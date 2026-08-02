Restore live backend integration by:
1. Restoring di.dart to use AppConfig.isMock check (original logic)
2. Restoring mock_data_service.dart to original with delays and original seed data
3. Verify flutter analyze passes with no errors