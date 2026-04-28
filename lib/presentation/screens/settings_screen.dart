// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import '../../core/constants/app_constants.dart';
// import '../../core/theme/app_theme.dart';
// import '../../data/models/instance_model.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/theme_controller.dart';
// import 'login_screen.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     final themeCtrl = Get.find<ThemeController>();

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           const SliverAppBar(
//             floating: true,
//             snap: true,
//             title: Text('Settings'),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.all(20),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 _buildSection(context, 'Instance Management', [
//                   Obx(() => _InstancesList(
//                         instances: auth.instances,
//                         activeId: auth.activeInstance.value?.id,
//                         onSwitch: auth.switchInstance,
//                         onDelete: (id) => _confirmDelete(context, auth, id),
//                       )),
//                   const SizedBox(height: 12),
//                   OutlinedButton.icon(
//                     onPressed: () => _showAddInstanceSheet(context),
//                     icon: const Icon(Icons.add_rounded, size: 18),
//                     label: const Text('Add Instance'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppTheme.primaryColor,
//                       side: const BorderSide(color: AppTheme.primaryColor),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 20),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                   ),
//                 ]),
//                 const SizedBox(height: 20),
//                 _buildSection(context, 'Appearance', [
//                   Obx(() => _ToggleTile(
//                         title: 'Dark Mode',
//                         subtitle: 'Use dark theme throughout the app',
//                         icon: Icons.dark_mode_rounded,
//                         value: themeCtrl.isDarkMode.value,
//                         onChanged: (_) => themeCtrl.toggleTheme(),
//                       )),
//                 ]),
//                 const SizedBox(height: 20),
//                 _buildSection(context, 'About', [
//                   const _InfoTile(
//                     title: 'App Version',
//                     subtitle: AppConstants.appVersion,
//                     icon: Icons.info_outline_rounded,
//                   ),
//                 ]),
//                 const SizedBox(height: 20),
//                 _buildSection(context, 'Account', [
//                   Obx(() {
//                     if (auth.activeInstance.value == null) {
//                       return const SizedBox.shrink();
//                     }
//                     return _DangerTile(
//                       title: 'Logout',
//                       subtitle: 'Disconnect from current instance',
//                       icon: Icons.logout_rounded,
//                       onTap: () => _confirmLogout(context, auth),
//                     );
//                   }),
//                 ]),
//                 const SizedBox(height: 80),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection(
//       BuildContext context, String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title.toUpperCase(),
//           style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                 letterSpacing: 1.2,
//                 fontWeight: FontWeight.w700,
//               ),
//         ),
//         const SizedBox(height: 10),
//         Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? AppTheme.darkBorder
//                   : AppTheme.lightBorder,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(children: children),
//           ),
//         ),
//       ],
//     ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
//   }

//   void _showAddInstanceSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).cardColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(ctx).viewInsets.bottom,
//         ),
//         child: const SizedBox(
//           height: 600,
//           child: AddInstanceScreen(),
//         ),
//       ),
//     );
//   }

//   void _confirmDelete(BuildContext context, AuthController auth, String id) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: Theme.of(context).cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Remove Instance'),
//         content: const Text('Are you sure you want to remove this instance?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               auth.removeInstance(id);
//             },
//             child: const Text('Remove',
//                 style: TextStyle(color: AppTheme.errorColor)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmLogout(BuildContext context, AuthController auth) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: Theme.of(context).cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Logout'),
//         content: const Text('Disconnect from the current instance?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               auth.logout();
//             },
//             child: const Text('Logout',
//                 style: TextStyle(color: AppTheme.errorColor)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InstancesList extends StatelessWidget {
//   final List<N8nInstance> instances;
//   final String? activeId;
//   final Function(N8nInstance) onSwitch;
//   final Function(String) onDelete;

//   const _InstancesList({
//     required this.instances,
//     this.activeId,
//     required this.onSwitch,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (instances.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Text(
//           'No instances added',
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       );
//     }

//     return Column(
//       children: instances
//           .map((inst) => _InstanceTile(
//                 instance: inst,
//                 isActive: inst.id == activeId,
//                 onSwitch: () => onSwitch(inst),
//                 onDelete: () => onDelete(inst.id),
//               ))
//           .toList(),
//     );
//   }
// }

// class _InstanceTile extends StatelessWidget {
//   final N8nInstance instance;
//   final bool isActive;
//   final VoidCallback onSwitch;
//   final VoidCallback onDelete;

//   const _InstanceTile({
//     required this.instance,
//     required this.isActive,
//     required this.onSwitch,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isActive
//             ? AppTheme.primaryColor.withValues(alpha: 0.1)
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isActive
//               ? AppTheme.primaryColor.withValues(alpha: 0.3)
//               : AppTheme.darkBorder,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: isActive
//                   ? AppTheme.primaryColor.withValues(alpha: 0.2)
//                   : AppTheme.darkBorder.withValues(alpha: 0.3),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               Icons.hub_rounded,
//               size: 18,
//               color: isActive ? AppTheme.primaryColor : AppTheme.darkTextMuted,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       instance.name,
//                       style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                             fontWeight: FontWeight.w700,
//                             color: Theme.of(context).textTheme.bodyLarge?.color,
//                           ),
//                     ),
//                     if (isActive) ...[
//                       const SizedBox(width: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primaryColor,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Text(
//                           'ACTIVE',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 9,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//                 Text(
//                   instance.baseUrl,
//                   style: Theme.of(context).textTheme.labelSmall,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           if (!isActive)
//             TextButton(
//               onPressed: onSwitch,
//               style: TextButton.styleFrom(
//                 foregroundColor: AppTheme.primaryColor,
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//               ),
//               child: const Text('Switch', style: TextStyle(fontSize: 12)),
//             ),
//           IconButton(
//             icon: const Icon(Icons.delete_outline_rounded, size: 18),
//             color: AppTheme.errorColor,
//             onPressed: onDelete,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ToggleTile extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final bool value;
//   final ValueChanged<bool> onChanged;

//   const _ToggleTile({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppTheme.primaryColor.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, size: 18, color: AppTheme.primaryColor),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title,
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).textTheme.bodyLarge?.color)),
//               Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
//             ],
//           ),
//         ),
//         Switch(value: value, onChanged: onChanged),
//       ],
//     );
//   }
// }

// class _InfoTile extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;

//   const _InfoTile({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppTheme.accentColor.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 18, color: AppTheme.accentColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: Theme.of(context).textTheme.bodyLarge?.color)),
//                 Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DangerTile extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _DangerTile({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppTheme.errorColor.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 18, color: AppTheme.errorColor),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: AppTheme.errorColor)),
//                 Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right_rounded, color: AppTheme.errorColor),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/instance_model.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final themeCtrl = Get.find<ThemeController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Settings'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Instance Management ──────────────────────────────────
                _buildSection(context, 'Instance Management', [
                  Obx(
                    () => _InstancesList(
                      instances: auth.instances,
                      activeId: auth.activeInstance.value?.id,
                      onSwitch: auth.switchInstance,
                      onDelete: (id) => _confirmDelete(context, auth, id),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showAddInstanceSheet(context);
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Instance'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Appearance ───────────────────────────────────────────
                _buildSection(context, 'Appearance', [
                  Obx(
                    () => _ToggleTile(
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme throughout the app',
                      icon: themeCtrl.isDarkMode.value
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      iconColor: themeCtrl.isDarkMode.value
                          ? AppTheme.primaryColor
                          : Colors.orange,
                      value: themeCtrl.isDarkMode.value,
                      onChanged: (_) => themeCtrl.toggleTheme(),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Support ──────────────────────────────────────────────
                _buildSection(context, 'Support', [
                  _ActionTile(
                    title: 'Rate the App',
                    subtitle: 'Enjoying it? Leave us a review!',
                    icon: Icons.star_rounded,
                    iconColor: AppTheme.warningColor,
                    onTap: _rateApp,
                  ),
                  _TileDivider(),
                  _ActionTile(
                    title: 'Share App',
                    subtitle: 'Tell your friends about n8n Manager',
                    icon: Icons.share_rounded,
                    iconColor: AppTheme.primaryColor,
                    onTap: _shareApp,
                  ),
                  _TileDivider(),
                  _ActionTile(
                    title: 'Contact Support',
                    subtitle: 'Get help or report an issue',
                    icon: Icons.mail_outline_rounded,
                    iconColor: AppTheme.successColor,
                    onTap: _contactSupport,
                  ),
                ]),
                const SizedBox(height: 20),

                // ── About ────────────────────────────────────────────────
                _buildSection(context, 'About', [
                  _InfoTile(
                    title: 'App Version',
                    subtitle: _version.isEmpty
                        ? 'Loading...'
                        : 'v$_version (build $_buildNumber)',
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.accentColor,
                    trailing: _version.isEmpty
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentColor,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: 'v$_version+$_buildNumber'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Version copied!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: AppTheme.darkTextMuted,
                            ),
                          ),
                  ),
                  _TileDivider(),
                  const _InfoTile(
                    title: 'Developer',
                    subtitle: 'Not affiliated with n8n GmbH',
                    icon: Icons.code_rounded,
                    iconColor: AppTheme.primaryColor,
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Account ──────────────────────────────────────────────
                Obx(() {
                  if (auth.activeInstance.value == null) {
                    return const SizedBox.shrink();
                  }
                  return _buildSection(context, 'Account', [
                    _DangerTile(
                      title: 'Logout',
                      subtitle: 'Disconnect from current instance',
                      icon: Icons.logout_rounded,
                      onTap: () => _confirmLogout(context, auth),
                    ),
                  ]);
                }),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section builder ────────────────────────────────────────────────────────
  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppTheme.darkTextSecondary : Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Feature actions ────────────────────────────────────────────────────────
  Future<void> _rateApp() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.andsayem.n8n';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out n8n Manager — manage your n8n automation workflows right from your phone!\n\nhttps://play.google.com/store/apps/details?id=com.andsayem.n8n',
        subject: 'n8n Manager App',
      ),
    );
  }

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'andsayem@gmail.com',
      queryParameters: {
        'subject': 'n8n Manager Support',
        'body': 'App Version: v$_version\n\nDescribe your issue:\n',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("No email app found");
    }
  }

  void _showAddInstanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const SizedBox(height: 620, child: AddInstanceScreen()),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthController auth, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Instance'),
        content: const Text('Are you sure you want to remove this instance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.removeInstance(id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Disconnect from the current instance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INSTANCES LIST
// ══════════════════════════════════════════════════════════════════════════════
class _InstancesList extends StatelessWidget {
  final List<N8nInstance> instances;
  final String? activeId;
  final Function(N8nInstance) onSwitch;
  final Function(String) onDelete;

  const _InstancesList({
    required this.instances,
    this.activeId,
    required this.onSwitch,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (instances.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No instances added yet.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Column(
      children: instances
          .map(
            (inst) => _InstanceTile(
              instance: inst,
              isActive: inst.id == activeId,
              onSwitch: () => onSwitch(inst),
              onDelete: () => onDelete(inst.id),
            ),
          )
          .toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INSTANCE TILE
// ══════════════════════════════════════════════════════════════════════════════
class _InstanceTile extends StatelessWidget {
  final N8nInstance instance;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onDelete;

  const _InstanceTile({
    required this.instance,
    required this.isActive,
    required this.onSwitch,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.primaryColor.withValues(alpha: 0.4)
              : borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.2)
                  : (isDark
                      ? AppTheme.darkBorder.withValues(alpha: 0.4)
                      : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.hub_rounded,
              size: 18,
              color: isActive
                  ? AppTheme.primaryColor
                  : (isDark ? AppTheme.darkTextMuted : Colors.grey.shade500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        instance.name,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.vpn_key_rounded,
                        size: 9,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'API Key',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  instance.baseUrl,
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isActive)
            TextButton(
              onPressed: onSwitch,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Switch', style: TextStyle(fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppTheme.errorColor,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE TILES
// ══════════════════════════════════════════════════════════════════════════════
class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark ? AppTheme.darkTextMuted : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}

class _DangerTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DangerTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppTheme.errorColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.errorColor),
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
    );
  }
}
