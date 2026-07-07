import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../application/xeno_canto_repository.dart';

/// Player "Ascolta il verso" per la scheda specie: play/pausa di una
/// registrazione xeno-canto (CC) + riga di attribuzione OBBLIGATORIA (autore +
/// numero XC + link alla pagina originale). Mostrato solo se c'è un verso.
class VersoPlayer extends StatefulWidget {
  const VersoPlayer({super.key, required this.verso});
  final VersoSpecie verso;

  @override
  State<VersoPlayer> createState() => _VersoPlayerState();
}

class _VersoPlayerState extends State<VersoPlayer> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _subStato;
  StreamSubscription<void>? _subFine;
  bool _inRiproduzione = false;
  bool _avviato = false;
  bool _caricando = false;

  @override
  void initState() {
    super.initState();
    _subStato = _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _inRiproduzione = s == PlayerState.playing);
    });
    _subFine = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _avviato = false); // riparte da capo al prossimo play
    });
  }

  @override
  void dispose() {
    _subStato?.cancel();
    _subFine?.cancel();
    _player.dispose();
    super.dispose();
  }

  /// Sul web l'audio passa dal Worker (same-origin, senza Content-Disposition,
  /// così il browser lo riproduce inline); su Android il file diretto va bene.
  String get _urlRiproduzione => kIsWeb
      ? '$kXenoCantoProxy?audio=${widget.verso.xcId}'
      : widget.verso.audioUrl;

  Future<void> _toggle() async {
    if (_inRiproduzione) {
      await _player.pause();
      return;
    }
    setState(() => _caricando = true);
    try {
      if (_avviato) {
        await _player.resume();
      } else {
        await _player.play(UrlSource(_urlRiproduzione));
        _avviato = true;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio non disponibile')),
        );
      }
    } finally {
      if (mounted) setState(() => _caricando = false);
    }
  }

  Future<void> _apriPagina() async {
    final uri = Uri.tryParse(widget.verso.pagina);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filled(
                onPressed: _caricando ? null : _toggle,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: Colors.white,
                ),
                icon: _caricando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_inRiproduzione ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.listenCall,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _apriPagina,
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.recordingCredit(widget.verso.autore, widget.verso.xcId),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
