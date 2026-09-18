import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../../../core/widgets/location_label.dart';
import '../../../data/models/models.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.showSettings) {
          return _SettingsView(profile: profile);
        }
        return _ProfileMainView(profile: profile);
      },
    );
  }
}

class _ProfileMainView extends StatelessWidget {
  const _ProfileMainView({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'My Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context
                              .read<ProfileBloc>()
                              .add(const ProfileShowSettings()),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white24,
                              child: AppSvgIcon(
                                AppIcons.user,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.yellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 12),
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
                                profile.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.phone,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LocationLabel(
                                fallback: profile.location,
                                compact: true,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.yellow,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified Farmer',
                                      style: TextStyle(
                                        color: AppColors.yellow,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _Stat(value: profile.farmArea, label: 'Farm Area'),
                        _Stat(value: profile.activeCrops, label: 'Crops'),
                        _Stat(value: profile.memberSince, label: 'Member Since'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.creditCardBlue,
                        Color(0xFF1565C0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.creditCardBlue.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'KISAN CREDIT CARD',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.credit_card,
                            color: Colors.amber,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '••••  ••••  ${profile.cardLast4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CREDIT LIMIT',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                profile.creditLimit,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'VALID THRU',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                profile.validThru,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.language,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: Colors.blue,
                    title: 'Language',
                    subtitle: profile.language,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'FARM DETAILS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.map_outlined,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: Colors.blue,
                    title: 'Farm Location',
                    subtitleWidget: LocationLabel(
                      fallback: profile.location,
                      compact: true,
                      iconColor: AppColors.textSecondary,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _MenuTile(
                    icon: Icons.star_outline,
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: Colors.orange,
                    title: 'Crop Profile',
                    subtitle: profile.crops,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context
                    .read<ProfileBloc>()
                    .add(const ProfileShowSettings()),
                child: const Text(
                  'More settings →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.mintSoft,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context
                      .read<ProfileBloc>()
                      .add(const ProfileShowMain()),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _SectionLabel('FARM DETAILS'),
            _MenuCard(
              children: [
                _MenuTile(
                  icon: Icons.map_outlined,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue,
                  title: 'Farm Location',
                  subtitleWidget: LocationLabel(
                    fallback: profile.location,
                    compact: true,
                    iconColor: AppColors.textSecondary,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                _MenuTile(
                  icon: Icons.star_outline,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: Colors.orange,
                  title: 'Crop Profile',
                  subtitle: profile.crops,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionLabel('PREFERENCES'),
            _MenuCard(
              children: [
                const _MenuTile(
                  iconWidget: AppSvgIcon(
                    AppIcons.bell,
                    size: 20,
                    color: Colors.purple,
                  ),
                  iconBg: Color(0xFFF3E5F5),
                  iconColor: Colors.purple,
                  title: 'Notifications',
                  subtitle: 'Enabled',
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                const _MenuTile(
                  icon: Icons.language,
                  iconBg: Color(0xFFE3F2FD),
                  iconColor: Colors.blue,
                  title: 'Language',
                  subtitle: 'English',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionLabel('SECURITY'),
            _MenuCard(
              children: [
                const _MenuTile(
                  icon: Icons.shield_outlined,
                  iconBg: Color(0xFFE8F5E9),
                  iconColor: AppColors.primary,
                  title: 'Privacy Settings',
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                const _MenuTile(
                  icon: Icons.help_outline,
                  iconBg: Color(0xFFE0F2F1),
                  iconColor: Colors.teal,
                  title: 'Help & Support',
                ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.dangerSoft,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AgriVisionX AI v1.0.0 • Made with ❤️ for Indian Farmers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    this.icon,
    this.iconWidget,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBg,
        child: iconWidget ?? Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: subtitleWidget ??
          (subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
