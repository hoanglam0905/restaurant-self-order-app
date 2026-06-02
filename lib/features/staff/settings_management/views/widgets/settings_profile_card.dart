import 'package:flutter/material.dart';

import '../../data/models/staff_settings_profile_model.dart';

class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({required this.profile, super.key});

  final StaffSettingsProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF6F1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11111827),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6E8EF)),
                  color: const Color(0xFFF0F2F7),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: profile.avatarAssetPath == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 38,
                          color: Color(0xFFA7ACB8),
                        )
                      : Image.asset(
                          profile.avatarAssetPath!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B56A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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
                  profile.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202530),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
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
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    profile.staffCode,
                    style: const TextStyle(
                      color: Color(0xFFC65A37),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.roleName,
                  style: const TextStyle(
                    color: Color(0xFF606A7C),
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
}
