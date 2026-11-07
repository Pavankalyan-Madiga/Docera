import 'package:flutter/material.dart';

import '../../models/settings_item_model.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool notifications = true;
  bool biometricLock = false;

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title will be available soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'Docera',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Docera',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE3EFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.description_rounded,
          color: Color(0xFF146CE8),
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFF8F9FD),
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                10,
              ),
              child: const SettingsHeader(),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      30,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          SettingsSection(
                            title: 'Account',
                            items: [
                              SettingsItemModel(
                                title: 'Profile',
                                subtitle: 'Manage your profile',
                                icon: Icons.person_outline_rounded,
                                iconColor: const Color(0xFF146CE8),
                                backgroundColor: const Color(0xFFE8F0FF),
                                onTap: () => _showComingSoon('Profile'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SettingsSection(
                            title: 'Appearance',
                            items: [
                              SettingsItemModel(
                                title: 'Dark Mode',
                                subtitle: 'Use dark appearance',
                                icon: Icons.dark_mode_outlined,
                                iconColor: const Color(0xFF7257C7),
                                backgroundColor: const Color(0xFFF0EBFF),
                                showSwitch: true,
                                value: darkMode,
                                onChanged: (value) {
                                  setState(() {
                                    darkMode = value;
                                  });
                                },
                              ),
                              SettingsItemModel(
                                title: 'Notifications',
                                subtitle: 'Receive app notifications',
                                icon: Icons.notifications_none_rounded,
                                iconColor: const Color(0xFFED8A20),
                                backgroundColor: const Color(0xFFFFF1DF),
                                showSwitch: true,
                                value: notifications,
                                onChanged: (value) {
                                  setState(() {
                                    notifications = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SettingsSection(
                            title: 'Storage',
                            items: [
                              SettingsItemModel(
                                title: 'Default Folder',
                                subtitle: 'Choose where files are saved',
                                icon: Icons.folder_outlined,
                                iconColor: const Color(0xFF3B8EEA),
                                backgroundColor: const Color(0xFFE8F2FF),
                                onTap: () =>
                                    _showComingSoon('Default Folder'),
                              ),
                              SettingsItemModel(
                                title: 'Clear Cache',
                                subtitle: 'Free up temporary storage',
                                icon: Icons.cleaning_services_outlined,
                                iconColor: const Color(0xFF2FA56B),
                                backgroundColor: const Color(0xFFE8F8F0),
                                onTap: () =>
                                    _showComingSoon('Clear Cache'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SettingsSection(
                            title: 'PDF & Documents',
                            items: [
                              SettingsItemModel(
                                title: 'Default PDF Viewer',
                                subtitle: 'Choose your preferred viewer',
                                icon: Icons.picture_as_pdf_outlined,
                                iconColor: const Color(0xFFE5484D),
                                backgroundColor: const Color(0xFFFFE9EA),
                                onTap: () =>
                                    _showComingSoon('Default PDF Viewer'),
                              ),
                              SettingsItemModel(
                                title: 'Export Quality',
                                subtitle: 'Choose document export quality',
                                icon: Icons.high_quality_outlined,
                                iconColor: const Color(0xFF8B63D9),
                                backgroundColor: const Color(0xFFF1EBFF),
                                onTap: () =>
                                    _showComingSoon('Export Quality'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SettingsSection(
                            title: 'Security',
                            items: [
                              SettingsItemModel(
                                title: 'App Lock',
                                subtitle: 'Protect Docera with a lock',
                                icon: Icons.lock_outline_rounded,
                                iconColor: const Color(0xFF4B6CB7),
                                backgroundColor: const Color(0xFFEAF0FF),
                                onTap: () =>
                                    _showComingSoon('App Lock'),
                              ),
                              SettingsItemModel(
                                title: 'Biometric Lock',
                                subtitle: 'Use fingerprint or face unlock',
                                icon: Icons.fingerprint_rounded,
                                iconColor: const Color(0xFF167D9A),
                                backgroundColor: const Color(0xFFE5F7FA),
                                showSwitch: true,
                                value: biometricLock,
                                onChanged: (value) {
                                  setState(() {
                                    biometricLock = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SettingsSection(
                            title: 'About',
                            items: [
                              SettingsItemModel(
                                title: 'Rate Docera',
                                subtitle: 'Share your feedback',
                                icon: Icons.star_outline_rounded,
                                iconColor: const Color(0xFFE3A31C),
                                backgroundColor: const Color(0xFFFFF5D9),
                                onTap: () => _showComingSoon('Rate Docera'),
                              ),
                              SettingsItemModel(
                                title: 'About Docera',
                                subtitle: 'Version 1.0.0',
                                icon: Icons.info_outline_rounded,
                                iconColor: const Color(0xFF146CE8),
                                backgroundColor: const Color(0xFFE8F0FF),
                                onTap: _showAppInfo,
                              ),
                              SettingsItemModel(
                                title: 'Privacy Policy',
                                subtitle: 'Read our privacy policy',
                                icon: Icons.privacy_tip_outlined,
                                iconColor: const Color(0xFF3E8B63),
                                backgroundColor: const Color(0xFFE9F7EF),
                                onTap: () =>
                                    _showComingSoon('Privacy Policy'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  'Docera',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF737B8C),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF9AA1AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}