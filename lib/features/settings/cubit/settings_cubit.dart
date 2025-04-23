import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_practice/features/models/share_token.dart';
import 'package:http/http.dart' as http;

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  final String deviceId = '1d116a75-16b4-442b-ab88-e361dbf9ea57';
  final String baseUrl = 'https://api.samiti.staging.gpssewa.com/api/v1';

  // Add your auth token
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImJhZ21hdGlAZ3Bzc2V3YS5jb20iLCJpZCI6OTEsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzQxNDI2MDEwLCJleHAiOjE3NDE1MTI0MTB9.bR8CJukhBg98URwphbRxpU96JmP846EfYaEb6KMbvtQ',
  };

  Future<void> fetchTokens() async {
    try {
      developer.log('Fetching tokens...', name: 'SettingsCubit');
      emit(state.copyWith(isLoading: true, error: null));

      final response = await http.get(
        Uri.parse('$baseUrl/device/$deviceId/liveShare/token'),
        headers: _headers, // Add headers to the GET request
      );

      developer.log('Fetch response status: ${response.statusCode}', name: 'SettingsCubit');
      developer.log('Fetch response body: ${response.body}', name: 'SettingsCubit');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> tokenList = data['data'];
          final tokens = tokenList.map((item) => ShareToken.fromJson(item)).toList();
          developer.log('Tokens fetched successfully: ${tokens.length} tokens', name: 'SettingsCubit');
          emit(state.copyWith(tokens: tokens, isLoading: false));
        } else {
          developer.log('Failed to fetch tokens: ${data['message']}', name: 'SettingsCubit');
          emit(state.copyWith(isLoading: false, error: data['message'] ?? 'Failed to fetch tokens'));
        }
      } else {
        developer.log('Failed to fetch tokens: ${response.statusCode}', name: 'SettingsCubit');
        emit(state.copyWith(isLoading: false, error: 'Failed to fetch tokens. Status code: ${response.statusCode}\nResponse: ${response.body}'));
      }
    } catch (e) {
      developer.log('Error fetching tokens: $e', name: 'SettingsCubit', error: e);
      emit(state.copyWith(isLoading: false, error: 'Error fetching tokens: $e'));
    }
  }

  Future<void> toggleToken(ShareToken token) async {
    try {
      developer.log('Toggling token ${token.id} from disabled=${token.disabled} to disabled=${!token.disabled}', name: 'SettingsCubit');

      // Create a temporary list to update the UI immediately
      final updatedTokens = [...state.tokens];
      final tokenIndex = updatedTokens.indexWhere((t) => t.id == token.id);

      if (tokenIndex != -1) {
        // Optimistically update UI
        updatedTokens[tokenIndex].disabled = !updatedTokens[tokenIndex].disabled;
        emit(state.copyWith(tokens: updatedTokens));

        // Make API call
        // final endpoint = token.disabled ? 'enable' : 'disable';
        final endpoint = updatedTokens[tokenIndex].disabled ? 'disable' : 'enable';
        final url = '$baseUrl/device/$deviceId/liveShare/token/${token.id}/$endpoint';

        developer.log('Making API call to: $url', name: 'SettingsCubit');
        developer.log('Request headers: $_headers', name: 'SettingsCubit');
        developer.log('Request body: {}', name: 'SettingsCubit');

        final response = await http.post(
          Uri.parse(url),
          body: '{}',
          headers: _headers, // Use the same headers for POST request
        );

        developer.log('Toggle response status: ${response.statusCode}', name: 'SettingsCubit');
        developer.log('Toggle response body: ${response.body}', name: 'SettingsCubit');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            // API call succeeded, refresh tokens to get the latest state
            developer.log('Token toggled successfully, refreshing token list', name: 'SettingsCubit');
            await fetchTokens();
          } else {
            // Revert UI change on API failure
            developer.log('API reported failure: ${data['message']}', name: 'SettingsCubit');
            updatedTokens[tokenIndex].disabled = !updatedTokens[tokenIndex].disabled;
            emit(state.copyWith(tokens: updatedTokens, error: data['message'] ?? 'Failed to update token'));
          }
        } else {
          // Revert UI change on API failure
          developer.log('API returned error status: ${response.statusCode}', name: 'SettingsCubit');
          updatedTokens[tokenIndex].disabled = !updatedTokens[tokenIndex].disabled;
          emit(state.copyWith(
              tokens: updatedTokens, error: 'Failed to update token. Status code: ${response.statusCode}\nResponse: ${response.body}'));
        }
      } else {
        developer.log('Token not found in list: ${token.id}', name: 'SettingsCubit');
      }
    } catch (e) {
      developer.log('Error toggling token: $e', name: 'SettingsCubit', error: e);
      emit(state.copyWith(error: 'Error updating token: $e'));
    }
  }
}
