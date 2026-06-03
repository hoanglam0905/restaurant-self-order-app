class StaffSettingsProfileModel {
  const StaffSettingsProfileModel({
    required this.fullName,
    required this.staffCode,
    required this.roleName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.salaryDisplay,
    required this.currentShiftName,
    required this.currentShiftTime,
    required this.appVersion,
    this.avatarAssetPath,
  });

  final String fullName;
  final String staffCode;
  final String roleName;
  final String email;
  final String phoneNumber;
  final String address;
  final String salaryDisplay;
  final String currentShiftName;
  final String currentShiftTime;
  final String appVersion;
  final String? avatarAssetPath;
}
