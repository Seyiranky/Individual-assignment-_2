import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

admin.initializeApp();
const db = admin.firestore();

export const markBookUnavailable = onDocumentCreated("swaps/{swapId}", async (event) => {
  const swapSnap = event.data;
  if (!swapSnap || !swapSnap.exists) return;

  const swapData = swapSnap.data();
  if (!swapData) return;

  const bookId = swapData.bookId as string;
  // const toUserId = swapData.toUserId as string;

  try {
    const bookRef = db.collection("books").doc(bookId);
    const bookSnap = await bookRef.get();

    if (!bookSnap.exists) {
      console.log("Book does not exist:", bookId);
      return;
    }

    const bookData = bookSnap.data();
    if (bookData?.isAvailable === false) {
      console.log("Book is already unavailable:", bookId);
      return;
    }

    await bookRef.update({
      isAvailable: false,
    });

    console.log(`Book ${bookId} marked as unavailable.`);
  } catch (error) {
    console.error("Error marking book unavailable:", error);
  }
});
