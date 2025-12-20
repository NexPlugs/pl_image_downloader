enum PermissionType {
  /// Internet Permission
  internet(permission: "internet"),

  /// Foreground Service Permission
  foregroundService(permission: "foregroundService"),

  /// Media Access Permission
  mediaAccess(permission: "mediaAccess"),

  /// Storage Permission
  storage(permission: "storage");

  final String permission;

  const PermissionType({required this.permission});

  /// Get the permission string
  String get permissionString => permission;

  /// Get the permission type from the permission string
  static PermissionType fromString(String permission) {
    return PermissionType.values.firstWhere(
      (e) =>
          e.permission.toLowerCase().trim() == permission.toLowerCase().trim(),
      orElse: () => throw Exception('Permission not found: $permission'),
    );
  }
}
