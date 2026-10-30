import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../data/models/nutrition.dart';
import '../../l10n/app_localizations.dart';
import '../../services/barcode_lookup.dart';
import '../../widgets/common.dart';
import 'portion_sheet.dart';
import '../../widgets/home_logo.dart';

/// Whether to show the camera scanner (phones only). Overridden in tests.
final scanCameraProvider = Provider<bool>(
  (ref) => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS),
);

/// Screen 38 — a product's barcode: the camera on phones, or typing the
/// number anywhere. A barcode the user saved before opens straight away;
/// otherwise Open Food Facts is asked and the user checks the label.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, required this.day, required this.meal});
  final String day;
  final MealType meal;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _message;
  late final bool _camera = ref.read(scanCameraProvider);

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _handle(String raw) async {
    final code = raw.trim();
    if (_busy) return;
    final l = AppLocalizations.of(context);
    if (!CustomFood.barcodePattern.hasMatch(code)) {
      setState(() => _message = l.barcodeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final saved = ref.read(dataProvider).customFoods.where((f) => f.barcode == code).firstOrNull;
    if (saved != null) {
      setState(() => _busy = false);
      final ok = await showPortionSheet(context, ref,
          name: saved.name, portion: saved.portion, per: saved.per, day: widget.day, meal: widget.meal, foodRef: saved.id);
      if (ok && mounted) {
        showSnack(context, l.foodAdded(saved.name));
        context.pop();
      }
      return;
    }
    final r = await ref.read(barcodeLookupProvider).find(code, lang: l.localeName);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.failure == LookupFailure.network) {
      setState(() => _message = l.lookupNetwork);
      return;
    }
    // Found: check the label. Not found: type it in once, it's kept.
    context.pushReplacement(Routes.customFood(barcode: code, day: widget.day, meal: widget.meal.name), extra: r.product);
    if (r.product == null) showSnack(context, l.productNotFound);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.scanBarcode), actions: const [HomeLogoButton()]),
      body: ResponsiveContainer(
        maxWidth: 640,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
          if (_camera) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.card),
              child: SizedBox(
                height: 280,
                child: MobileScanner(
                  controller: MobileScannerController(
                    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
                  ),
                  onDetect: (cap) {
                    final v = cap.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
                    if (v != null) _handle(v);
                  },
                  errorBuilder: (_, _) => Center(child: Padding(padding: const EdgeInsets.all(Space.l), child: Text(l.cameraUnavailable, textAlign: TextAlign.center))),
                ),
              ),
            ),
            const SizedBox(height: Space.s),
            Text(l.pointAtBarcode, style: t.bodySmall?.copyWith(color: context.status.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: Space.xl),
          ],
          if (!_camera) ...[
            AppCard(
              color: context.status.highlight,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const IconBadge(Icons.qr_code_scanner),
                const SizedBox(width: Space.m),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.scanOnPhone, style: t.titleSmall),
                    Text(l.scanOnPhoneBody, style: t.bodySmall),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: Space.xl),
          ],
          Text(l.orTypeBarcode, style: t.titleSmall),
          const SizedBox(height: Space.s),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)],
            decoration: InputDecoration(labelText: l.barcodeNumber, errorText: _message),
            onSubmitted: _handle,
          ),
          const SizedBox(height: Space.m),
          PrimaryButton(label: l.lookUp, loading: _busy, onPressed: () => _handle(_code.text)),
          const SizedBox(height: Space.l),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 18, color: context.status.info),
            const SizedBox(width: Space.s),
            Expanded(child: Text(l.offNote, style: t.bodySmall?.copyWith(color: context.status.textSecondary))),
          ]),
        ]),
      ),
    );
  }
}
