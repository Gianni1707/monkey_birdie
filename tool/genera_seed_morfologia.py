#!/usr/bin/env python3
"""Genera il seed dei tratti morfologici (BIRDBASE -> tabella `specie`).

Legge tool/data/birdbase.xlsx (Excel) con la sola stdlib (zipfile + XML), abbina
al catalogo sul nome scientifico (prova più tassonomie), e scrive
supabase/seed/specie_morfologia_seed.sql (UPDATE bulk, idempotente).

Tratti: peso_min_g/peso_max_g (range o medio in fallback), uova_min/uova_max
(Clutch), nido (Nest_Type decodificato in italiano). Dove manca -> NULL.

Uso (dalla root):  python3 tool/genera_seed_morfologia.py
"""
import re
import zipfile
import xml.etree.ElementTree as ET

XLSX = "tool/data/birdbase.xlsx"
SEED = "supabase/seed/specie_morfologia_seed.sql"
CATALOGO = "supabase/seed/specie_full_seed.sql"
M = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"

# Nest_Type (BIRDBASE Legend) -> etichetta italiana. Per valori multipli
# ("CV,O") si usa il primo codice.
NIDO_IT = {
    "BU": "in tana (nel terreno)",
    "CP": "a coppa",
    "CR": "in fessura",
    "CV": "in cavità (albero)",
    "DM": "a cupola",
    "HC": "a semicoppa",
    "NO": "senza nido",
    "O": "nido di altri uccelli",
    "PL": "a piattaforma",
    "PN": "pensile (a sacca)",
    "SA": "a piattino",
    "SC": "in raspatura (a terra)",
    "SP": "sferico (globulare)",
    "M": "a tumulo",
}

# Tetto di sanità sulla covata: Clutch_Min/Max di BIRDBASE sono min/max deposti
# (non la covata tipica) e la coda alta contiene outlier implausibili su piccoli
# passeriformi (es. Cinciallegra 3-18). Importo le uova solo se min e max sono
# coerenti e max <= questa soglia; altrimenti -> n/d (meglio niente che assurdo).
MAX_UOVA_PLAUSIBILE = 10

# Indici colonna (riga 2 = sotto-intestazioni BIRDBASE) del foglio "Data".
COL_SCI = (5, 4, 2, 3, 6)  # eBird/Clements, IOC, Latin, BirdLife, AviList
C_FMIN, C_FMAX, C_MMIN, C_MMAX, C_UMIN, C_UMAX, C_AVG = 20, 21, 22, 23, 24, 25, 26
C_CMIN, C_CMAX, C_NEST = 78, 79, 74


def _shared_strings(z):
    ss = []
    try:
        r = ET.fromstring(z.read("xl/sharedStrings.xml"))
    except KeyError:
        return ss
    for si in r.findall(M + "si"):
        ss.append("".join(t.text or "" for t in si.iter(M + "t")))
    return ss


def _colnum(ref):
    c = "".join(ch for ch in ref if ch.isalpha())
    n = 0
    for ch in c:
        n = n * 26 + (ord(ch) - 64)
    return n - 1


def _rows(z, path, ss):
    root = ET.fromstring(z.read(path))
    for row in root.iter(M + "row"):
        cells = {}
        for c in row.findall(M + "c"):
            t = c.get("t")
            v = c.find(M + "v")
            istr = c.find(M + "is")
            val = None
            if t == "s" and v is not None:
                val = ss[int(v.text)]
            elif istr is not None:
                val = "".join(x.text or "" for x in istr.iter(M + "t"))
            elif v is not None:
                val = v.text
            cells[_colnum(c.get("r"))] = val
        w = (max(cells) + 1) if cells else 0
        yield [cells.get(i) for i in range(w)]


def _num(row, i):
    if i >= len(row):
        return None
    v = row[i]
    if v is None or v in ("", "NA", "na"):
        return None
    try:
        return float(v)
    except ValueError:
        return None


def _peso(row):
    """Range (min<max) da Female/Male/Unsexed; fallback al medio; else None."""
    mins = [x for x in (_num(row, C_FMIN), _num(row, C_MMIN), _num(row, C_UMIN)) if x]
    maxs = [x for x in (_num(row, C_FMAX), _num(row, C_MMAX), _num(row, C_UMAX)) if x]
    avg = _num(row, C_AVG)
    if mins and maxs and min(mins) < max(maxs):
        return round(min(mins)), round(max(maxs))
    if avg:
        return round(avg), round(avg)
    if mins or maxs:  # solo un estremo o min==max
        v = round((mins or maxs)[0])
        return v, v
    return None


def _nido(row):
    if C_NEST >= len(row) or not row[C_NEST]:
        return None
    code = str(row[C_NEST]).split(",")[0].strip()
    return NIDO_IT.get(code)


def main():
    sci_catalogo = sorted(
        set(re.findall(r"\('[^']*', '([^']+)'", open(CATALOGO).read()))
    )
    z = zipfile.ZipFile(XLSX)
    ss = _shared_strings(z)
    data = list(_rows(z, "xl/worksheets/sheet1.xml", ss))[2:]  # salta 2 header

    # mappa nome-scientifico (ogni tassonomia) -> riga
    bb = {}
    for row in data:
        for i in COL_SCI:
            v = row[i] if i < len(row) else None
            if v:
                bb.setdefault(v.strip(), row)

    righe = []  # (sci, pmin, pmax, umin, umax, nido)
    n_peso = n_uova = n_nido = 0
    for sci in sci_catalogo:
        row = bb.get(sci)
        if row is None:
            continue
        peso = _peso(row)
        cmin = _num(row, C_CMIN)
        cmax = _num(row, C_CMAX)
        nido = _nido(row)
        # Uova: solo se min/max coerenti e max entro la soglia di sanità.
        umin = umax = None
        if cmin is not None and cmax is not None:
            a, b = int(cmin), int(cmax)
            if 1 <= a <= b <= MAX_UOVA_PLAUSIBILE:
                umin, umax = a, b
        if peso is None and umin is None and nido is None:
            continue
        pmin, pmax = peso if peso else (None, None)
        if peso:
            n_peso += 1
        if umin is not None or umax is not None:
            n_uova += 1
        if nido:
            n_nido += 1
        righe.append((sci, pmin, pmax, umin, umax, nido))

    # scrive il seed (UPDATE ... FROM (VALUES ...)), idempotente.
    def sqlnum(x):
        return "NULL" if x is None else str(x)

    def sqltxt(x):
        return "NULL" if x is None else "'" + x.replace("'", "''") + "'"

    with open(SEED, "w") as f:
        f.write("-- Seed morfologia (BIRDBASE) generato da genera_seed_morfologia.py\n")
        f.write(f"-- Specie abbinate con almeno un tratto: {len(righe)}/{len(sci_catalogo)}.\n")
        f.write("-- Rieseguibile (aggiorna per nome_scientifico).\n")
        f.write("update specie as s set\n")
        f.write("  peso_min_g = v.pmin::int, peso_max_g = v.pmax::int,\n")
        f.write("  uova_min = v.umin::int, uova_max = v.umax::int, nido = v.nido\n")
        f.write("from (values\n")
        for i, (sci, pmin, pmax, umin, umax, nido) in enumerate(righe):
            virg = "" if i == len(righe) - 1 else ","
            f.write(
                f"  ('{sci.replace(chr(39), chr(39)*2)}', "
                f"{sqlnum(pmin)}, {sqlnum(pmax)}, {sqlnum(umin)}, {sqlnum(umax)}, "
                f"{sqltxt(nido)}){virg}\n"
            )
        f.write(") as v(sci, pmin, pmax, umin, umax, nido)\n")
        f.write("where s.nome_scientifico = v.sci;\n")

    # report
    print(f"Catalogo: {len(sci_catalogo)}  |  righe morfologia: {len(righe)}")
    print(f"  con peso: {n_peso}  |  con uova: {n_uova}  |  con nido: {n_nido}")
    print("\n=== MAPPA NIDO (codice -> italiano) ===")
    for k, v in NIDO_IT.items():
        print(f"  {k:3} -> {v}")
    print("\n=== CAMPIONE (10 comuni) ===")
    comuni = [
        "Parus major", "Erithacus rubecula", "Turdus merula", "Hirundo rustica",
        "Passer domesticus", "Falco peregrinus", "Cuculus canorus", "Upupa epops",
        "Apus apus", "Ardea cinerea",
    ]
    byid = {r[0]: r for r in righe}
    for c in comuni:
        r = byid.get(c)
        if not r:
            print(f"  {c:22} -> (non abbinata)")
            continue
        _, pmin, pmax, umin, umax, nido = r
        peso = "n/d" if pmin is None else (f"{pmin} g" if pmin == pmax else f"{pmin}–{pmax} g")
        uova = "n/d" if umin is None and umax is None else f"{umin}–{umax}"
        print(f"  {c:22} peso={peso:12} uova={uova:6} nido={nido or 'n/d'}")
    print(f"\nSeed scritto in {SEED}")


if __name__ == "__main__":
    main()
