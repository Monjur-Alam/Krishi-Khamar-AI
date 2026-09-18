import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/app_svg_icon.dart';
import '../../../core/widgets/location_label.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../location/bloc/location_cubit.dart';
import '../bloc/weather_bloc.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.weatherBlue,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
                  child: Row(
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
                        child: Column(
                          children: [
                            Text(
                              'Weather & Advisory',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(height: 4),
                            LocationLabel(compact: true),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: AppSvgIcon(
                          AppIcons.weather,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.isLoading && state.hourly.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        final loc = context.read<LocationCubit>().state;
                        context.read<WeatherBloc>().add(
                              WeatherRefreshRequested(
                                latitude: loc.latitude ??
                                    WeatherRepository.fallbackLat,
                                longitude: loc.longitude ??
                                    WeatherRepository.fallbackLon,
                              ),
                            );
                        await context.read<WeatherBloc>().stream.firstWhere(
                              (s) => !s.isLoading,
                            );
                      },
                      child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  _Card(
                    titleIcon: Icons.agriculture,
                    title: "Today's Farming Advisory",
                    child: Column(
                      children: state.advisories
                          .map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(a.icon, color: a.color, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      a.text,
                                      style: const TextStyle(height: 1.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Card(
                    titleIcon: Icons.access_time,
                    title: 'Hourly Forecast',
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.hourly.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final h = state.hourly[i];
                          final selected = state.selectedHour == i;
                          return GestureDetector(
                            onTap: () => context
                                .read<WeatherBloc>()
                                .add(WeatherHourSelected(i)),
                            child: Container(
                              width: 64,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFE3F2FD)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    h.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: selected
                                          ? AppColors.weatherBlue
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Icon(
                                    h.icon,
                                    color: selected
                                        ? AppColors.weatherBlue
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${h.tempC}°',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: selected
                                          ? AppColors.weatherBlue
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Card(
                    titleIcon: Icons.calendar_month,
                    title: '7-Day Forecast',
                    child: Column(
                      children: [
                        for (var i = 0; i < state.weekly.length; i++) ...[
                          _DayRow(day: state.weekly[i]),
                          if (i != state.weekly.length - 1)
                            Divider(color: Colors.grey.shade200, height: 18),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.weatherBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            AppSvgIcon(
                              AppIcons.weather,
                              size: 22,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Rain Prediction',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: state.rainBars
                                .map(
                                  (b) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: FractionallySizedBox(
                                                heightFactor: b.value,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF90CAF9,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            b.label,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.titleIcon,
    required this.title,
    required this.child,
  });

  final IconData titleIcon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, color: AppColors.weatherBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});
  final DailyWeather day;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            day.day,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Icon(day.icon, color: AppColors.weatherBlue, size: 22),
        const SizedBox(width: 16),
        const Icon(Icons.water_drop, size: 14, color: AppColors.weatherBlue),
        const SizedBox(width: 4),
        Text(
          '${day.precipChance}%',
          style: const TextStyle(
            color: AppColors.weatherBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          '${day.high}°  ${day.low}°',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
