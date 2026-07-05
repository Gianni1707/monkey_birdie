import 'package:flutter/material.dart';

/// Campo di input "a pillola" con etichetta in grassetto sopra (layout dei
/// mockup, colori del tema). Se [password] è true mostra l'occhio show/hide.
class CampoAuth extends StatefulWidget {
  const CampoAuth({
    super.key,
    required this.controller,
    required this.label,
    required this.icona,
    this.hint,
    this.password = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icona;
  final String? hint;
  final bool password;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  @override
  State<CampoAuth> createState() => _CampoAuthState();
}

class _CampoAuthState extends State<CampoAuth> {
  late bool _nascondi = widget.password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bordo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _nascondi,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icona),
            suffixIcon: widget.password
                ? IconButton(
                    tooltip: null,
                    icon: Icon(
                      _nascondi ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _nascondi = !_nascondi),
                  )
                : null,
            filled: true,
            fillColor: scheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: bordo,
            enabledBorder: bordo,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pulsante primario a tutta larghezza con freccia in coda (mockup), con stato
/// di caricamento. Riusato da login e registrazione.
class BottonePrimarioAuth extends StatelessWidget {
  const BottonePrimarioAuth({
    super.key,
    required this.testo,
    required this.onPressed,
    required this.isLoading,
  });

  final String testo;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(testo),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }
}
