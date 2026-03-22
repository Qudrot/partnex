import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_theme.dart';
import 'package:partnex/features/auth/presentation/pages/splash_page.dart';
import 'package:partnex/core/network/api_client.dart';
import 'package:partnex/features/auth/data/repositories/api_auth_repository.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:partnex/features/auth/presentation/blocs/theme_cubit/theme_cubit.dart';
import 'package:partnex/core/services/ui_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SmeProfileCubit>(
          create: (_) => SmeProfileCubit(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: ApiAuthRepository(apiClient: ApiClient()),
            smeProfileCubit: context.read<SmeProfileCubit>(),
          ),
        ),
        BlocProvider<ScoreCubit>(
          create: (context) => ScoreCubit(
            authRepository: context.read<AuthBloc>().authRepository,
            smeProfileCubit: context.read<SmeProfileCubit>(),
          ),
        ),
        BlocProvider<DiscoveryCubit>(
          create: (context) => DiscoveryCubit(
            authRepository: context.read<AuthBloc>().authRepository,
          ),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.read<SmeProfileCubit>().reset();
            context.read<DiscoveryCubit>().reset();
            context.read<ScoreCubit>().reset();
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Partnex',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              navigatorKey: uiService.navigatorKey,
              scaffoldMessengerKey: uiService.scaffoldMessengerKey,
              debugShowCheckedModeBanner: false,
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}
