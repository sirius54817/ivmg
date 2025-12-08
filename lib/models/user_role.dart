enum UserRole {
  admin,
  user,
  staff;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'User';
      case UserRole.staff:
        return 'Staff';
    }
  }
}
