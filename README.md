# Job Card

Workshop job-card app for Compass Automatic Gear. Staff open a card for every car that comes in
(customer, plate, brand, model, colour, mileage, fuel level, comments, photos, a short video and the
customer's signature), work on it, and mark it finished. The same Flutter code base runs as:

| Target | Purpose |
| --- | --- |
| **Android app** | Creating, editing and finishing cards in the workshop (side-loaded, 64-bit phones only) |
| **Web portal** | Viewing cards, dashboard, photo viewer and the "Old data" Storage clean-up |

The web portal is **view only** by design: cards are created and edited from the phones.

## Stack

- Flutter 3.44 / Dart 3.12, GetX for state and routing.
- Firebase: Authentication (e-mail + password), Cloud Firestore, Cloud Storage, Cloud Messaging
  (push), Hosting, Cloud Functions (Node 22) and the *Resize Images* extension.
- Android: Gradle 8.14, AGP 8.11, Kotlin 2.2, Java 17.

### Firestore

| Collection | Content |
| --- | --- |
| `car_card` | One document per job card. `status` is `true` while the card is open ("New cards") and `false` once finished. `user_id` is the signed-in account, `timestamp` the creation time, `car_images` the photo URLs, `customer_signature` and `car_video` single URLs, `creator_token` the push token of the phone that created the card. |
| `users` | One document per account with `users_tokens`, the push tokens of that user's phones. |

Lists are paged (48 cards a page) and sorted newest first on the composite index
`(user_id, status, timestamp desc)`. Counters use `count()` aggregations and refresh live.

### Storage layout

| Path | Written by |
| --- | --- |
| `car_pictures/<ms>.jpg` | the app, compressed to 2000 px before upload |
| `car_pictures/thumbnails/<ms>_600x600.jpg` | the app (600 px, uploaded with the photo) and the Resize Images extension |
| `customers_signatures/<ms>.png` | the app |
| `car_videos/<ms>.mp4` | the app |

Every client looks for the thumbnail first and only loads the original when a photo is opened.
Images are cached for 3 days on the device / in the browser.

### Cloud Functions (`functions/`)

- `notifyNewCard` – Firestore trigger on `car_card/{id}`: sends a push to every registered phone of
  every user except the one that created the card, and removes tokens reported as dead.
  Tapping the notification opens the card.
Thumbnails for the photos taken before the extension existed were created once with a backfill
function (finished 2026-10-14, then removed). New photos get their thumbnail from the app and the
extension.

The extension configuration lives in `extensions/`.

## Getting started

Prerequisites: Flutter SDK, Android Studio (SDK + an emulator), Node 22 and the Firebase CLI
(`npm i -g firebase-tools`, then `firebase login`).

Files that are **not** in the repository and must be added by hand:

- `android/app/google-services.json` – from the Firebase console (Android app settings).

```bash
flutter pub get
flutter run -d emulator-5554            # Android emulator
flutter run -d chrome                   # web portal in Chrome
```

## Building

**Android APK (64-bit only, side-loaded)**

```bash
flutter build apk --release --target-platform android-arm64
# -> build/app/outputs/flutter-apk/app-release.apk
```

The app is not published on the Play Store, so the default debug signing is used on purpose.
Bump `version:` in `pubspec.yaml` for every release so phones can upgrade in place.

**Web portal**

```bash
flutter build web --release
firebase deploy --only hosting
```

`web/index.html` shows a branded loading screen until Flutter paints its first frame. Hosting
serves `index.html` and the JavaScript with `no-cache` and the assets for 7 days, so a new deploy is
picked up on the next reload (the Flutter service worker may need one extra reload).

**Cloud Functions and extension**

```bash
cd functions && npm install && cd ..
firebase deploy --only functions
firebase deploy --only extensions
```

## Code layout

```
lib/
  main.dart                 routes; web theme or mobile theme by platform
  common/                   shared helpers: image cache, upload compression, thumbnail upload,
                            Storage clean-up, session, root messenger, notification → card routing
  mobile/                   phone-only widgets: form sections, signature pad, saving screen, gallery
  web/                      portal: shell + side navigation, theme, widgets, images, photo viewer,
                            controllers (cards, dashboard, card details, old data) and pages
  screens/, controllers/, widgets/, models/   mobile screens (login, lists, card, edit, images)
functions/                  Cloud Functions
extensions/                 Resize Images extension parameters
web/                        index.html (loading screen), manifest, messaging service worker
```

## Web portal pages

- **Dashboard** – open / finished / today / this week counts and the latest cards.
- **New cards / Finished cards** – poster grid (4 a row) or table, search across all fields,
  live counters, card page with thumbnails, full-size viewer with arrow keys, call / WhatsApp / share.
- **Old data** – lists every file in Storage that no card references (photos, signatures, videos),
  grouped by the day it was taken, so leftovers from deleted cards can be reviewed and removed.
  Files from the last 24 hours are skipped in case a card is still being created. Scanning only
  reads; nothing is deleted until files are selected and the deletion confirmed. Deleting a photo also
  removes its thumbnail. Storage has no recycle bin, so delete a day at a time.

## Notes

- Access to data is controlled by the Firestore and Storage security rules.
- App Check is intentionally off: it would block side-loaded phones.
- Tests: `flutter test` fails on Windows when the checkout path contains an apostrophe; run it from a
  path without one.
