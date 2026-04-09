import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class _E2ECredential {
  final String email;
  final String password;

  const _E2ECredential(this.email, this.password);
}

const Map<String, _E2ECredential> _credentialsByRole = {
  'franqueador_master': _E2ECredential('admin@liveshop.com', 'admin123'),
  'franqueado': _E2ECredential('franqueado@liveshop.com', 'teste123'),
  'cliente_parceiro': _E2ECredential('cliente@liveshop.com', 'teste123'),
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
  if (kReleaseMode) return;

  final normalizedRole = _normalizeRole(role);
  final credential = _credentialsByRole[normalizedRole];

  if (credential == null) {
    debugPrint('[E2E] Role not configured: $role');
    return;
  }

  final ok = await container
      .read(authProvider.notifier)
      .login(credential.email, credential.password);

  if (!ok) {
    final error = container.read(authProvider).error;
    debugPrint('[E2E] Auto login failed for role $normalizedRole: $error');
  } else {
    debugPrint('[E2E] Auto login active for role: $normalizedRole');
  }
}
