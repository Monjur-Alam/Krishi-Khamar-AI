import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_cubit.dart';
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
        return _ProfileMainView(profile: profile);
      },
    );
  }
}

Future<void> _showLanguageSheet(BuildContext context) async {
  final l10n = context.l10n;
  final cubit = context.read<LocaleCubit>();
  final current = cubit.state.languageCode;

  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.chooseLanguage,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _LanguageOption(
                label: l10n.english,
                selected: current == 'en',
                onTap: () {
                  cubit.setLocale(const Locale('en'));
                  Navigator.pop(sheetContext);
                },
              ),
              _LanguageOption(
                label: l10n.bangla,
                selected: current == 'bn',
                onTap: () {
                  cubit.setLocale(const Locale('bn'));
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _ProfileMainView extends StatelessWidget {
  const _ProfileMainView({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageLabel = context.watch<LocaleCubit>().languageLabel;

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
                        Expanded(
                          child: Text(
                            l10n.myProfile,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.yellow,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.verifiedFarmer,
                                      style: const TextStyle(
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
                        _Stat(
                          value: profile.farmArea,
                          label: l10n.farmArea,
                        ),
                        _Stat(
                          value: profile.activeCrops,
                          label: l10n.crops,
                        ),
                        _Stat(
                          value: profile.memberSince,
                          label: l10n.memberSince,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _CreditCard(profile: profile),
              const SizedBox(height: 16),
              _SectionLabel(l10n.farmDetails),
              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.map_outlined,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: Colors.blue,
                    title: l10n.farmLocation,
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
                    title: l10n.cropProfile,
                    subtitle: profile.crops,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionLabel(l10n.preferences),
              _MenuCard(
                children: [
                  _MenuTile(
                    iconWidget: const AppSvgIcon(
                      AppIcons.bell,
                      size: 20,
                      color: Colors.purple,
                    ),
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: Colors.purple,
                    title: l10n.notifications,
                    subtitle: l10n.enabled,
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _MenuTile(
                    icon: Icons.language,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: Colors.blue,
                    title: l10n.language,
                    subtitle: languageLabel,
                    onTap: () => _showLanguageSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionLabel(l10n.security),
              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.shield_outlined,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: AppColors.primary,
                    title: l10n.privacySettings,
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _MenuTile(
                    icon: Icons.help_outline,
                    iconBg: const Color(0xFFE0F2F1),
                    iconColor: Colors.teal,
                    title: l10n.helpSupport,
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
                label: Text(
                  l10n.logout,
                  style: const TextStyle(
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
              Text(
                l10n.madeWithLove,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
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
                l10n.kisanCreditCard,
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
                    l10n.creditLimit,
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
                    l10n.validThru,
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
    this.onTap,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final VoidCallback? onTap;

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
      onTap: onTap ?? () {},
    );
  }
}
