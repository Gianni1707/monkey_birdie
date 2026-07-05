/// UT04 — display in ITALIANO dell'ordine tassonomico.
///
/// Nel catalogo l'ordine è salvato in **latino grezzo** com'è restituito da GBIF
/// (`specie.ordine`, es. `Passeriformes`): dato neutro e riusabile. Qui c'è la
/// sola mappa CURATA latino->italiano (~46 ordini di uccelli, non migliaia) usata
/// a display. Se l'ordine è null o non mappato -> [ordineInItaliano] ritorna null
/// e la UI NON mostra il badge (niente "n/d").
const Map<String, String> _ordiniItaliano = {
  'Accipitriformes': 'Accipitriformi',
  'Aegotheliformes': 'Egoteliformi',
  'Anseriformes': 'Anseriformi',
  'Apodiformes': 'Apodiformi',
  'Apterygiformes': 'Apterigiformi',
  'Bucerotiformes': 'Bucerotiformi',
  'Caprimulgiformes': 'Caprimulgiformi',
  'Cariamiformes': 'Cariamiformi',
  'Casuariiformes': 'Casuariiformi',
  'Cathartiformes': 'Catartiformi',
  'Charadriiformes': 'Caradriiformi',
  'Ciconiiformes': 'Ciconiiformi',
  'Coliiformes': 'Coliiformi',
  'Columbiformes': 'Columbiformi',
  'Coraciiformes': 'Coraciiformi',
  'Cuculiformes': 'Cuculiformi',
  'Eurypygiformes': 'Euripigiformi',
  'Falconiformes': 'Falconiformi',
  'Galbuliformes': 'Galbuliformi',
  'Galliformes': 'Galliformi',
  'Gaviiformes': 'Gaviiformi',
  'Gruiformes': 'Gruiformi',
  'Leptosomiformes': 'Leptosomiformi',
  'Mesitornithiformes': 'Mesitornitiformi',
  'Musophagiformes': 'Musofagiformi',
  'Nyctibiiformes': 'Nictibiiformi',
  'Opisthocomiformes': 'Opistocomiformi',
  'Otidiformes': 'Otidiformi',
  'Passeriformes': 'Passeriformi',
  'Pelecaniformes': 'Pelecaniformi',
  'Phaethontiformes': 'Faetontiformi',
  'Phoenicopteriformes': 'Fenicotteriformi',
  'Piciformes': 'Piciformi',
  'Podargiformes': 'Podargiformi',
  'Podicipediformes': 'Podicipediformi',
  'Procellariiformes': 'Procellariiformi',
  'Psittaciformes': 'Psittaciformi',
  'Pteroclidiformes': 'Pterocliformi',
  'Rheiformes': 'Reiformi',
  'Sphenisciformes': 'Sfenisciformi',
  'Steatornithiformes': 'Steatornitiformi',
  'Strigiformes': 'Strigiformi',
  'Struthioniformes': 'Struthioniformi',
  'Suliformes': 'Suliformi',
  'Tinamiformes': 'Tinamiformi',
  'Trogoniformes': 'Trogoniformi',
};

/// Nome ITALIANO dell'ordine, o `null` se assente/non mappato (-> niente badge).
String? ordineInItaliano(String? latino) {
  final l = latino?.trim();
  if (l == null || l.isEmpty) return null;
  return _ordiniItaliano[l];
}
