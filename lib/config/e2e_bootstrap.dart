import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class _E2ECredential {
  final String email;
  final String password;

  const _E2ECredential(this.email, this.password);
}

const Map<String, _E2ECredential> _credentialsByRole = {
  'franqueador_master': _E2ECredential(
    String.fromEnvironment('E2E_EMAIL_MASTER', defaultValue: ''),
    String.fromEnvironment('E2E_PASSWORD_MASTER', defaultValue: ''),
  ),
  'franqueado': _E2ECredential(
    String.fromEnvironment('E2E_EMAIL_FRANQUEADO', defaultValue: ''),
    String.fromEnvironment('E2E_PASSWORD_FRANQUEADO', defaultValue: ''),
  ),
  'cliente_parceiro': _E2ECredential(
    String.fromEnvironment('E2E_EMAIL_CLIENTE', defaultValue: ''),
    String.fromEnvironment('E2E_PASSWORD_CLIENTE', defaultValue: ''),
  ),
};

String _normalizeRole(String role) {
  switch (role) {
    case 'master':
      return 'franqueador_master';
    case 'cliente':
      return 'cliente_parceiro';
    default:
      return role;
  }
}

Future<void> bootstrapE2EAuth(
  ProviderContainer container, {
  required String role,
}) async {
  final normalizedRole = _normalizeRole(role);
  final credential = _credentialsByRole[normalizedRole];

  if (credential == null) {
    print('[E2E] Role not configured: $role');
    return;
  }

  if (credential.email.isEmpty || credential.password.isEmpty) {
    print(
      '[E2E] Credentials not provided for role $normalizedRole. '
      'Pass --dart-define=E2E_EMAIL_<ROLE>=... and --dart-define=E2E_PASSWORD_<ROLE>=...',
    );
    return;
  }

  final ok = await container
      .read(authProvider.notifier)
      .login(credential.email, credential.password);

  if (!ok) {
    final error = container.read(authProvider).error;
    print('[E2E] Auto login failed for role $normalizedRole: $error');
  } else {
    print('[E2E] Auto login active for role: $normalizedRole');
  }
}
