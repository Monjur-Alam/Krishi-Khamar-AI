import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../../../core/widgets/location_label.dart';
import '../../../data/models/models.dart';
import '../../location/bloc/location_cubit.dart';
import '../../navigation/bloc/navigation_cubit.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return _HomeContent(data: state);
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});
  final HomeLoaded data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(data: data)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                l10n.quickActions,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              _QuickActions(
                onChat: () => context.read<NavigationCubit>().setTab(1),
                onScan: () => context.read<NavigationCubit>().setTab(2),
                onWeather: () => context.read<NavigationCubit>().setTab(3),
              ),
              const SizedBox(height: 18),
              _WeatherCard(
                weather: data.weather,
                isLoading: data.weatherLoading,
                onForecast: () => context.read<NavigationCubit>().setTab(3),
              ),
              const SizedBox(height: 14),
              _MandiCard(prices: data.mandiPrices),
              const SizedBox(height: 14),
              _KisanBotCard(
                alert: data.kisanBotAlert,
                onTap: () => context.read<NavigationCubit>().setTab(1),
              ),
              const SizedBox(height: 14),
              _DiseaseCard(
                alert: data.latestAlert,
                onTap: () => context.read<NavigationCubit>().setTab(2),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    l10n.myCrops,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.viewAll,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              ...data.crops.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CropTile(crop: c),
                  )),
              const SizedBox(height: 6),
              const _SchemesCard(),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data});
  final HomeLoaded data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.goodMorning,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LocationLabel(fallback: data.location),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      _CircleSvgIcon(AppIcons.bell),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.read<NavigationCubit>().setTab(4),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: AppSvgIcon(
                        AppIcons.user,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _WeatherChip(
                    icon: Icons.thermostat,
                    text: '${data.weather.tempC}°C',
                  ),
                  _divider(),
                  _WeatherChip(
                    icon: Icons.water_drop_outlined,
                    text: '${data.weather.humidity}% ${l10n.humidity}',
                  ),
                  _divider(),
                  _WeatherChip(
                    icon: Icons.cloud_outlined,
                    text: data.weather.rainChance >= 40
                        ? l10n.rainLikely
                        : data.weather.condition,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 14,
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: Colors.white38,
      );
}

class _CircleSvgIcon extends StatelessWidget {
  const _CircleSvgIcon(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white38),
      ),
      child: AppSvgIcon(asset, size: 20, color: Colors.white),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onChat,
    required this.onScan,
    required this.onWeather,
  });

  final VoidCallback onChat;
  final VoidCallback onScan;
  final VoidCallback onWeather;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: l10n.aiChat,
            iconWidget: const AppSvgIcon(
              AppIcons.chat,
              size: 26,
              color: Color(0xFF1565C0),
            ),
            bg: const Color(0xFFE3F2FD),
            fg: const Color(0xFF1565C0),
            onTap: onChat,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            label: l10n.diseaseDetect,
            iconWidget: const AppSvgIcon(
              AppIcons.leaf,
              size: 26,
              color: AppColors.primary,
            ),
            bg: const Color(0xFFE8F5E9),
            fg: AppColors.primary,
            onTap: onScan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            label: l10n.mandiPrices,
            icon: Icons.trending_up,
            bg: const Color(0xFFFFF3E0),
            fg: const Color(0xFFEF6C00),
            onTap: onWeather,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            label: l10n.schemes,
            icon: Icons.description_outlined,
            bg: const Color(0xFFF3E5F5),
            fg: const Color(0xFF6A1B9A),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    this.icon,
    this.iconWidget,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            iconWidget ?? Icon(icon, color: fg, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.weather,
    required this.onForecast,
    this.isLoading = false,
  });
  final WeatherInfo weather;
  final VoidCallback onForecast;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.weatherBlue, AppColors.weatherBlueDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todaysWeather,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${weather.tempC}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            weather.condition,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${weather.rainNote} • ${weather.rainChance}% chance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const AppSvgIcon(
                AppIcons.weather,
                size: 56,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric(Icons.water_drop, '${weather.humidity}%', l10n.humidity),
              _metric(Icons.air, '${weather.windKmh}km/h', l10n.wind),
              _metric(
                  Icons.wb_sunny, 'UV ${weather.uvIndex}', l10n.uvIndex),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onForecast,
            child: Text(
              l10n.view7DayForecast,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MandiCard extends StatelessWidget {
  const _MandiCard({required this.prices});
  final List<MandiPrice> prices;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFFEF6C00), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.mandiPrices,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              BlocBuilder<LocationCubit, LocationState>(
                builder: (context, loc) {
                  return Text(
                    '${l10n.live} • ${loc.city ?? l10n.yourArea}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prices.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(p.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    p.price,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${p.isUp ? '+' : ''}${p.changePercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: p.isUp ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KisanBotCard extends StatelessWidget {
  const _KisanBotCard({required this.alert, required this.onTap});
  final String alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.kisanBotAi,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.live.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"$alert"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.askFarming,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard({required this.onTap, this.alert});
  final VoidCallback onTap;
  final CropScan? alert;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasAlert = alert != null && alert!.risk != ScanRisk.healthy;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const AppSvgIcon(
                    AppIcons.leaf,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cropDiseaseDetection,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.scanCropsWithAi,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasAlert ? AppColors.dangerSoft : AppColors.successSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                hasAlert
                    ? l10n.alertDetected(alert!.crop, alert!.diagnosis)
                    : l10n.noActiveDiseaseAlerts,
                style: TextStyle(
                  color: hasAlert ? AppColors.danger : AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropTile extends StatelessWidget {
  const _CropTile({required this.crop});
  final CropItem crop;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (crop.status) {
      CropStatus.healthy => (AppColors.successSoft, AppColors.success),
      CropStatus.monitor => (AppColors.warningSoft, AppColors.warning),
      CropStatus.alert => (AppColors.dangerSoft, AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(crop.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              crop.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              switch (crop.status) {
                CropStatus.healthy => context.l10n.healthy,
                _ => crop.statusLabel,
              },
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchemesCard extends StatelessWidget {
  const _SchemesCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.governmentSchemes,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.schemesAvailable,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}
