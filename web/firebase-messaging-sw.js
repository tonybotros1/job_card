// // Import and configure the Firebase SDK
// // These scripts are made available when the app is served or deployed on Firebase Hosting
// // If you do not serve/host your project using Firebase Hosting see https://firebase.google.com/docs/web/setup
// // importScripts('/__/firebase/9.2.0/firebase-app-compat.js');
// // importScripts('/__/firebase/9.2.0/firebase-messaging-compat.js');
// // importScripts('/__/firebase/init.js');

// // const messaging = firebase.messaging();


// //  * Here is is the code snippet to initialize Firebase Messaging in the Service
// //  * Worker when your app is not hosted on Firebase Hosting.

//  // Give the service worker access to Firebase Messaging.
//  // Note that you can only use Firebase Messaging here. Other Firebase libraries
//  // are not available in the service worker.
// //  importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-app-compat.js');
// //  importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging-compat.js');

//  import { initializeApp } from "firebase/app";
//  import { getMessaging } from "firebase/messaging/sw";
 
// //  import { getMessaging, onMessage } from "firebase/messaging";

//  // Initialize the Firebase app in the service worker by passing in
//  // your app's Firebase config object.
//  // https://firebase.google.com/docs/web/setup#config-object
//  const firebaseConfig = firebase.initializeApp({
//     apiKey: "AIzaSyDQE2wU5fSbsePR5XAzhxRhHv3eHppwv94",
//     authDomain: "job-card-62478.firebaseapp.com",
//     projectId: "job-card-62478",
//     storageBucket: "job-card-62478.appspot.com",
//     messagingSenderId: "9681419746",
//     appId: "1:9681419746:web:4f6f116df48e511f47cdbb",
//     measurementId: "G-LDQZ5NLESB"
//  });

//  // Retrieve an instance of Firebase Messaging so that it can handle background
//  // messages.
// //  const messaging = firebase.messaging();
//  const app = initializeApp(firebaseConfig);
//  const messaging = getMessaging(app);

// onMessage(messaging, (payload) => {
//   console.log('Message received. ', payload);
//   // ...
// });

// import { onBackgroundMessage } from "firebase/messaging/sw";

// onBackgroundMessage(messaging, (payload) => {
//   console.log('[firebase-messaging-sw.js] Received background message ', payload);
//   // Customize notification here
//   const notificationTitle = 'Background Message Title';
//   const notificationOptions = {
//     body: 'Background Message body.',
//     icon: '/firebase-logo.png'
//   };

//   self.registration.showNotification(notificationTitle,
//     notificationOptions);
// });


// // If you would like to customize notifications that are received in the
// // background (Web app is closed or not in browser focus) then you should
// // implement this optional method.
// // Keep in mind that FCM will still show notification messages automatically 
// // and you should use data messages for custom notifications.
// // For more info see: 
// // https://firebase.google.com/docs/cloud-messaging/concept-options
// // messaging.onBackgroundMessage(function(payload) {
// //   console.log('[firebase-messaging-sw.js] Received background message ', payload);
// //   // Customize notification here
// //   const notificationTitle = 'Background Message Title';
// //   const notificationOptions = {
// //     body: 'Background Message body.',
// //     icon: '/firebase-logo.png'
// //   };

// //   self.registration.showNotification(notificationTitle,
// //     notificationOptions);
// // });


