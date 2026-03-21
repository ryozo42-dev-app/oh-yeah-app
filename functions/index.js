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

exports.saveDailyLogs = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("Asia/Tokyo")
  .onRun(async () => {

    const db = admin.firestore()
    const bucket = admin.storage().bucket()

    const today = new Date()
    today.setHours(0,0,0,0)

    const dateStr = today.toISOString().split("T")[0]

    const snapshot = await db.collection("logs")
      .where("timestamp", ">=", today)
      .get()

    let content = "action,operator,timestamp\n"

    snapshot.forEach(doc => {
      const d = doc.data()

      const time = d.timestamp
        ? new Date(d.timestamp.seconds * 1000).toLocaleString("ja-JP")
        : ""

      content += `${d.action},${d.operator},${time}\n`
    })

    const file = bucket.file(`logs/${dateStr}.csv`)

    await file.save(content)

    return null
  })