import { initializeApp } from "firebase/app"
import { getFirestore } from "firebase/firestore"

const firebaseConfig = {
  apiKey: "AIzaSyBaVwlEW3vg3YWI_dMGQl40ANajz3p90Q",
  authDomain: "oh-yeah-9fdc6.firebaseapp.com",
  projectId: "oh-yeah-9fdc6",
  storageBucket: "oh-yeah-9fdc6.firebasestorage.app",
  messagingSenderId: "642657130095",
  appId: "1:642657130095:web:30dd7511a0fab7021c9f9a",
  measurementId: "G-2YK0T5GBZE"
}

const app = initializeApp(firebaseConfig)

export const db = getFirestore(app)