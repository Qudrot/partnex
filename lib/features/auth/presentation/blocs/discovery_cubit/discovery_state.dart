import 'package:equatable/equatable.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<Map<String, dynamic>> smes;

  const DiscoveryLoaded({required this.smes});

  @override
  List<Object?> get props => [smes];
}

class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError(this.message);

  @override
  List<Object?> get props => [message];
}
