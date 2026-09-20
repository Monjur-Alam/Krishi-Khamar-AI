import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (p, c) => c.authenticated && !p.authenticated,
      listener: (context, state) {
        Navigator.of(context).pushReplacementNamed('/main');
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 28),
                Container(
                  width: 64,
                  height: 64,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const AppSvgIcon(
                    AppIcons.leaf,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.l10n.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.tagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.welcomeBack,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.loginSubtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            context.l10n.mobileNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 14),
                                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                const Text(
                                  '+91',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  width: 1,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  color: Colors.grey.shade300,
                                ),
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: context.l10n.enterMobile,
                                      border: InputBorder.none,
                                      hintStyle: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    onChanged: (v) => context
                                        .read<LoginBloc>()
                                        .add(LoginPhoneChanged(v)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => context
                                          .read<LoginBloc>()
                                          .add(const LoginSendOtpPressed()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              context.l10n.sendOtp,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.chevron_right,
                                                size: 22),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  context.l10n.orContinueWith,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context
                                  .read<LoginBloc>()
                                  .add(const LoginGooglePressed()),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const AppSvgIcon(AppIcons.google, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    context.l10n.continueWithGoogle,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: context.l10n.newFarmer,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: context.l10n.registerNow,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: _FeatureChip(
                                  iconWidget: const AppSvgIcon(
                                    AppIcons.leaf,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  label: context.l10n.cropHealth,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FeatureChip(
                                  iconWidget: const AppSvgIcon(
                                    AppIcons.weather,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  label: context.l10n.weather,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FeatureChip(
                                  icon: Icons.bar_chart,
                                  label: context.l10n.mandiPrices,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    this.icon,
    this.iconWidget,
    required this.label,
  });
  final IconData? icon;
  final Widget? iconWidget;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget ?? Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
