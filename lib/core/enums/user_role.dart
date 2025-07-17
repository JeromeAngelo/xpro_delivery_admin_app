enum UserRole {
  teamLeader,
  helper,
  driver;

  String get displayText {
    switch (this) {
      case UserRole.teamLeader:
        return 'Team Leader';
      case UserRole.helper:
        return 'Helper';
      case UserRole.driver:
        return 'Driver';
    }
  }
}
