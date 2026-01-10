# Service Tests

This directory contains unit tests for the YACK app services.

## Running Tests

### Run all service tests
```bash
flutter test test/services/
```

### Run a specific test file
```bash
flutter test test/services/media_service_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage test/services/
```

## Test Files

| File | Description |
|------|-------------|
| `auth_service_test.dart` | Tests for authentication error mapping and status handling |
| `contract_list_service_test.dart` | Tests for ContractListItem JSON parsing |
| `crypto_service_test.dart` | Tests for RSA key generation, encryption/decryption |
| `media_service_test.dart` | Tests for ContractMedia JSON parsing |
| `message_service_test.dart` | Tests for ContractMessage JSON parsing |
| `temp_contract_service_test.dart` | Tests for TempContract model parsing |
| `user_service_test.dart` | Tests for UserProfile JSON parsing |

## Notes

- Some services like `AuthService` depend on Firebase which requires mocking for full testing
- The tests focus on JSON parsing, data model validation, and pure logic functions

