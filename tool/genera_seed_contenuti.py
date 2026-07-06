#!/usr/bin/env python3
"""Genera i seed dei CONTENUTI editoriali dai .md in tool/data/:
  - guide (34+ consigli)              -> supabase/seed/guide_seed.sql
  - calendario_stagionale (12 note)   -> supabase/seed/calendario_stagionale_seed.sql

I .md sono in UTF-8 ma con testo "mojibake" (UTF-8 letto come latin1). Qui si
ripulisce con un mapping ESPLICITO (piu' robusto del round-trip, perche' nel
sorgente alcuni byte del trattino/È sono andati persi). Poi si parsa e si emette
SQL con escaping degli apici.

Uso (dalla root):  python3 tool/genera_seed_contenuti.py
"""
import re

GUIDE_MD = "tool/data/guide_consigli.md"
CAL_MD = "tool/data/calendario_stagionale.md"
GUIDE_SEED = "supabase/seed/guide_seed.sql"
CAL_SEED = "supabase/seed/calendario_stagionale_seed.sql"


def pulisci(t: str) -> str:
    """Corregge il mojibake con regole esplicite e ordinate."""
    # lettere accentate ben formate (Ã + continuazione)
    for a, b in (
        ("Ã¨", "è"), ("Ã©", "é"), ("Ã¬", "ì"),
        ("Ã²", "ò"), ("Ã¹", "ù"), ("Ã¼", "ü"),
    ):
        t = t.replace(a, b)
    # 'Ã ' dopo lettera = à (consuma lo spazio-artefatto): attività, città, già…
    t = re.sub(r"(?<=[A-Za-zàèéìòù])Ã ", "à", t)
    # 'Ã ' restante (inizio frase/dopo punto) = È
    t = t.replace("Ã ", "È ")
    # eventuale 'Ã' isolato residuo -> à
    t = t.replace("Ã", "à")
    # middot e nbsp
    t = t.replace("Â·", "·").replace("Â ", " ").replace("Â", "")
    # trattino perso ('â' isolato) -> en dash
    t = t.replace("â", "–")
    return t


def sql(s: str) -> str:
    return s.replace("'", "''")


def genera_guide():
    testo = pulisci(open(GUIDE_MD, encoding="utf-8").read())
    righe = testo.splitlines()
    voci = []
    i = 0
    rx = re.compile(r"^\*\*(?P<tit>.+?)\*\*\s*·\s*\*(?P<cat>.+?)\*\s*$")
    while i < len(righe):
        m = rx.match(righe[i].strip())
        if m:
            # corpo = righe successive fino a vuota
            corpo = []
            j = i + 1
            while j < len(righe) and righe[j].strip():
                corpo.append(righe[j].strip())
                j += 1
            voci.append((m.group("cat").strip(), m.group("tit").strip(),
                         " ".join(corpo).strip()))
            i = j
        else:
            i += 1

    buf = ["-- Seed guide & consigli (generato da tool/genera_seed_contenuti.py).",
           f"-- {len(voci)} voci. Idempotente: svuota e reinserisce.",
           "delete from guide;"]
    for ordine, (cat, tit, corpo) in enumerate(voci, start=1):
        buf.append(
            "insert into guide (categoria, titolo, corpo, ordine) values "
            f"('{sql(cat)}', '{sql(tit)}', '{sql(corpo)}', {ordine});"
        )
    open(GUIDE_SEED, "w", encoding="utf-8").write("\n".join(buf) + "\n")
    print(f"guide: {len(voci)} voci -> {GUIDE_SEED}")
    return voci


def genera_calendario():
    testo = pulisci(open(CAL_MD, encoding="utf-8").read())
    righe = testo.splitlines()
    voci = []
    i = 0
    rx = re.compile(r"^\*\*(?P<mese>\d{1,2})\s*·\s*(?P<tit>.+?)\*\*\s*$")
    while i < len(righe):
        m = rx.match(righe[i].strip())
        if m:
            corpo = []
            j = i + 1
            while j < len(righe) and righe[j].strip():
                corpo.append(righe[j].strip())
                j += 1
            voci.append((int(m.group("mese")), m.group("tit").strip(),
                         " ".join(corpo).strip()))
            i = j
        else:
            i += 1

    buf = ["-- Seed calendario stagionale (generato da tool/genera_seed_contenuti.py).",
           f"-- {len(voci)} note (una per mese). Idempotente.",
           "delete from calendario_stagionale;"]
    for mese, tit, testo_v in sorted(voci):
        buf.append(
            "insert into calendario_stagionale (mese, titolo, testo) values "
            f"({mese}, '{sql(tit)}', '{sql(testo_v)}');"
        )
    open(CAL_SEED, "w", encoding="utf-8").write("\n".join(buf) + "\n")
    print(f"calendario: {len(voci)} note -> {CAL_SEED}")
    return voci


if __name__ == "__main__":
    genera_guide()
    genera_calendario()
