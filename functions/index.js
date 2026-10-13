// Cloud Functions for the Job Card project.
//
// notifyNewCard: push notification to every phone when a card is added.
// (The one-off thumbnail backfill that used to live here finished on
// 2026-10-14; new photos get thumbnails from the app and the Resize Images
// extension.)
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

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
