const admin = require("firebase-admin");

// ✅ Load Service Account Key
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// ✅ Create User
admin
  .auth()
  .createUser({
    email: "demo@ecoapp.com",
    password: "eco12345",
  })
  .then((user) => {
    console.log("✅ User Created Successfully:", user.uid);
  })
  .catch((error) => {
    console.log("❌ Error Creating User:", error);
  });
