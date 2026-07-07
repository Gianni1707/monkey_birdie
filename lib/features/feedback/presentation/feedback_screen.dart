import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/feedback_controller.dart';

/// Box "Invia un feedback" (consigli / bug / altro). Per i bug versione app e
/// piattaforma sono allegate in automatico (vedi controller): non le chiediamo.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  TipoFeedback _tipo = TipoFeedback.consiglio;
  final _messaggio = TextEditingController();

  @override
  void dispose() {
    _messaggio.dispose();
    super.dispose();
  }

  String _etichettaTipo(AppLocalizations l10n, TipoFeedback t) => switch (t) {
        TipoFeedback.consiglio => l10n.feedbackTypeConsiglio,
        TipoFeedback.bug => l10n.feedbackTypeBug,
        TipoFeedback.altro => l10n.feedbackTypeAltro,
      };

  Future<void> _invia() async {
    final l10n = AppLocalizations.of(context);
    if (_messaggio.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.feedbackEmpty)));
      return;
    }
    final ok = await ref
        .read(feedbackControllerProvider.notifier)
        .invia(tipo: _tipo, messaggio: _messaggio.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.feedbackThanks)));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(feedbackControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('${next.error}')));
      }
    });

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(feedbackControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.feedbackSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.feedbackType, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<TipoFeedback>(
            initialValue: _tipo,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (final t in TipoFeedback.values)
                DropdownMenuItem(value: t, child: Text(_etichettaTipo(l10n, t))),
            ],
            onChanged: isLoading
                ? null
                : (t) => setState(() => _tipo = t ?? _tipo),
          ),
          const SizedBox(height: 18),
          Text(l10n.feedbackMessage, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _messaggio,
            minLines: 5,
            maxLines: 10,
            maxLength: 2000,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: l10n.feedbackHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: isLoading ? null : _invia,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(l10n.feedbackSend),
            ),
          ),
        ],
      ),
    );
  }
}
