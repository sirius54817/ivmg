# Quick Start Guide - Inventory Management System

## 🚀 First Time Setup

### Step 1: Create Admin Account in Firebase

1. Open Firebase Console: https://console.firebase.google.com
2. Select your project: `ivmg-eebef`
3. Go to **Authentication** → **Users** → **Add User**
4. Create an admin account with email and password
5. Copy the **UID** of the newly created user
6. Go to **Firestore Database**
7. Click **Start Collection** → Name it `users`
8. Create a document with the UID as the Document ID
9. Add these fields:
   - `email`: (string) the admin email
   - `name`: (string) "Admin" or any name
   - `role`: (string) "admin"
   - `createdAt`: (timestamp) current time
   - `createdBy`: (string) null or leave empty

### Step 2: Login and Start Using

1. Launch the app
2. Login with the admin credentials you just created
3. From Admin Dashboard, create **User** accounts
4. Login as a User to:
   - Create **Staff** accounts
   - Add **Products** (with categories, codes, and stock)
5. Login as Staff to:
   - Record sales
   - View sales history

## 📱 User Roles & Permissions

### 👨‍💼 Admin
- ✅ Create User accounts
- ✅ View all users
- ❌ Cannot create products or staff directly

### 👤 User
- ✅ Create Staff accounts
- ✅ Add/Manage Products
- ✅ Update stock levels
- ✅ View all products
- ❌ Cannot record sales

### 🛒 Staff
- ✅ Record sales transactions
- ✅ Fill customer information
- ✅ Select products from categories
- ✅ View personal sales history
- ❌ Cannot add products or create accounts

## 🏷️ Product Categories

- **Category 1** (cat1)
- **Category 2** (cat2)
- **Category 3** (cat3)

Each product requires:
- Product Name
- Item Code
- SSLC Code
- Initial Stock Count

## 💰 Sales Process (Staff)

1. Navigate to **Sell Product** tab
2. Enter customer information:
   - Name
   - Phone Number
   - Address
3. Select product:
   - Choose **Category** first
   - Then choose **Product** from that category
   - Enter **Quantity**
4. Review product details shown
5. Click **Submit Sale**
6. Stock automatically decreases!

## 📊 Features

- ✨ Real-time stock tracking
- 🔴 Low stock indicators (< 10 items)
- 📈 Automatic stock updates on sales
- 📱 Responsive design
- 🎨 Custom pink/rose theme
- 🔒 Role-based access control
- 📝 Sales history tracking

## 🎨 Theme

The app uses your custom color scheme:
- Pink/Rose primary colors
- Blue/Cyan secondary colors
- Light cream backgrounds
- Bold borders for modern look
- Dark mode support

## 🔥 Firebase Security

Make sure to set up Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if false; // Only through app logic
    }
    
    // Products
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['user'];
    }
    
    // Sales
    match /sales/{saleId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'staff';
    }
  }
}
```

## 📞 Support

For any issues or questions, check:
- Firebase Console for backend data
- Flutter logs for debugging
- README.md for detailed documentation

Happy Inventory Managing! 🎉
