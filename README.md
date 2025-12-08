# Inventory Management System

A comprehensive Flutter-based inventory management application with Firebase backend, featuring role-based access control and real-time data synchronization.

## Features

### 🔐 User Roles

#### Admin
- Create user accounts
- View all users in the system
- Full system overview

#### User
- Create staff accounts
- Manage products (add, view, update stock)
- Organize products into 3 categories (Category 1, Category 2, Category 3)
- Add product details (Item Code, SSLC Code, Stock Count)
- Increase stock levels

#### Staff
- Record sales transactions
- Fill customer information forms
- Select products via cascading dropdowns (Category → Product)
- View personal sales history
- Automatic stock deduction on sale

### 📦 Product Management
- **3 Categories**: Category 1, Category 2, Category 3
- **Product Details**:
  - Product Name
  - Item Code
  - SSLC Code
  - Stock Count
- Real-time stock tracking
- Low stock indicators
- Stock increase functionality

### 💰 Sales System
- **Customer Information**:
  - Name
  - Phone Number
  - Address
- **Product Selection**:
  - Category dropdown
  - Product dropdown (filtered by category)
  - Quantity input with stock validation
- Auto-filled staff information
- Automatic stock updates
- Sales history tracking

### 🎨 Design
- Custom color scheme based on provided CSS variables
- Light and dark theme support
- Responsive card-based UI
- Material Design 3
- Border-based shadowing for a modern look

## Getting Started

### Prerequisites
- Flutter SDK (3.10.1 or higher)
- Firebase project configured
- Android/iOS/Linux/Windows/Web development environment

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - The app is already configured with Firebase
   - Firebase options are in `lib/firebase_options.dart`

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/              # Data models
│   ├── app_user.dart
│   ├── product.dart
│   ├── sale.dart
│   └── user_role.dart
├── services/            # Business logic
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── sales_service.dart
│   └── user_service.dart
├── screens/             # UI screens
│   ├── admin/          # Admin dashboard
│   ├── user/           # User dashboard
│   ├── staff/          # Staff dashboard
│   └── login_screen.dart
├── theme/              # App theming
│   └── app_theme.dart
├── firebase_options.dart
└── main.dart
```

## Firebase Collections

### users
```
{
  email: string
  name: string
  role: "admin" | "user" | "staff"
  createdBy: string (user ID)
  createdAt: timestamp
}
```

### products
```
{
  name: string
  category: "cat1" | "cat2" | "cat3"
  itemCode: string
  sslcCode: string
  stockCount: number
  createdBy: string (user ID)
  createdAt: timestamp
  updatedAt: timestamp
}
```

### sales
```
{
  productId: string
  productName: string
  itemCode: string
  customerName: string
  customerPhone: string
  customerAddress: string
  staffId: string
  staffName: string
  quantity: number
  saleDate: timestamp
}
```

## Default Test Accounts

You'll need to create an admin account first through Firebase Console:

1. Go to Firebase Console → Authentication
2. Add user manually with role "admin" in Firestore
3. Use that account to create other users

## Color Scheme

The app uses a custom color palette:
- **Primary**: Pink/Rose tones
- **Secondary**: Blue/Cyan tones
- **Accent**: Yellow/Cream tones
- **Background**: Light cream/blue tones
- **Borders**: Matching primary colors

## Technologies

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **State Management**: StatefulWidget with Streams
- **Architecture**: Service-based architecture

## License

This project is private and proprietary.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# ivmg
