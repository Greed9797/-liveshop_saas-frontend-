import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class CadastroClienteScreen extends ConsumerStatefulWidget {
  const CadastroClienteScreen({super.key});
  @override
  ConsumerState<CadastroClienteScreen> createState() => _CadastroClienteScreenState();
}

class _CadastroClienteScreenState extends ConsumerState<CadastroClienteScreen> {
  final _pageCtrl = PageController();
  int _step = 0;
  bool _loading = false;

  // Step 1 — Dados pessoais
  final _nomeCtrl    = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _cpfCtrl     = TextEditingController();

  // Step 2 — Dados comerciais
  final _cnpjCtrl       = TextEditingController();
  final _razaoCtrl      = TextEditingController();
  final _fatCtrl        = TextEditingController();
  final _nichoCtrl      = TextEditingController();
  final _sigaCtrl       = TextEditingController();

  // Step 3 — Localização
  final _cepCtrl        = TextEditingController();
  final _cidadeCtrl     = TextEditingController();
  final _estadoCtrl     = TextEditingController();
  double? _lat, _lng;
  bool _geocodingLoading = false;
  Timer? _cepDebounce;

  // Step 4 — Qualificação
  bool _jaVendeTikTok = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nomeCtrl.dispose(); _celularCtrl.dispose(); _emailCtrl.dispose(); _cpfCtrl.dispose();
    _cnpjCtrl.dispose(); _razaoCtrl.dispose(); _fatCtrl.dispose(); _nichoCtrl.dispose(); _sigaCtrl.dispose();
    _cepCtrl.dispose(); _cidadeCtrl.dispose(); _estadoCtrl.dispose();
    _cepDebounce?.cancel();
    super.dispose();
  }

  void _onCepChanged(String value) {
    _cepDebounce?.cancel();
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return;
    _cepDebounce = Timer(const Duration(milliseconds: 500), () => _buscarCep(digits));
  }

  Future<void> _buscarCep(String cep) async {
    setState(() => _geocodingLoading = true);
    try {
      final data = await ref.read(clientesProvider.notifier).buscarCep(cep);
      setState(() {
        _cidadeCtrl.text = data['cidade'] as String? ?? '';
        _estadoCtrl.text = data['estado'] as String? ?? '';
        _lat = (data['lat'] as num?)?.toDouble();
        _lng = (data['lng'] as num?)?.toDouble();
      });
    } catch (_) {
      // Falha silenciosa
    } finally {
      if (mounted) setState(() => _geocodingLoading = false);
    }
  }

  void _nextStep() {
    if (_step == 0 && (_nomeCtrl.text.isEmpty || _celularCtrl.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e celular são obrigatórios')),
      );
      return;
    }
    if (_step < 3) {
      setState(() => _step++);
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _salvar({required bool gerarContrato}) async {
    setState(() => _loading = true);
    try {
      final cliente = await ref.read(clientesProvider.notifier).criar({
        'nome':         _nomeCtrl.text,
        'celular':      _celularCtrl.text,
        if (_emailCtrl.text.isNotEmpty)  'email':        _emailCtrl.text,
        if (_cpfCtrl.text.isNotEmpty)    'cpf':          _cpfCtrl.text,
        if (_cnpjCtrl.text.isNotEmpty)   'cnpj':         _cnpjCtrl.text,
        if (_razaoCtrl.text.isNotEmpty)  'razao_social': _razaoCtrl.text,
        if (_nichoCtrl.text.isNotEmpty)  'nicho':        _nichoCtrl.text,
        if (_sigaCtrl.text.isNotEmpty)   'siga':         _sigaCtrl.text,
        if (_cepCtrl.text.isNotEmpty)    'cep':          _cepCtrl.text.replaceAll(RegExp(r'\D'), ''),
        if (_cidadeCtrl.text.isNotEmpty) 'cidade':       _cidadeCtrl.text,
        if (_estadoCtrl.text.isNotEmpty) 'estado':       _estadoCtrl.text,
        'fat_anual':    double.tryParse(_fatCtrl.text.replaceAll(',', '.')) ?? 0,
        'vende_tiktok': _jaVendeTikTok,
        if (_lat != null) 'lat': _lat,
        if (_lng != null) 'lng': _lng,
      });
      if (!mounted) return;
      if (gerarContrato) {
        Navigator.pushNamed(context, AppRoutes.contrato, arguments: {'clienteId': cliente.id});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rascunho salvo!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.vendas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(current: _step),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 360,
                      child: PageView(
                        controller: _pageCtrl,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _step1(),
                          _step2(),
                          _step3(),
                          _step4(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNavButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _step1() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dados Pessoais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _field('Nome Completo *', _nomeCtrl),
        _field('Celular (WhatsApp) *', _celularCtrl, type: TextInputType.phone),
        _field('Email', _emailCtrl, type: TextInputType.emailAddress),
        _field('CPF', _cpfCtrl),
      ],
    ),
  );

  Widget _step2() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dados Comerciais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _field('CNPJ', _cnpjCtrl),
        _field('Razão Social', _razaoCtrl),
        _field('Faturamento Anual R\$', _fatCtrl, type: TextInputType.number),
        _field('Nicho (ex: Moda, Eletrônicos)', _nichoCtrl),
        _field('@ TikTok / Instagram', _sigaCtrl),
      ],
    ),
  );

  Widget _step3() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Localização', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(
          controller: _cepCtrl,
          keyboardType: TextInputType.number,
          onChanged: _onCepChanged,
          decoration: InputDecoration(
            labelText: 'CEP *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: _geocodingLoading
                ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                : const Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(flex: 3, child: _field('Cidade', _cidadeCtrl)),
            const SizedBox(width: 8),
            Expanded(flex: 1, child: _field('UF', _estadoCtrl)),
          ],
        ),
        if (_lat != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success, size: 14),
              const SizedBox(width: 4),
              Text('Geolocalizado (${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)})',
                  style: const TextStyle(fontSize: 11, color: AppColors.success)),
            ]),
          ),
      ],
    ),
  );

  Widget _step4() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Qualificação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        Row(children: [
          const Text('Já vende no TikTok Live?', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 12),
          Switch(
            value: _jaVendeTikTok,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _jaVendeTikTok = v),
          ),
          Text(_jaVendeTikTok ? 'Sim' : 'Não'),
        ]),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        const Text('Revisão', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _reviewRow('Nome', _nomeCtrl.text),
        _reviewRow('Celular', _celularCtrl.text),
        if (_emailCtrl.text.isNotEmpty) _reviewRow('Email', _emailCtrl.text),
        if (_cnpjCtrl.text.isNotEmpty) _reviewRow('CNPJ', _cnpjCtrl.text),
        if (_nichoCtrl.text.isNotEmpty) _reviewRow('Nicho', _nichoCtrl.text),
        if (_cidadeCtrl.text.isNotEmpty) _reviewRow('Cidade/UF', '${_cidadeCtrl.text}/${_estadoCtrl.text}'),
      ],
    ),
  );

  Widget _reviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]),
  );

  Widget _buildNavButtons() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Row(
      children: [
        if (_step > 0)
          TextButton.icon(
            onPressed: _prevStep,
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Voltar'),
          ),
        const Spacer(),
        if (_step < 3)
          ActionButton(label: 'PRÓXIMO', icon: Icons.arrow_forward_ios, onPressed: _nextStep)
        else ...[
          ActionButton(
            label: 'GERAR CONTRATO',
            icon: Icons.description_outlined,
            onPressed: () => _salvar(gerarContrato: true),
          ),
          const SizedBox(width: 12),
          ActionButton(
            label: 'RASCUNHO',
            icon: Icons.save_outlined,
            outlined: true,
            onPressed: () => _salvar(gerarContrato: false),
          ),
        ],
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? type}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  static const _labels = ['Pessoal', 'Comercial', 'Localização', 'Qualificação'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final active = i == current;
        final done   = i < current;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.success : active ? AppColors.primary : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text('${i + 1}', style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_labels[i], style: TextStyle(fontSize: 9, color: active ? AppColors.primary : Colors.grey)),
                ],
              ),
              if (i < _labels.length - 1)
                Expanded(child: Container(height: 1, color: done ? AppColors.success : Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 16))),
            ],
          ),
        );
      }),
    );
  }
}
