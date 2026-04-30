class Tenant {
  final String id;
  final String nome;
  final bool ativo;
  final String? cnpj;
  final String? telefoneContato;
  final String? emailContato;
  final String? createdAt;
  final String? ownerId;
  final String? ownerNome;
  final String? ownerEmail;

  const Tenant({
    required this.id,
    required this.nome,
    required this.ativo,
    this.cnpj,
    this.telefoneContato,
    this.emailContato,
    this.createdAt,
    this.ownerId,
    this.ownerNome,
    this.ownerEmail,
  });

  factory Tenant.fromJson(Map<String, dynamic> j) => Tenant(
        id: j['id'] as String,
        nome: j['nome'] as String,
        ativo: j['ativo'] as bool? ?? true,
        cnpj: j['cnpj'] as String?,
        telefoneContato: j['telefone_contato'] as String?,
        emailContato: j['email_contato'] as String?,
        createdAt: (j['criado_em'] ?? j['created_at']) as String?,
        ownerId: j['owner_id'] as String?,
        ownerNome: j['owner_nome'] as String?,
        ownerEmail: j['owner_email'] as String?,
      );
}
