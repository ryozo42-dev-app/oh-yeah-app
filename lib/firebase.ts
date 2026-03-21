import { initializeApp } from "firebase/app"
import { getAuth } from "firebase/auth"
import { getFirestore } from "firebase/firestore"
import { getStorage } from "firebase/storage"
import { getFunctions } from "firebase/functions"

const firebaseConfig = {
  apiKey: "AIzaSyBaVw1EW3vg3YWI_dMGQl4OANajz3p9O9Q",
  authDomain: "oh-yeah-9fdc6.firebaseapp.com",
  projectId: "oh-yeah-9fdc6",
  storageBucket: "oh-yeah-9fdc6.firebasestorage.app",
  messagingSenderId: "642657130095",
  appId: "1:642657130095:web:30dd7511a0fab7021c9f9a",
  measurementId: "G-2YK0T5GBZE"
}

const app = initializeApp(firebaseConfig)

export const auth = getAuth(app)
export const db = getFirestore(app)
export const storage = getStorage(app)
export const functions = getFunctions(app)