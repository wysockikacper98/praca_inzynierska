const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.orderNotification = functions.https.onCall((data, context) => {
  console.log("orderID:", data.orderID);
  console.log("userID:", data.userID);
  console.log("firmID:", data.firmID);

  // get user details
  admin.firestore().collection("users").doc(data.userID).get()
      .then((user) => {
        console.log("USER email with dot", user.data().email);
        console.log("USER email by []", user.data()["email"]);
        admin.messaging().sendToDevice(
            user.data().tokens, // ['token_1', 'token_2', ...]
            {
              data: {
                orderID: JSON.stringify(data.orderID),
                userID: JSON.stringify(data.userID),
                firmID: JSON.stringify(data.firmID),
              },
            },
            {
              // Required for background/quit data-only messages on iOS
              contentAvailable: true,
              // Required for background/quit data-only messages on Android
              priority: "high",
            }
        );
      });
});


//  exports.orderNotificationAutomated = functions.firestore
//  .document('orders/{newOrder}')
//      .onCreate((snapshot, context) => {
//
//          return admin.messaging().sendToDevice(
//                             user.data().tokens, // ['token_1', 'token_2', ...]
//                             {
//                               data: {
//                                 orderID: JSON.stringify(data.orderID),
//                                 userID: JSON.stringify(data.userID),
//                                 firmID: JSON.stringify(data.firmID),
//                               },
//                             },
//                             {
//                               // Required for background/quit data-only messages on iOS
//                               contentAvailable: true,
//                               // Required for background/quit data-only messages on Android
//                               priority: "high",
//                             }
//                         );
//      });
