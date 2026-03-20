const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewsNotification = functions.firestore
  .document("news/{newsId}")
  .onCreate(async (snap, context) => {
    const newsData = snap.data();

    const title = newsData.title || "新しいお知らせ";
    const body = newsData.content || "新着ニュースがあります！";

    const message = {
      notification: {
        title: title,
        body: body,
      },
      topic: "news",
    };

    try {
      await admin.messaging().send(message);
      console.log("通知送信成功");
    } catch (error) {
      console.error("通知送信失敗:", error);
    }
  });