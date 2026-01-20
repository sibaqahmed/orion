import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';

class AccountSheet extends StatelessWidget {
  const AccountSheet({
    super.key,
    required this.onOpenSettings,
    required this.onHelp,
    required this.onAbout,
    required this.onLogout,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final Future<void> Function() onLogout;

  String _displayName(User? u) {
    final name = (u?.displayName ?? "").trim();
    if (name.isNotEmpty) return name;

    final email = (u?.email ?? "").trim();
    if (email.isNotEmpty) {
      final part = email.split("@").first;
      if (part.isNotEmpty) return part;
    }
    return "User";
  }

  String _initials(User? u) {
    final name = _displayName(u).trim();
    if (name.isEmpty) return "U";

    final parts = name.split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(
            top: BorderSide(color: AppColors.accent.withOpacity(0.18)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),

            // ✅ Profile header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  children: [
                    _AvatarCircle(
                      photoUrl: user?.photoURL,
                      fallbackText: _initials(user),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName(user),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (user?.email ?? "No email"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.9),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ✅ Plan tag (local display — you can later make it dynamic)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.28),
                                ),
                              ),
                              child: const Text(
                                "Plan: Orion (Beta)",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Actions
            _SheetTile(
              icon: Icons.settings_rounded,
              title: "Settings",
              subtitle: "Voice, preferences",
              onTap: onOpenSettings,
            ),
            _SheetTile(
              icon: Icons.help_outline_rounded,
              title: "Help",
              subtitle: "FAQs, contact",
              onTap: onHelp,
            ),
            _SheetTile(
              icon: Icons.info_outline_rounded,
              title: "About",
              subtitle: "Version, credits",
              onTap: onAbout,
            ),

            const SizedBox(height: 6),

            // ✅ Logout (special)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  await onLogout();
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A5F).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFF5A5F).withOpacity(0.30),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Color(0xFFFF5A5F), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Color(0xFFFF5A5F),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFFF5A5F)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.10),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.9),
                        fontSize: 12.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withOpacity(0.8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.photoUrl,
    required this.fallbackText,
  });

  final String? photoUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoUrl ?? "").trim().isNotEmpty;

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withOpacity(0.18),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
        image: hasPhoto
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? const SizedBox.shrink()
          : Text(
        fallbackText,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
