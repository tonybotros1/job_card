// Firebase Cloud Messaging service worker for the web build.
// The Firebase SDK registers this file itself (scope /firebase-cloud-messaging-push-scope)
// when the app asks for a messaging token. It only receives messages while the
// page is in the background; foreground messages reach the Dart side through
// FirebaseMessaging.onMessage.
//
// Only the compat builds of firebase-app and firebase-messaging may be used in a
// service worker. Keep the version in step with the JS SDK version used by the
// firebase_core_web plugin (lib/src/firebase_sdk_version.dart).
importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging-compat.js');

// Web client configuration - the same public values as the kIsWeb branch of lib/main.dart.
firebase.initializeApp({
  apiKey: 'AIzaSyDQE2wU5fSbsePR5XAzhxRhHv3eHppwv94',
  authDomain: 'job-card-62478.firebaseapp.com',
  projectId: 'job-card-62478',
  storageBucket: 'job-card-62478.appspot.com',
  messagingSenderId: '9681419746',
  appId: '1:9681419746:web:4f6f116df48e511f47cdbb',
  measurementId: 'G-LDQZ5NLESB',
});

const messaging = firebase.messaging();

// Messages with a "notification" block are shown by the browser automatically.
// Data-only messages arrive here and need an explicit notification.
messaging.onBackgroundMessage((payload) => {
  if (payload.notification) return;
  const data = payload.data || {};
  self.registration.showNotification(data.title || 'Job Card', {
    body: data.body || '',
    icon: '/icons/Icon-192.png',
  });
});
