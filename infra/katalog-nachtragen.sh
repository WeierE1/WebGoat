#!/usr/bin/env bash
# Fuellt die zwei Felder, die vor dem Merge niemand kennen kann:
# Merge-Zeitpunkt und endgueltige Groesse.
#
#   bash infra/katalog-nachtragen.sh <pr-nummer>
#
# Ersetzt in der Detaildatei UND in der Indexzeile:
#   pending-datum-NNN  ->  2026-08-27 13:21
#   pending-size-NNN   ->  +718/-3 ueber 8 Dateien   (Detaildatei)
#                          +718/-3 · 8               (Index, kompakt)
#
# Exit 0 = gefuellt oder nichts zu tun. Exit 1 = etwas stimmt nicht.
#
# Braucht `gh` und einen Token mit Leserecht auf das Repository. Aendert nur
# docs/changes/; committet NICHT -- das tut der Workflow, damit dieses Skript
# auch von Hand gefahrlos laufen kann.
#
# WARUM NICHT DER MENSCH: weil er es nicht tut. Die Pflicht "Eintrag in
# docs/changes/" wurde fuenfmal versaeumt, und ein Feld, das beim Merge von Hand
# nachgetragen werden muss, ist genau so ein Versaeumnis mit Ansage.

set -uo pipefail

wurzel="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$wurzel"

nummer="${1:-}"
if [ -z "$nummer" ]; then
  echo "Aufruf: bash infra/katalog-nachtragen.sh <pr-nummer>" >&2
  exit 2
fi

dreistellig="$(printf '%03d' "$nummer")"
key="pr-${dreistellig}"

mapfile -t dateien < <(find docs/changes -maxdepth 1 -name "${key}-*.md" | sort)
if [ "${#dateien[@]}" -ne 1 ]; then
  echo "FEHLER: genau eine Detaildatei ${key}-*.md erwartet, gefunden: ${#dateien[@]}" >&2
  exit 1
fi
datei="${dateien[0]}"
index="docs/changes/README.md"

marke_datum="pending-datum-${dreistellig}"
marke_size="pending-size-${dreistellig}"

if ! grep -qF "$marke_datum" "$datei" "$index" 2>/dev/null \
   && ! grep -qF "$marke_size" "$datei" "$index" 2>/dev/null; then
  echo "Nichts zu tun: keine Marke fuer $key mehr vorhanden."
  exit 0
fi

# --- Werte holen. Nicht abtippen. -------------------------------------------
json=$(gh pr view "$nummer" --json mergedAt,additions,deletions,changedFiles,state) || {
  echo "FEHLER: gh pr view $nummer fehlgeschlagen." >&2
  exit 1
}

zustand=$(printf '%s' "$json" | sed -n 's/.*"state":"\([A-Z]*\)".*/\1/p')
if [ "$zustand" != "MERGED" ]; then
  echo "FEHLER: PR #$nummer hat den Zustand '$zustand', nicht MERGED." >&2
  echo "        Die Marken werden erst beim Merge gefuellt -- ein Datum, das" >&2
  echo "        vor dem Merge eingesetzt wird, ist eine Erfindung." >&2
  exit 1
fi

roh_datum=$(printf '%s' "$json" | sed -n 's/.*"mergedAt":"\([^"]*\)".*/\1/p')
plus=$(printf '%s' "$json"      | sed -n 's/.*"additions":\([0-9]*\).*/\1/p')
minus=$(printf '%s' "$json"     | sed -n 's/.*"deletions":\([0-9]*\).*/\1/p')
anzahl=$(printf '%s' "$json"    | sed -n 's/.*"changedFiles":\([0-9]*\).*/\1/p')

for wert in roh_datum plus minus anzahl; do
  if [ -z "${!wert}" ]; then
    echo "FEHLER: Feld '$wert' liess sich nicht aus der Antwort lesen." >&2
    exit 1
  fi
done

# 2026-08-27T13:21:13Z -> 2026-08-27 13:21. UTC, ohne Umrechnung: GitHub liefert
# Z-suffigiert, und eine in Ortszeit umgerechnete Spalte mit der Aufschrift UTC
# ist um den Offset falsch und sieht richtig aus.
datum="${roh_datum:0:10} ${roh_datum:11:5}"

size_lang="+${plus} / −${minus} über ${anzahl} Dateien"
size_kurz="+${plus}/−${minus} · ${anzahl}"

echo "PR #$nummer gemergt $datum UTC, $size_kurz"

# --- Ersetzen, aber NUR in den zwei Kopfzeilen ------------------------------
#
# GELERNT BEIM ERSTEN NACHTRAGEN (pr-069): ein globales `s|marke|wert|g` ersetzt
# die Marke auch dort, wo sie als ZITAT steht -- im Ausgabeblock von Abschnitt 4
# stand `[ ja ] Marke pending-datum-069 in Detaildatei und Index`, und daraus
# wurde `[ ja ] Marke 2026-08-27 13:55 UTC in ...`. Das ist ein umgeschriebener
# Nachweis, und genau das verbietet spec.md Paragraph 20.4: Nachweise werden
# annotiert, nie umgeschrieben.
#
# Deshalb adressiert: in der Detaildatei nur die Kopfzeilen `| Merged |` und
# `| Size |`, im Index nur die Zeile, die auf diese Detaildatei verlinkt.
sed -i \
  -e "/^| Merged |/s|${marke_datum}|${datum} UTC|" \
  -e "/^| Size |/s|${marke_size}|${size_lang}|" \
  "$datei"
sed -i \
  -e "\|$(basename "$datei")|{s|${marke_datum}|${datum}|; s|${marke_size}|${size_kurz}|;}" \
  "$index"

# --- Gegenprobe: in den Kopfzeilen und der Indexzeile darf nichts uebrig sein
if grep -E "^\| (Merged|Size) \|" "$datei" | grep -qF "pending-"; then
  echo "FEHLER: nach dem Ersetzen steht in der Kopftabelle noch eine Marke." >&2
  grep -nE "^\| (Merged|Size) \|" "$datei" >&2
  exit 1
fi
if grep -F "$(basename "$datei")" "$index" | grep -qF "pending-"; then
  echo "FEHLER: nach dem Ersetzen steht in der Indexzeile noch eine Marke." >&2
  grep -nF "$(basename "$datei")" "$index" >&2
  exit 1
fi

echo "Gefuellt:"
grep -nE '^\| (Merged|Size) \|' "$datei" | sed 's/^/  /'
grep -nF "$(basename "$datei")" "$index" | sed 's/^/  /'
