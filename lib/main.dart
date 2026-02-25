import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnest/core/theme/app_theme.dart';
import 'package:partnest/features/auth/presentation/pages/onboarding/welcome_role_selection_page.dart';
import 'package:partnest/core/network/api_client.dart';
import 'package:partnest/features/auth/data/repositories/api_auth_repository.dart';
import 'package:partnest/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:partnest/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnest/features/auth/presentation/blocs/score_cubit/score_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            authRepository: ApiAuthRepository(apiClient: ApiClient()),
          ),
        ),
        BlocProvider<SmeProfileCubit>(
          create: (_) => SmeProfileCubit(),
        ),
        BlocProvider<ScoreCubit>(
          create: (_) => ScoreCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Partnex MVP',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const WelcomeRoleSelectionPage(),
      ),
    );
  }
}
