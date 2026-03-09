import serial
import time
import cv2
import numpy as np
import tensorflow as tf
import firebase_admin
from firebase_admin import credentials, firestore

# ==============================
# ✅ FIREBASE SETUP
# ==============================

cred = credentials.Certificate(
    r"D:\eco_credit_app\serviceAccountKey.json"
)

firebase_admin.initialize_app(cred)

db = firestore.client()
print("✅ Firebase Connected!")

# ==============================
# ✅ ARDUINO SETUP
# ==============================

arduino = serial.Serial("COM5", 9600, timeout=1)
time.sleep(2)
print("✅ Arduino Connected!")

# ==============================
# ✅ AI MODEL LOAD
# ==============================

model = tf.keras.models.load_model("waste_model.h5")

labels = ["Plastic", "Organic", "Recyclable", "Non-Recyclable"]

credit_rules = {
    "Plastic": 10,
    "Organic": 15,
    "Recyclable": 12,
    "Non-Recyclable": 5
}

command_map = {
    "Plastic": "1",
    "Organic": "2",
    "Recyclable": "3",
    "Non-Recyclable": "4"
}

# ==============================
# ✅ STUDENT UID (Demo)
# ==============================

student_uid = "PASTE_FIREBASE_UID_HERE"

# ==============================
# ✅ CAMERA CAPTURE
# ==============================

def capture_image():
    cam = cv2.VideoCapture(0)
    print("📷 Press SPACE to Capture Waste Image")

    while True:
        ret, frame = cam.read()
        cv2.imshow("Smart Dustbin Camera", frame)

        key = cv2.waitKey(1)

        if key == 32:  # SPACE
            img = frame
            break

    cam.release()
    cv2.destroyAllWindows()
    return img

# ==============================
# ✅ AI PREDICTION
# ==============================

def predict_waste(img):
    img = cv2.resize(img, (224, 224))
    img = img / 255.0
    img = np.expand_dims(img, axis=0)

    prediction = model.predict(img)
    class_index = np.argmax(prediction)

    waste_type = labels[class_index]
    return waste_type

# ==============================
# ✅ FIREBASE CREDIT UPDATE
# ==============================

def update_firebase_credits(uid, waste_type):

    credits = credit_rules[waste_type]

    user_ref = db.collection("users").document(uid)

    # ✅ Add Credits
    user_ref.update({
        "credits": firestore.Increment(credits)
    })

    # ✅ Add Transaction Record
    db.collection("transactions").add({
        "userId": uid,
        "title": f"Smart Bin Disposal ({waste_type})",
        "points": credits,
        "date": time.strftime("%Y-%m-%d")
    })

    print(f"✅ Firebase Updated: +{credits} Credits Added!")

# ==============================
# ✅ SEND TO ARDUINO
# ==============================

def send_command(waste_type):

    command = command_map[waste_type]

    print(f"✅ Sending Arduino Command: {command}")

    arduino.write((command + "\n").encode())

    while True:
        response = arduino.readline().decode().strip()

        if response:
            print("Arduino:", response)

        if "DONE" in response:
            print("✅ Sorting Completed!")
            break

# ==============================
# ✅ MAIN LOOP
# ==============================

while True:
    print("\n===== SMART BIN SYSTEM RUNNING =====")

    img = capture_image()

    waste_type = predict_waste(img)
    print("✅ AI Detected:", waste_type)

    send_command(waste_type)

    # ✅ Update Firebase After DONE
    update_firebase_credits(student_uid, waste_type)

    again = input("Sort another waste item? (y/n): ")

    if again.lower() != "y":
        print("Exiting System...")
        break

arduino.close()
