import 'package:flutter/material.dart';

import '../data/models/staff_settings_profile_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({required this.profile, super.key});

  final StaffSettingsProfileModel profile;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _addressController = TextEditingController(text: widget.profile.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã lưu thông tin hồ sơ. Bạn có thể nối API cập nhật tại đây.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1E2533)),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: Color(0xFF1E2533),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            _buildProfileBanner(),
            const SizedBox(height: 14),
            _buildReadOnlyMeta(),
            const SizedBox(height: 14),
            _buildFormCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC96541), Color(0xFFB84D2D)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB84D2D).withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Lưu thay đổi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10111827),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E5EF)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.profile.avatarAssetPath == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: Color(0xFFA4ACBA),
                        )
                      : Image.asset(
                          widget.profile.avatarAssetPath!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                right: -3,
                bottom: -3,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bạn có thể tích hợp API upload ảnh tại nút này.',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB84D2D),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F2533),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.profile.staffCode,
                    style: const TextStyle(
                      color: Color(0xFFC65A37),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.profile.roleName,
                  style: const TextStyle(
                    color: Color(0xFF616A7C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyMeta() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.badge_outlined,
            label: 'Mã nhân viên',
            value: widget.profile.staffCode,
          ),
          const Divider(height: 20, color: Color(0xFFF0F2F7)),
          _MetaRow(
            icon: Icons.work_outline_rounded,
            label: 'Vai trò',
            value: widget.profile.roleName,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileTextField(
            label: 'Họ và tên',
            hint: 'Nhập họ và tên',
            icon: Icons.person_outline_rounded,
            controller: _nameController,
            validator: _requiredValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _ProfileTextField(
            label: 'Email liên hệ',
            hint: 'Nhập email',
            icon: Icons.alternate_email_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _requiredValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _ProfileTextField(
            label: 'Số điện thoại',
            hint: 'Nhập số điện thoại',
            icon: Icons.phone_rounded,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: _requiredValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _ProfileTextField(
            label: 'Địa chỉ thường trú',
            hint: 'Nhập địa chỉ',
            icon: Icons.location_on_outlined,
            controller: _addressController,
            maxLines: 2,
            validator: _requiredValidator,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng không để trống thông tin này.';
    }
    return null;
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E7788),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          textInputAction: textInputAction,
          style: const TextStyle(
            color: Color(0xFF232A39),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFA2AABC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFFB84D2D)),
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(fontSize: 11, height: 1.1),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFB84D2D), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF95A0B1),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2B3342),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
