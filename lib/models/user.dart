class User {
  final String id;
  final String nome;
  final String email;
  final String papel; // 'franqueador_master' | 'franqueado' | 'cliente_parceiro'
  final String tenantId;
  final String tenantNome;

  const User({
    required this.id,
    required this.nome,
    required this.email,
    required this.papel,
    required this.tenantId,
    required this.tenantNome,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id:         j['id'] as String,
    nome:       j['nome'] as String,
    email:      j['email'] as String,
    papel:      j['papel'] as String,
    tenantId:   j['tenant_id'] as String,
    tenantNome: j['tenant_nome'] as String,
  );
}
