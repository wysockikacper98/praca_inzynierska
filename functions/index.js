const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const ordersRef = db.collection("orders");
const firmRef = db.collection("firms")

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

// exports.sendNotificationsAutomaticly = functions.pubsub
//   // .schedule("every day 00:00")
//   .schedule("every day 5 minutes")
//   .onRun(( context )=> {
//   functions.logger.log("User cleanup finished");
// });
// every 24 hours
exports.scheduledFunction = functions.pubsub.schedule("every 24 hours")
  .onRun(async (context) => {
    const snapshot = await ordersRef.where("status", "!=", "COMPLETED").get();
    if (!snapshot.empty) {
      snapshot.forEach(doc => {
        if (doc.data()["status"] === "PROCESSING") {
          const dateDifference = dateDifferenceInDays(doc.data()["dateTo"].toDate());
          if (dateDifference === 2) {
            sendNotificationToFirm(doc.data()["firmID"], doc.id, "Opóźnienie zamówienia zostało zajerestrowane.", 'Niedotrzymanie terminu zakończenia poskutkowało zarejetrowaniem opóźnienia w systemie.', true);
          } else if (dateDifference === 1) { // spóźniony jeden dzień
            sendNotificationToFirm(doc.data()["firmID"], doc.id, "Zamówienie nie zostało zakończone.", "Dalsze niedotrzymanie terminu poskutkuje zarejestrowaniem opóźnienia w sytemie.", false);
          } else if (dateDifference === -1) { //dzień przed końcem zlecenia
            sendNotificationToFirm(doc.data()["firmID"], doc.id, "Jutro ostatni dzień wykonywania pracy.", doc.data()["title"], false);
          }


        } else { // PENDING
          const dateDifference = dateDifferenceInDays(doc.data()["dateFrom"].toDate());
          if (dateDifference === -2) {
            sendNotificationToFirm(doc.data()["firmID"], doc.id, "Spóźnienie zostało zarejestrowane", "Niedotrzymanie terminu rozpoczęcia poskutkowało zarejetrowaniem opóźnienia w systemie.", true);
          } else if (dateDifference === -1) { // spóźniony jeden dzień
            sendNotificationToFirm(doc.data()["firmID"], doc.id, "Jednodniowe spóźnienie z rozpoczęciem prac.", "Kolejny dzień spóźnienia zostanie zarejestrowany w systemie", false);
          } else if (dateDifference === 1) { //dzień przed rozpoczęciem zlecenia
            sendNotificationToFirm(doc.data()["firmID"], doc.id, "Jutro pierwszy dzień wykonywania pracy.", doc.data()['title'], false);

          }
        }
      });
    }
    return null;
  });

async function sendNotificationToFirm(firmID, orderID, messageTitle, orderTitle, isLate) {
  const doc = await firmRef.doc(firmID).get();

  if (doc.exists) {
    const token = doc.data()['tokens'];
    if(isLate) {
      await firmRef.doc(firmID).update({late: FieldValue.increment(1)})
    }
    if(token != null) {
      admin.messaging()
        .sendToDevice(
          token,
          {
            "data": {
              "name": "/order-details",
              "details": orderID,
            },
            "notification": {
              "title": messageTitle,
              "body": orderTitle,
              "android_channel_id": "4eda5bda-3bd6-11ec-8d3d-0242ac130003",
            },
          },
        ).then();
    }
  }
}

// if plus some date is before today
// if 0 today
// if  negative some date is in future
const dateDifferenceInDays = (someDate) => {
  const today = new Date();
  const diffTime = today - someDate;
  console.log("Today: ", today);
  console.log("dateFrom: ", someDate);
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}

