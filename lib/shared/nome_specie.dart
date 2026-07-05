import '../data/models/avvistamento.dart';
import '../data/models/specie.dart';

/// Nome comune da MOSTRARE: italiano se presente, altrimenti l'inglese
/// esistente. Fonte di verità unica del display del nome specie (UT nomi-IT).
/// Il nome scientifico resta mostrato a parte, in corsivo.
String nomeVisualizzato(String? nomeComuneIt, String nomeComune) {
  final it = nomeComuneIt?.trim();
  return (it != null && it.isNotEmpty) ? it : nomeComune;
}

/// Comodità sui modelli, così la UI scrive `specie.nomeDaMostrare`.
extension NomeSpecieX on Specie {
  String get nomeDaMostrare => nomeVisualizzato(nomeComuneIt, nomeComune);
}

extension NomeAvvistamentoX on AvvistamentoDettaglio {
  String get specieNomeDaMostrare =>
      nomeVisualizzato(specieNomeComuneIt, specieNomeComune);
}
