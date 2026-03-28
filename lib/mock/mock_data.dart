// Dados mockados — fonte única para toda a aplicação nesta etapa

// Faturamento do mês
final mockFat = {
  'total':   48320.00,
  'bruto':   38100.00,
  'liquido': 29450.00,
};

// Cabines (10 no total)
final mockCabines = List.generate(10, (i) => {
  'numero':       i + 1,
  'status':       i < 3 ? 'ao_vivo' : 'disponivel',
  'apresentador': i < 3 ? 'Ana Silva' : null,
  'cliente':      i < 3 ? 'Loja XYZ' : null,
  'horario':      i < 3 ? '14:30' : null,
  'tempo':        i < 3 ? '45min' : null,
});

// Clientes no mapa
final mockClientes = [
  {'nome': 'Loja ABC',    'status': 'ativo',       'lat': -23.5, 'lng': -46.6},
  {'nome': 'Store XYZ',  'status': 'enviado',      'lat': -22.9, 'lng': -43.1},
  {'nome': 'Shop 123',   'status': 'negociacao',   'lat': -15.7, 'lng': -47.9},
  {'nome': 'Loja MMM',   'status': 'inadimplente', 'lat': -30.0, 'lng': -51.2},
  {'nome': 'Indica Ltda','status': 'recomendacao', 'lat': -12.9, 'lng': -38.5},
];

// Ranking de vendedores do dia
final mockRanking = [
  {'nome': 'Ana Silva',    'valor': 12400.00},
  {'nome': 'Bruno Costa',  'valor':  9800.00},
  {'nome': 'Carla Ramos',  'valor':  7200.00},
];

// Leads disponíveis
final mockLeads = [
  {'nome': 'Carlos Mendes', 'nicho': 'Moda',   'cidade': 'São Paulo',  'fat': 180000, 'novo': true},
  {'nome': 'Maria Costa',   'nicho': 'Beleza',  'cidade': 'Curitiba',   'fat':  95000, 'novo': false},
  {'nome': 'João Ferreira', 'nicho': 'Fitness', 'cidade': 'Belo Horizonte', 'fat': 210000, 'novo': true},
];

// Boletos
final mockBoletos = [
  {'tipo': 'Imposto',   'valor': 1240.00, 'vencimento': '10/04/2025', 'status': 'pendente'},
  {'tipo': 'Royalties', 'valor':  890.00, 'vencimento': '05/04/2025', 'status': 'pago'},
  {'tipo': 'Marketing', 'valor':  450.00, 'vencimento': '31/03/2025', 'status': 'vencido'},
];

// Franqueados (painel franqueador)
final mockFranqueados = [
  {'nome': 'Unidade SP',  'fat': 48320.00, 'clientes': 12, 'status': 'ativo'},
  {'nome': 'Unidade RJ',  'fat': 31200.00, 'clientes':  8, 'status': 'ativo'},
  {'nome': 'Unidade BH',  'fat':  9800.00, 'clientes':  3, 'status': 'inadimplente'},
];

// Manuais
final mockManuais = [
  {'titulo': 'Manual de Conduta',        'data': '15/01/2025'},
  {'titulo': 'Responsabilidades do Franqueado', 'data': '20/01/2025'},
  {'titulo': 'Termos e Contratos',       'data': '10/02/2025'},
];

// Recomendações
final mockRecomendacoes = [
  {'indicado': 'Paula Mendes',  'recomendante': 'Carlos Oliveira'},
  {'indicado': 'Roberto Lima',  'recomendante': 'Ana Silva'},
];

// Métricas do cliente parceiro (Painel do Cliente)
final mockClienteMetrics = {
  'crescimento': 18.5,
  'volume':      342,
  'faturamento': 29800.00,
  'lucro':        8400.00,
  'comissao':     1490.00,
  'maisVendidos': ['Vestido Floral', 'Blusa Slip', 'Calça Wide', 'Conjunto Malha', 'Saia Midi'],
};
