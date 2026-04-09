class ConfiguracoesFranquia {
  final String id;
  final String nome;
  final String? logoUrl;
  final String? asaasApiKeyHidden;
  final bool hasAsaas;
  final String? asaasWalletId;
  final bool hasTiktok;
  final String? tiktokShopId;
  final double metaDiariaGmv;

  const ConfiguracoesFranquia({
    required this.id,
    required this.nome,
    this.logoUrl,
    this.asaasApiKeyHidden,
    required this.hasAsaas,
    this.asaasWalletId,
    required this.hasTiktok,
    this.tiktokShopId,
    this.metaDiariaGmv = 10000,
  });

  factory ConfiguracoesFranquia.fromJson(Map<String, dynamic> j) => ConfiguracoesFranquia(
    id: j['id'] as String,
    nome: j['nome'] as String,
    logoUrl: j['logo_url'] as String?,
    asaasApiKeyHidden: j['asaas_api_key_hidden'] as String?,
    hasAsaas: (j['has_asaas'] as bool?) ?? false,
    asaasWalletId: j['asaas_wallet_id'] as String?,
    hasTiktok: (j['has_tiktok'] as bool?) ?? false,
    tiktokShopId: j['tiktok_shop_id'] as String?,
    metaDiariaGmv: (j['meta_diaria_gmv'] as num?)?.toDouble() ?? 10000,
  );
}
