// Dialog reusável Create/Edit/Delete pra Lead. Tema dark fixo (segue CRM v3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/lead.dart';
import '../../providers/leads_provider.dart';

class _D {
  static const bg          = Color(0xFF16161A);
  static const surface     = Color(0xFF1E1E22);
  static const input       = Color(0xFF1A1A1E);
  static const border      = Color(0x1AFFFFFF);
  static const borderFocus = Color(0xFFFF6A2F);
  static const text        = Color(0xFFF5F0EB);
  static const textSec     = Color(0xFFB8B2AC);
  static const textMuted   = Color(0xFF75716D);
  static const primary     = Color(0xFFFF6A2F);
  static const danger      = Color(0xFFF87171);
  static const success     = Color(0xFF34D399);
}

const _STAGE_OPTS = [
  ('lead_novo', 'Lead captado'),
  ('contato_iniciado', 'Qualificação'),
  ('reuniao_agendada', 'Reunião agendada'),
  ('proposta_enviada', 'Negociação'),
  ('em_negociacao', 'Contrato enviado'),
  ('aguardando_assinatura', 'Contrato pendente'),
  ('ganho', 'Fechado ganho'),
  ('perdido', 'Fechado perdido'),
];

const _TIPO_OPTS = [
  ('Cliente', 'Cliente'),
  ('Creator', 'Creator'),
  ('Unidade', 'Unidade'),
  ('Outro', 'Outro'),
];

Future<bool?> showLeadDialog(BuildContext context, {Lead? lead}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => Dialog(
      backgroundColor: _D.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: _LeadForm(lead: lead),
      ),
    ),
  );
}

class _LeadForm extends ConsumerStatefulWidget {
  final Lead? lead;
  const _LeadForm({required this.lead});

  @override
  ConsumerState<_LeadForm> createState() => _LeadFormState();
}

class _LeadFormState extends ConsumerState<_LeadForm> {
  late final TextEditingController _nome;
  late final TextEditingController _cidade;
  late final TextEditingController _estado;
  late final TextEditingController _responsavel;
  late final TextEditingController _origem;
  late final TextEditingController _valor;
  late final TextEditingController _observacoes;
  late String _tipo;
  late String _etapa;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEdit => widget.lead != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _nome = TextEditingController(text: l?.nome ?? '');
    _cidade = TextEditingController(text: l?.cidade ?? '');
    _estado = TextEditingController(text: l?.estado ?? '');
    _responsavel = TextEditingController(text: l?.responsavelNome ?? '');
    _origem = TextEditingController(text: l?.origem ?? '');
    _valor = TextEditingController(
      text: l == null
          ? ''
          : (l.valorOportunidade > 0 ? l.valorOportunidade : l.fatEstimado).toStringAsFixed(0),
    );
    _observacoes = TextEditingController(text: l?.observacoesInternas ?? '');
    _tipo = _detectTipo(l?.nicho);
    _etapa = l?.crmEtapa ?? 'lead_novo';
  }

  @override
  void dispose() {
    _nome.dispose();
    _cidade.dispose();
    _estado.dispose();
    _responsavel.dispose();
    _origem.dispose();
    _valor.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  String _detectTipo(String? nicho) {
    if (nicho == null) return 'Cliente';
    final n = nicho.toLowerCase();
    if (n.contains('unidade') || n.contains('franquead')) return 'Unidade';
    if (n.contains('creator') || n.contains('apresentador')) return 'Creator';
    if (n.contains('cliente') || n.contains('bio_')) return 'Cliente';
    return 'Outro';
  }

  Future<void> _save() async {
    if (_nome.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome obrigatório'), backgroundColor: _D.danger),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final valorNum = double.tryParse(_valor.text.replaceAll(',', '.')) ?? 0;
      final data = <String, dynamic>{
        'nome': _nome.text.trim(),
        if (_cidade.text.trim().isNotEmpty) 'cidade': _cidade.text.trim(),
        if (_estado.text.trim().isNotEmpty) 'estado': _estado.text.trim(),
        if (_responsavel.text.trim().isNotEmpty) 'responsavel_nome': _responsavel.text.trim(),
        if (_origem.text.trim().isNotEmpty) 'origem': _origem.text.trim(),
        if (_tipo != 'Outro') 'nicho': _tipo,
        if (valorNum > 0) ...{
          'valor_oportunidade': valorNum,
          'fat_estimado': valorNum,
        },
        if (_observacoes.text.trim().isNotEmpty) 'observacoes_internas': _observacoes.text.trim(),
        'crm_etapa': _etapa,
      };

      final notifier = ref.read(leadsProvider.notifier);
      if (_isEdit) {
        // Atualiza campos
        await notifier.atualizar(widget.lead!.id, data);
        // Se etapa mudou, sincroniza via moverEtapa (endpoint específico)
        if (widget.lead!.crmEtapa != _etapa) {
          await notifier.moverEtapa(widget.lead!.id, _etapa);
        }
      } else {
        await notifier.criar(data);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: _D.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _D.bg,
        title: Text('Excluir lead?', style: TextStyle(color: _D.text)),
        content: Text(
          'Esta ação não pode ser desfeita. Lead "${widget.lead!.nome}" será removido.',
          style: TextStyle(color: _D.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: _D.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _D.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _deleting = true);
    try {
      await ref.read(leadsProvider.notifier).deletar(widget.lead!.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: _D.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: _D.bg,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit ? 'Editar lead' : 'Novo lead',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _D.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: _D.textMuted),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Field(label: 'Nome do lead *', controller: _nome),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _Field(label: 'Cidade', controller: _cidade)),
                        const SizedBox(width: 10),
                        SizedBox(width: 90, child: _Field(label: 'UF', controller: _estado)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _Dropdown(label: 'Tipo', value: _tipo, items: _TIPO_OPTS, onChanged: (v) => setState(() => _tipo = v ?? 'Cliente'))),
                        const SizedBox(width: 10),
                        Expanded(child: _Dropdown(label: 'Etapa', value: _etapa, items: _STAGE_OPTS, onChanged: (v) => setState(() => _etapa = v ?? 'lead_novo'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Field(label: 'Responsável', controller: _responsavel),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _Field(label: 'Origem', controller: _origem, hint: 'ex: bio_cliente, indicação, outbound')),
                        const SizedBox(width: 10),
                        Expanded(child: _Field(label: 'Valor (R\$)', controller: _valor, keyboard: TextInputType.number)),
                      ],
                    ),
                    if (_isEdit) ...[
                      const SizedBox(height: 18),
                      _BioDataBlock(lead: widget.lead!),
                    ],
                    const SizedBox(height: 12),
                    _Field(label: 'Observações internas', controller: _observacoes, multiline: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (_isEdit)
                  TextButton.icon(
                    onPressed: _deleting ? null : _delete,
                    icon: _deleting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _D.danger))
                        : Icon(Icons.delete_outline, size: 16, color: _D.danger),
                    label: Text('Excluir', style: TextStyle(color: _D.danger)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                  child: Text('Cancelar', style: TextStyle(color: _D.textMuted)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(backgroundColor: _D.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                  icon: _saving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check, size: 16),
                  label: Text(_isEdit ? 'Salvar' : 'Criar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool multiline;
  final TextInputType? keyboard;
  const _Field({required this.label, required this.controller, this.hint, this.multiline = false, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: _D.textSec, letterSpacing: 0.1)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: multiline ? 3 : 1,
          maxLines: multiline ? 5 : 1,
          keyboardType: keyboard,
          cursorColor: _D.primary,
          style: GoogleFonts.inter(fontSize: 13, color: _D.text),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: _D.textMuted),
            filled: true,
            fillColor: _D.input,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _D.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _D.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _D.borderFocus, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: _D.textSec, letterSpacing: 0.1)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _D.input,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _D.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.any((e) => e.$1 == value) ? value : items.first.$1,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _D.textMuted),
              dropdownColor: _D.surface,
              borderRadius: BorderRadius.circular(10),
              style: GoogleFonts.inter(fontSize: 13, color: _D.text),
              onChanged: onChanged,
              items: items.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _BioDataBlock extends StatelessWidget {
  final Lead lead;
  const _BioDataBlock({required this.lead});

  static const _LABELS = <String, String>{
    'nome': 'Nome',
    'cidade': 'Cidade',
    'estado': 'Estado',
    'email': 'E-mail',
    'whatsapp': 'WhatsApp',
    'telefone': 'Telefone',
    'segmento': 'Segmento',
    'nicho': 'Nicho',
    'fat_anual': 'Faturamento anual',
    'faturamento': 'Faturamento',
    'fat_estimado': 'Faturamento estimado',
    'situacao': 'Situação atual',
    'experiencia_franquia': 'Experiência c/ franquias',
    'conhece_live_commerce': 'Conhece live commerce',
    'socios': 'Sócios',
    'capital': 'Capital disponível',
    'prazo_inicio': 'Prazo para início',
    'espaco_fisico': 'Espaço físico',
    'horario': 'Melhor horário',
    'atrativos': 'O que mais atrai',
    'receio': 'Principal receio',
    'interesse': 'Nível de interesse',
  };

  String _formatValue(dynamic v) {
    if (v == null) return '';
    if (v is List) return v.map((e) => e.toString()).where((s) => s.isNotEmpty).join(', ');
    if (v is Map) return v.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
    return v.toString().trim();
  }

  String _humanLabel(String key) =>
      _LABELS[key] ??
      key.split('_').map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');

  /// Fallback: parsea o texto da ficha gerada pelo backend (formatLeadFicha)
  /// quando payload_externo ainda não está disponível na resposta da API.
  /// Formato esperado:
  ///   SEÇÃO EM CAPS
  ///   Label: valor
  ///   Label: valor
  ///
  ///   OUTRA SEÇÃO
  ///   ...
  static List<({String section, List<({String label, String value})> rows})>
      _parseFicha(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    final sections = <({String section, List<({String label, String value})> rows})>[];
    String? current;
    var rows = <({String label, String value})>[];
    void flush() {
      if (current != null && rows.isNotEmpty) {
        sections.add((section: current!, rows: List.of(rows)));
      }
      rows = [];
    }
    for (final line in raw.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) continue;
      // Heurística: linha sem ":" e em maiúsculas = título de seção
      if (!t.contains(':') && t.toUpperCase() == t && t.length > 2) {
        flush();
        current = t;
        continue;
      }
      final idx = t.indexOf(':');
      if (idx > 0) {
        final label = t.substring(0, idx).trim();
        final value = t.substring(idx + 1).trim();
        if (value.isNotEmpty) rows.add((label: label, value: value));
      }
    }
    flush();
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final email = lead.contatoEmail;
    final whatsapp = lead.contatoWhatsapp;
    final payload = lead.payloadExterno;
    final data = (payload?['data'] is Map)
        ? Map<String, dynamic>.from(payload!['data'] as Map)
        : <String, dynamic>{};
    final persona = payload?['persona']?.toString();
    final sourcePath = payload?['source_path']?.toString();
    final submittedAt = payload?['submitted_at']?.toString();
    final fichaSections = _parseFicha(lead.observacoesInternas);

    final hasContato = (email?.isNotEmpty ?? false) || (whatsapp?.isNotEmpty ?? false);
    final hasAnything = hasContato || data.isNotEmpty || fichaSections.isNotEmpty;
    if (!hasAnything) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.input,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _D.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados do formulário',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _D.text,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          if (persona != null || sourcePath != null || submittedAt != null)
            Text(
              [
                if (persona != null) 'Persona: $persona',
                if (sourcePath != null) sourcePath,
                if (submittedAt != null) submittedAt,
              ].join(' · '),
              style: GoogleFonts.inter(fontSize: 10.5, color: _D.textMuted),
            ),
          const SizedBox(height: 12),
          if (hasContato) ...[
            if (email?.isNotEmpty ?? false) _BioRow(label: 'E-mail', value: email!),
            if (whatsapp?.isNotEmpty ?? false) _BioRow(label: 'WhatsApp', value: whatsapp!),
            const SizedBox(height: 8),
            Container(height: 1, color: _D.border),
            const SizedBox(height: 8),
          ],
          if (data.isNotEmpty)
            ...data.entries
                .map((e) {
                  final v = _formatValue(e.value);
                  if (v.isEmpty) return null;
                  return _BioRow(label: _humanLabel(e.key), value: v);
                })
                .whereType<Widget>()
          else if (fichaSections.isNotEmpty)
            ...fichaSections.expand((s) => [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 6),
                    child: Text(
                      s.section,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _D.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  ...s.rows.map((r) => _BioRow(label: r.label, value: r.value)),
                ])
          else if (!hasContato)
            Text(
              'Sem dados adicionais do formulário.',
              style: GoogleFonts.inter(fontSize: 11.5, color: _D.textMuted, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

class _BioRow extends StatelessWidget {
  final String label;
  final String value;
  const _BioRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: _D.textSec,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: GoogleFonts.inter(fontSize: 12.5, color: _D.text, height: 1.4),
          ),
        ],
      ),
    );
  }
}
