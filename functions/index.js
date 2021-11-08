const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewTripNotification = functions.https.onCall((data, context) => {
  const obj = JSON.parse(data);

  admin.messaging()
      .sendToDevice(
          obj.tokens,
          {"data": {
            "name": obj.data.name,
            "details": obj.data.details,
          },
          "notification": {
            "title": obj.notification.title,
            "body": obj.notification.body,
            "android_channel_id": "4eda5bda-3bd6-11ec-8d3d-0242ac130003",
          }}
      );
});
