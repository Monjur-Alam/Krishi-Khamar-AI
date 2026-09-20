import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/l10n.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/ui/login_page.dart';
import 'features/navigation/ui/main_shell_page.dart';
import 'features/splash/ui/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final localeCubit = LocaleCubit();
  await localeCubit.load();

  runApp(AgriVisionApp(localeCubit: localeCubit));
}

class AgriVisionApp extends StatelessWidget {
  const AgriVisionApp({super.key, required this.localeCubit});

  final LocaleCubit localeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: localeCubit,
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'AgriVisionX AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: locale,
            supportedLocales: L10n.supportedLocales,
            localizationsDelegates: const [
              L10nDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashPage(),
              '/login': (_) => const LoginPage(),
              '/main': (_) => const MainShellPage(),
            },
          );
        },
      ),
    );
  }
}
