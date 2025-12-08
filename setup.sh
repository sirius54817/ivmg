#!/bin/bash

# Inventory Management Setup Script

echo "🚀 Setting up Inventory Management System..."

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. For Linux/Desktop testing:"
echo "   - Firebase has limited desktop support"
echo "   - Recommend testing on Android/iOS/Web"
echo ""
echo "2. Run on Android:"
echo "   flutter run -d android"
echo ""
echo "3. Run on Web:"
echo "   flutter run -d chrome"
echo ""
echo "4. Create your first admin user:"
echo "   a. Go to Firebase Console: https://console.firebase.google.com"
echo "   b. Navigate to Authentication → Users"
echo "   c. Click 'Add User' and create an account"
echo "   d. Go to Firestore Database → users collection"
echo "   e. Find the user document (by UID)"
echo "   f. Add these fields:"
echo "      - email: (user's email)"
echo "      - name: 'Admin'"
echo "      - role: 'admin'"
echo "      - createdAt: (current timestamp)"
echo ""
echo "5. Login with the admin account"
echo "6. Create 'user' accounts from admin dashboard"
echo "7. Login as user to create 'staff' and 'products'"
echo "8. Login as staff to record sales"
echo ""
echo "🎨 The app uses your custom color scheme!"
echo "📱 Happy inventory managing!"
