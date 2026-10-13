// One-off backfill: creates car_pictures/thumbnails/<name>_600x600.jpg for every
// photo in car_pictures/ that has no thumbnail yet. Originals are only read.
//
// The Resize Images extension (0.3.x) no longer backfills, so this function
// does it for the photos that existed before the extension was installed.
// New uploads are handled by the extension itself (and by the mobile app).
//
// Call it repeatedly with the returned pageToken until done:
//   POST https://<region>-<project>.cloudfunctions.net/backfillThumbnails
//   headers: x-backfill-token: <BACKFILL_TOKEN>
//   body: { "pageToken": "..." }  (optional)
const { onRequest } = require('firebase-functions/v2/https');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { defineString } = require('firebase-functions/params');
const admin = require('firebase-admin');
const sharp = require('sharp');

admin.initializeApp();

// ---------------------------------------------------------------------------
// New card -> push notification to every registered device of every user,
// except the phone that created the card (its token is stored on the card as
// `creator_token`). Tokens FCM reports as dead are removed from the user doc.
// ---------------------------------------------------------------------------
exports.notifyNewCard = onDocumentCreated(
  { document: 'car_card/{cardId}', region: 'us-central1' },
  async (event) => {
    const card = event.data ? event.data.data() : null;
    if (!card) return;
    const creator = typeof card.creator_token === 'string' ? card.creator_token : '';

    const users = await admin.firestore().collection('users').get();
    const owners = new Map(); // token -> user doc ref
    users.forEach((doc) => {
      const list = doc.get('users_tokens');
      if (!Array.isArray(list)) return;
      list.forEach((t) => {
        if (typeof t === 'string' && t && t !== creator) owners.set(t, doc.ref);
      });
    });
    const tokens = [...owners.keys()];
    if (tokens.length === 0) return;

    const title = 'New card added';
    const vehicle = [card.car_brand, card.car_model].filter(Boolean).join(' ').replace(/\s+/g, ' ').trim();
    const body = vehicle ? `${vehicle}${card.plate_number ? ' · ' + card.plate_number : ''}` : 'A new job card was added';

    const dead = [];
    for (let i = 0; i < tokens.length; i += 500) {
      const batch = tokens.slice(i, i + 500);
      const res = await admin.messaging().sendEachForMulticast({
        tokens: batch,
        notification: { title, body },
        android: { priority: 'high', notification: { sound: 'default' } },
        apns: { payload: { aps: { sound: 'default' } } },
        data: { kind: 'new_card', cardId: event.params.cardId },
      });
      res.responses.forEach((r, idx) => {
        const code = r.error && r.error.code;
        if (!r.success && (code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-registration-token' || code === 'messaging/invalid-argument')) {
          dead.push(batch[idx]);
        }
      });
    }
    for (const t of dead) {
      await owners.get(t).update({ users_tokens: admin.firestore.FieldValue.arrayRemove(t) });
    }
    console.log(`notifyNewCard ${event.params.cardId}: sent to ${tokens.length - dead.length} device(s), removed ${dead.length} dead token(s)`);
  },
);

const BACKFILL_TOKEN = defineString('BACKFILL_TOKEN');

const PREFIX = 'car_pictures/';
const THUMB_DIR = 'car_pictures/thumbnails/';
const SIZE = 600;
const PAGE_SIZE = 1000;
const PARALLEL = 48;
const TIME_BUDGET_MS = 50 * 60 * 1000; // leave margin under the 60-minute limit

function thumbPathFor(name) {
  const base = name.substring(PREFIX.length);
  const dot = base.lastIndexOf('.');
  const stem = dot > 0 ? base.substring(0, dot) : base;
  return `${THUMB_DIR}${stem}_${SIZE}x${SIZE}.jpg`;
}

async function makeThumb(bucket, file) {
  const [buffer] = await file.download();
  const out = await sharp(buffer, { failOn: 'none' })
    .rotate()
    .resize(SIZE, SIZE, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 80, mozjpeg: true })
    .toBuffer();
  await bucket.file(thumbPathFor(file.name)).save(out, {
    contentType: 'image/jpeg',
    resumable: false,
    metadata: {
      cacheControl: 'public,max-age=31536000',
      metadata: { resizedImage: 'true', backfilled: 'true' },
    },
  });
}

exports.backfillThumbnails = onRequest(
  { region: 'us-central1', memory: '4GiB', cpu: 4, timeoutSeconds: 3600, concurrency: 1, maxInstances: 1 },
  async (req, res) => {
    if (req.get('x-backfill-token') !== BACKFILL_TOKEN.value()) {
      res.status(403).send('forbidden');
      return;
    }
    const started = Date.now();
    const bucket = admin.storage().bucket();
    let pageToken = (req.body && req.body.pageToken) || undefined;
    const stats = { scanned: 0, created: 0, skipped: 0, failed: 0, pages: 0 };
    const failures = [];

    // Existing thumbnails, so already-covered photos are skipped cheaply.
    const existing = new Set();
    let thumbToken;
    do {
      const [files, , resp] = await bucket.getFiles({ prefix: THUMB_DIR, pageToken: thumbToken, maxResults: 5000, autoPaginate: false });
      files.forEach((f) => existing.add(f.name));
      thumbToken = resp && resp.nextPageToken;
    } while (thumbToken);

    const isPhoto = (f) =>
      f.name.startsWith(PREFIX) && !f.name.startsWith(THUMB_DIR) && /\.(jpe?g|png|webp)$/i.test(f.name);

    // Newest first: photos are named by their timestamp, so Storage lists them
    // oldest first. This mode lists every original once, sorts them newest
    // first and works down from `cursor` (the last name handled, exclusive),
    // so the photos people actually open get their thumbnails first.
    if (req.body && req.body.newestFirst) {
      const cursor = typeof req.body.cursor === 'string' ? req.body.cursor : '';
      const all = [];
      let listToken;
      do {
        const [files, , resp] = await bucket.getFiles({ prefix: PREFIX, pageToken: listToken, maxResults: 5000, autoPaginate: false });
        files.forEach((f) => {
          if (isPhoto(f)) all.push(f);
        });
        listToken = resp && resp.nextPageToken;
      } while (listToken);
      stats.scanned = all.length;
      all.sort((a, b) => (a.name < b.name ? 1 : a.name > b.name ? -1 : 0));
      const todo = all.filter((f) => (!cursor || f.name < cursor) && !existing.has(thumbPathFor(f.name)));
      stats.skipped = all.length - todo.length;
      let last = cursor;
      let i = 0;
      for (; i < todo.length && Date.now() - started < TIME_BUDGET_MS; i += PARALLEL) {
        const batch = todo.slice(i, i + PARALLEL);
        await Promise.all(
          batch.map(async (f) => {
            try {
              await makeThumb(bucket, f);
              stats.created += 1;
            } catch (e) {
              stats.failed += 1;
              if (failures.length < 20) failures.push(`${f.name}: ${e.message}`);
            }
          }),
        );
        last = batch[batch.length - 1].name;
      }
      const remaining = Math.max(0, todo.length - i);
      res.json({ done: remaining === 0, cursor: last || null, remaining, elapsedSec: Math.round((Date.now() - started) / 1000), ...stats, failures });
      return;
    }

    while (Date.now() - started < TIME_BUDGET_MS) {
      const [files, , resp] = await bucket.getFiles({ prefix: PREFIX, pageToken, maxResults: PAGE_SIZE, autoPaginate: false });
      stats.pages += 1;
      const todo = files.filter((f) => {
        if (!f.name.startsWith(PREFIX) || f.name.startsWith(THUMB_DIR)) return false;
        if (!/\.(jpe?g|png|webp)$/i.test(f.name)) return false;
        stats.scanned += 1;
        if (existing.has(thumbPathFor(f.name))) {
          stats.skipped += 1;
          return false;
        }
        return true;
      });

      for (let i = 0; i < todo.length; i += PARALLEL) {
        await Promise.all(
          todo.slice(i, i + PARALLEL).map(async (f) => {
            try {
              await makeThumb(bucket, f);
              stats.created += 1;
            } catch (e) {
              stats.failed += 1;
              if (failures.length < 20) failures.push(`${f.name}: ${e.message}`);
            }
          }),
        );
      }

      pageToken = resp && resp.nextPageToken;
      if (!pageToken) break;
    }

    res.json({ done: !pageToken, nextPageToken: pageToken || null, elapsedSec: Math.round((Date.now() - started) / 1000), ...stats, failures });
  },
);
