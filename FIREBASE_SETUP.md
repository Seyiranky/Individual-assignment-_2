# Firebase Console Setup Checklist

## 1. Enable Authentication Providers

### Steps:
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Email/Password** provider:
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"

3. Enable **Google Sign-In** provider (if using):
   - Click on "Google"
   - Toggle "Enable" to ON
   - Add support email
   - Click "Save"

## 2. Create Firestore Database

### Steps:
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose **Production mode** or **Test mode** (Test mode allows reads/writes for 30 days)
4. Select a **location** for your database
5. Click "Enable"

**Note:** If you already have a database, make sure it's in the correct mode.

## 3. Update Firestore Security Rules

### Steps:
1. Go to Firebase Console → Firestore Database → Rules tab
2. Copy the rules from `firestore.rules` file in your project
3. Paste and click "Publish"

**Or** use Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

## 4. Create Storage Bucket & Update Rules

### Steps:
1. Go to Firebase Console → Storage
2. If no bucket exists, click "Get started"
3. Start in **Production mode** (more secure)
4. Choose a location
5. Go to Storage → Rules tab
6. Copy the rules from `storage.rules` file in your project
7. Paste and click "Publish"

**Or** use Firebase CLI:
```bash
firebase deploy --only storage
```

## 5. Create Required Firestore Indexes (If Needed)

When you run the app, Firebase may prompt you to create indexes. Click the link in the error message to auto-create them, or:

1. Go to Firebase Console → Firestore Database → Indexes tab
2. Click "Create Index" if needed

**Common indexes needed:**
- Collection: `books`
  - Fields: `isAvailable` (Ascending), `createdAt` (Descending)
  
- Collection: `books`
  - Fields: `ownerId` (Ascending), `createdAt` (Descending)

- Collection: `swaps`
  - Fields: `toUserId` (Ascending), `createdAt` (Descending)

- Collection: `swaps`
  - Fields: `fromUserId` (Ascending), `createdAt` (Descending)

- Collection: `chats`
  - Fields: `participants` (Array), `lastMessageTime` (Descending)

## 6. Verify Firebase Configuration

### Check `firebase_options.dart`:
- Make sure it contains your Firebase project credentials
- If missing, run: `flutterfire configure` in your project directory

## 7. Test the Setup

1. **Test Authentication:**
   - Try registering a new user
   - Try logging in
   - Check Authentication → Users tab for new users

2. **Test Firestore:**
   - Post a book in the app
   - Check Firestore Database → `books` collection for new documents

3. **Test Storage:**
   - Upload a book cover image
   - Check Storage → `book_covers` folder for uploaded images

## Troubleshooting

### If books aren't posting:
- Check Firestore rules in Console
- Check browser console for errors
- Verify you're logged in (Authentication → Users)

### If images aren't uploading:
- Check Storage rules in Console
- Verify Storage bucket exists
- Check browser console for permission errors

### If you see index errors:
- Click the error link to auto-create the index
- Or manually create indexes as listed above

