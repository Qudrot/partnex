import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partnex/core/theme/app_theme.dart';
import 'package:partnex/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:partnex/features/auth/presentation/blocs/sme_profile_cubit/sme_profile_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/score_cubit/score_cubit.dart';
import 'package:partnex/features/auth/presentation/blocs/discovery_cubit/discovery_cubit.dart';

Widget pumpApp(
  Widget widget, {
  AuthBloc? authBloc,
  SmeProfileCubit? smeProfileCubit,
  ScoreCubit? scoreCubit,
  DiscoveryCubit? discoveryCubit,
}) {
  final providers = [
    if (smeProfileCubit != null)
      BlocProvider<SmeProfileCubit>.value(value: smeProfileCubit),
    if (authBloc != null) 
      BlocProvider<AuthBloc>.value(value: authBloc),
    if (scoreCubit != null) 
      BlocProvider<ScoreCubit>.value(value: scoreCubit),
    if (discoveryCubit != null) 
      BlocProvider<DiscoveryCubit>.value(value: discoveryCubit),
  ];

  final app = MaterialApp(
    title: 'Partnex Test',
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    home: widget,
  );

  if (providers.isEmpty) {
    return app;
  }

  return MultiBlocProvider(
    providers: providers,
    child: app,
  );
}
