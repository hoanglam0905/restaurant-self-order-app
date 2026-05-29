import 'package:flutter/material.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUpperCase =>
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);
  bool get _hasLowerCase =>
      RegExp(r'[a-z]').hasMatch(_newPasswordController.text);
  bool get _hasDigitOrSpecial => RegExp(
    r'[0-9!@#$%^&*(),.?":{}|<>]',
  ).hasMatch(_newPasswordController.text);

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    if (!_hasMinLength ||
        !_hasUpperCase ||
        !_hasLowerCase ||
        !_hasDigitOrSpecial) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu mới chưa đáp ứng đủ điều kiện bảo mật.'),
        ),
      );
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu mới phải khác mật khẩu hiện tại.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đổi mật khẩu thành công. Bạn có thể nối API đổi mật khẩu tại đây.',
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
        iconTheme: const IconThemeData(color: Color(0xFF1F2533)),
        title: const Text(
          'Bảo mật & Mật khẩu',
          style: TextStyle(
            color: Color(0xFF1F2533),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            _buildSecurityBanner(),
            const SizedBox(height: 14),
            _buildPasswordCard(),
            const SizedBox(height: 14),
            _buildRuleCard(),
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
                    color: const Color(0xFFB84D2D).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Đổi mật khẩu',
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

  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7F2), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E2D9)),
      ),
      child: const Row(
        children: [
          _SecurityIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bảo vệ tài khoản của bạn',
                  style: TextStyle(
                    color: Color(0xFF1F2533),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Nên đổi mật khẩu định kỳ để tăng mức độ an toàn.',
                  style: TextStyle(
                    color: Color(0xFF707A8D),
                    fontSize: 12,
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

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: Column(
        children: [
          _PasswordField(
            label: 'Mật khẩu hiện tại',
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            onToggleObscure: () {
              setState(() {
                _obscureCurrent = !_obscureCurrent;
              });
            },
            validator: _requiredValidator,
          ),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Mật khẩu mới',
            controller: _newPasswordController,
            obscureText: _obscureNew,
            onChanged: (_) => setState(() {}),
            onToggleObscure: () {
              setState(() {
                _obscureNew = !_obscureNew;
              });
            },
            validator: _requiredValidator,
          ),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Xác nhận mật khẩu mới',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            onToggleObscure: () {
              setState(() {
                _obscureConfirm = !_obscureConfirm;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập xác nhận mật khẩu.';
              }
              if (value != _newPasswordController.text) {
                return 'Mật khẩu xác nhận chưa khớp.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điều kiện mật khẩu',
            style: TextStyle(
              color: Color(0xFF262E3D),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _RuleItem(label: 'Ít nhất 8 ký tự', matched: _hasMinLength),
          _RuleItem(label: 'Ít nhất 1 chữ in hoa', matched: _hasUpperCase),
          _RuleItem(label: 'Ít nhất 1 chữ thường', matched: _hasLowerCase),
          _RuleItem(
            label: 'Ít nhất 1 số hoặc ký tự đặc biệt',
            matched: _hasDigitOrSpecial,
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập thông tin bắt buộc.';
    }
    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleObscure,
    required this.validator,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final String? Function(String?) validator;
  final ValueChanged<String>? onChanged;

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
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            color: Color(0xFF232A39),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFB84D2D),
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF8D96A8),
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            hintText: 'Nhập mật khẩu',
            hintStyle: const TextStyle(
              color: Color(0xFFA2AABC),
              fontWeight: FontWeight.w600,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
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

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.label, required this.matched});

  final String label;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            matched
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 17,
            color: matched ? const Color(0xFF0F8B54) : const Color(0xFFA0A8B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: matched
                    ? const Color(0xFF1F8F5D)
                    : const Color(0xFF6F7788),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityIcon extends StatelessWidget {
  const _SecurityIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBDD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.shield_moon_rounded,
        color: Color(0xFFB84D2D),
        size: 22,
      ),
    );
  }
}
