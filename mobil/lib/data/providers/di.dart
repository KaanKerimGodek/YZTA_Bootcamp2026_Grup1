import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/mock_savings_repository.dart';
import '../repositories/remote_savings_repository.dart';
import '../repositories/savings_repository.dart';
import '../services/api_client.dart';
import '../services/mock_data_service.dart';
import '../services/n8n_webhook_service.dart';

// ---------------------------------------------------------------------------
// Service-layer providers
// ---------------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final mockServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});

final n8nWebhookServiceProvider = Provider<N8nWebhookService>((ref) {
  return N8nWebhookService(
    client: ref.watch(apiClientProvider),
    webhookUrl: AppConfig.n8nWebhookUrl,
  );
});

// ---------------------------------------------------------------------------
// Repository provider — mode'a göre mock ya da remote döner
// ---------------------------------------------------------------------------

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  if (AppConfig.isMock) {
    return MockSavingsRepository(
      ref.watch(mockServiceProvider),
      AppConfig.userId,
    );
  }
  return RemoteSavingsRepository(
    webhookService: ref.watch(n8nWebhookServiceProvider),
    client: ref.watch(apiClientProvider),
    supabaseUrl: AppConfig.supabaseUrl,
    supabaseAnonKey: AppConfig.supabaseAnonKey,
    userId: AppConfig.userId,
  );
});
