import 'package:equatable/equatable.dart';
import 'package:flutter_practice/features/models/share_token.dart';

class SettingsState extends Equatable {
  final List<ShareToken> tokens;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.tokens = const [],
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    List<ShareToken>? tokens,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      tokens: tokens ?? this.tokens,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [tokens, isLoading, error];
}
