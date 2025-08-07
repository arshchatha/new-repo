enum UserRole {
  broker,
  carrier,
  admin,

}


extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.broker:
        return 'broker';
      case UserRole.carrier:
        return 'carrier';
      case UserRole.admin:
        return 'admin';
    }
  }
}
