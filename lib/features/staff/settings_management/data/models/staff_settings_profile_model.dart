class StaffSettingsProfileModel {
  const StaffSettingsProfileModel({
    required this.staffId,
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

  final int staffId;
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

  StaffSettingsProfileModel copyWith({
    int? staffId,
    String? fullName,
    String? staffCode,
    String? roleName,
    String? email,
    String? phoneNumber,
    String? address,
    String? salaryDisplay,
    String? currentShiftName,
    String? currentShiftTime,
    String? appVersion,
    String? avatarAssetPath,
  }) {
    return StaffSettingsProfileModel(
      staffId: staffId ?? this.staffId,
      fullName: fullName ?? this.fullName,
      staffCode: staffCode ?? this.staffCode,
      roleName: roleName ?? this.roleName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      salaryDisplay: salaryDisplay ?? this.salaryDisplay,
      currentShiftName: currentShiftName ?? this.currentShiftName,
      currentShiftTime: currentShiftTime ?? this.currentShiftTime,
      appVersion: appVersion ?? this.appVersion,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
    );
  }
}