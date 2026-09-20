import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_bottom_nav.dart';
import '../../../data/repositories/scan_repository.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/ui/chat_page.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/ui/home_page.dart';
import '../../location/bloc/location_cubit.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/ui/profile_page.dart';
import '../../scan/bloc/scan_bloc.dart';
import '../../scan/ui/scan_page.dart';
import '../../weather/bloc/weather_bloc.dart';
import '../../weather/ui/weather_page.dart';
import '../bloc/navigation_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherRepository = WeatherRepository();
    final scanRepository = ScanRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => LocationCubit()..requestAndFetch(),
        ),
        BlocProvider(
          create: (_) => HomeBloc(
            weatherRepository: weatherRepository,
            scanRepository: scanRepository,
          )..add(const HomeStarted()),
        ),
        BlocProvider(create: (_) => ChatBloc()..add(const ChatStarted())),
        BlocProvider(
          create: (_) => ScanBloc(scanRepository: scanRepository)
            ..add(const ScanStarted()),
        ),
        BlocProvider(
          create: (_) => WeatherBloc(weatherRepository: weatherRepository)
            ..add(const WeatherStarted()),
        ),
        BlocProvider(create: (_) => ProfileBloc()..add(const ProfileStarted())),
      ],
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatelessWidget {
  const _MainShellView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationCubit, LocationState>(
          listenWhen: (previous, current) =>
              current.hasFix &&
              (previous.latitude != current.latitude ||
                  previous.longitude != current.longitude),
          listener: (context, location) {
            final lat = location.latitude!;
            final lon = location.longitude!;
            context.read<HomeBloc>().add(
                  HomeWeatherRefreshRequested(latitude: lat, longitude: lon),
                );
            context.read<WeatherBloc>().add(
                  WeatherRefreshRequested(latitude: lat, longitude: lon),
                );
          },
        ),
        BlocListener<ScanBloc, ScanState>(
          listenWhen: (previous, current) =>
              previous.phase != ScanPhase.result &&
              current.phase == ScanPhase.result,
          listener: (context, state) {
            context.read<HomeBloc>().add(const HomeRefreshScanAlert());
          },
        ),
      ],
      child: BlocBuilder<NavigationCubit, NavState>(
        builder: (context, nav) {
          return Scaffold(
            body: IndexedStack(
              index: nav.index,
              children: const [
                HomePage(),
                ChatPage(),
                ScanPage(),
                WeatherPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: AppBottomNav(
              currentIndex: nav.index,
              onTap: (i) => context.read<NavigationCubit>().setTab(i),
            ),
          );
        },
      ),
    );
  }
}
