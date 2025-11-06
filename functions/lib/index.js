"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.markBookUnavailable = void 0;
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-functions/v2/firestore");
admin.initializeApp();
const db = admin.firestore();
exports.markBookUnavailable = (0, firestore_1.onDocumentCreated)("swaps/{swapId}", async (event) => {
    const swapSnap = event.data;
    if (!swapSnap || !swapSnap.exists)
        return;
    const swapData = swapSnap.data();
    if (!swapData)
        return;
    const bookId = swapData.bookId;
    // const toUserId = swapData.toUserId as string;
    try {
        const bookRef = db.collection("books").doc(bookId);
        const bookSnap = await bookRef.get();
        if (!bookSnap.exists) {
            console.log("Book does not exist:", bookId);
            return;
        }
        const bookData = bookSnap.data();
        if ((bookData === null || bookData === void 0 ? void 0 : bookData.isAvailable) === false) {
            console.log("Book is already unavailable:", bookId);
            return;
        }
        await bookRef.update({
            isAvailable: false,
        });
        console.log(`Book ${bookId} marked as unavailable.`);
    }
    catch (error) {
        console.error("Error marking book unavailable:", error);
    }
});
//# sourceMappingURL=index.js.map