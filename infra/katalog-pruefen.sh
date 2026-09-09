#!/usr/bin/env bash
# Tor fuer die Katalogpflicht: hat dieser Pull Request einen vollstaendigen
# Eintrag in docs/changes/?
#
#   bash infra/katalog-pruefen.sh <pr-nummer>
#
# Exit 0 = Eintrag vorhanden und vollstaendig (oder begruendet ausgenommen).
# Exit 1 = fehlt oder unvollstaendig; die Meldung nennt, was fehlt.
# Nichts wird veraendert.
#
# WARUM ES DAS GIBT: die Pflicht "Eintrag in docs/changes/" stand zwei Wochen in
# CLAUDE.md und wurde fuenfmal nicht erfuellt (pr-064 bis pr-068). Eine Regel,
# die nur in der Dokumentation existiert, wird beim ersten Zeitdruck
# durchbrochen -- dasselbe Argument, mit dem spec.md Paragraph 6 die
# Schichtgrenze maschinell prueft statt sie aufzuschreiben.
#
# Der Eintrag entsteht IM PR: Branch, Arbeit, PR oeffnen (jetzt ist die Nummer
# bekannt), Eintrag nachcommitten. Beim ersten Push ist dieses Tor deshalb rot,
# und das ist der vorgesehene Ablauf und kein Fehler.

set -uo pipefail

wurzel="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$wurzel"

nummer="${1:-}"
if [ -z "$nummer" ]; then
  echo "Aufruf: bash infra/katalog-pruefen.sh <pr-nummer>" >&2
  exit 2
fi

# Drei Stellen, drei Ziffern -- so heissen die Dateien.
key="pr-$(printf '%03d' "$nummer")"
fehler=0

meckern() { printf '  [FEHLT] %s\n         -> %s\n' "$1" "$2"; fehler=1; }
gut()     { printf '  [ ja  ] %s\n' "$1"; }

echo "== Katalogpflicht fuer PR #$nummer ($key) =="

# --- Zwei Ausnahmen. Beide erlaubt, beide sichtbar. -------------------------
#
# 1. ENGINE-VORGANG. Ein Vorschlag von Renovate oder von einem der Agenten
#    KANN keinen Katalogeintrag tragen: Paragraph 18.3 erlaubt ihm
#    ausschliesslich Manifest-Dateien, und `docs/changes/....md` ist keine --
#    das Umfangs-Tor aus #44 (Umfangstor.java) wuerde den Durchlauf verwerfen.
#    Ohne diese Ausnahme waere jeder Engine-PR rot, Paragraph 18.4 ("ein Pull
#    Request, dessen Build gruen ist") nie erfuellt und der Zaehler aus
#    Paragraph 30.3 dauerhaft 0 -- das Tor wuerde genau die Messung kaputtmachen,
#    fuer die es aufgestellt wurde.
#
#    Erkannt am Branchnamen, nicht am Autor: Renovate laeuft unter wechselnden
#    Identitaeten, der Branch-Praefix ist die stabile Angabe. Und der Job endet
#    GRUEN statt zu fehlen -- ein fehlender Check kann ein Ruleset blockieren.
#
# 2. [kein-katalog] im PR-Text, mit Begruendung durch einen Menschen.
if [ -n "${PR_BRANCH:-}" ]; then
  case "${PR_BRANCH}" in
    renovate/*|cra/anhebung/*|cra/migration/*)
      echo "  AUSGENOMMEN: Engine-Vorgang auf Branch '${PR_BRANCH}'."
      echo "  Ein Engine-PR darf nach Paragraph 18.3 nur Manifeste beruehren; ein"
      echo "  Katalogeintrag waere eine Umfangsverletzung und wuerde vom Tor aus #44"
      echo "  verworfen. Der Nachweis dieses Vorgangs ist der Nachweis-Block am PR"
      echo "  (Paragraph 12.1), nicht der Katalog."
      exit 0
      ;;
  esac
fi
if [ -n "${PR_BODY:-}" ] && printf '%s' "$PR_BODY" | grep -qF '[kein-katalog]'; then
  echo "  AUSGENOMMEN: der PR-Text enthaelt [kein-katalog]."
  echo "  Das ist erlaubt und wird hier absichtlich protokolliert, damit die"
  echo "  Ausnahme nicht still wirkt. Wer sie setzt, begruendet sie im PR-Text."
  exit 0
fi

# --- Gibt es die Detaildatei? -----------------------------------------------
# Glob ueber den Slug: der Dateiname traegt den Titel, den wir hier nicht kennen.
mapfile -t dateien < <(find docs/changes -maxdepth 1 -name "${key}-*.md" | sort)

if [ "${#dateien[@]}" -eq 0 ]; then
  meckern "docs/changes/${key}-<slug>.md" \
    "Eintrag anlegen (Skill change-catalogue). Sechs Abschnitte, Marken pending-datum-$(printf '%03d' "$nummer") und pending-size-$(printf '%03d' "$nummer") fuer Merged und Size."
  echo
  echo "Der Eintrag gehoert IN diesen PR, nicht dahinter. Ein Nachtrag kann"
  echo "Abschnitt 4 nicht mehr ehrlich fuellen -- siehe pr-064."
  exit 1
fi

if [ "${#dateien[@]}" -gt 1 ]; then
  meckern "genau eine Detaildatei" "gefunden: ${dateien[*]}"
fi

datei="${dateien[0]}"
gut "$datei"

# --- Die sechs Abschnitte, in dieser Reihenfolge -----------------------------
erwartet=("## 1. Why" "## 2. What changed" "## 3. Files" "## 4. Verification" "## 5. Known gaps" "## 6. Provenance")
for abschnitt in "${erwartet[@]}"; do
  if grep -qxF "$abschnitt" "$datei"; then
    gut "$abschnitt"
  else
    meckern "$abschnitt" "fehlt in $datei -- die sechs Abschnitte sind Pflicht und immer in derselben Reihenfolge"
  fi
done

# --- Abschnitt 5 und 6 duerfen nicht leer sein ------------------------------
# "Known gaps" leer ist laut Skill fast immer falsch, und Provenance
# entscheidet, ob der Rest vertrauenswuerdig ist.
for paar in "## 5. Known gaps:## 6. Provenance" "## 6. Provenance:"; do
  von="${paar%%:*}"
  bis="${paar#*:}"
  if [ -n "$bis" ]; then
    inhalt=$(awk -v v="$von" -v b="$bis" 'index($0,v)==1{f=1;next} index($0,b)==1{f=0} f' "$datei")
  else
    inhalt=$(awk -v v="$von" 'index($0,v)==1{f=1;next} f' "$datei")
  fi
  if [ -n "$(printf '%s' "$inhalt" | tr -d '[:space:]')" ]; then
    gut "$von hat Inhalt"
  else
    meckern "$von ist leer" "ein leerer Abschnitt 5 ist fast immer falsch; Abschnitt 6 entscheidet, ob der Rest belastbar ist"
  fi
done

# --- Steht der Eintrag im Index? -------------------------------------------
if grep -qF "$(basename "$datei")" docs/changes/README.md; then
  gut "im Index verlinkt"
else
  meckern "Indexzeile in docs/changes/README.md" \
    "Zeile einfuegen, neueste zuerst, mit [→]($(basename "$datei"))"
fi

# --- Marken: vorhanden ODER schon gefuellt ---------------------------------
#
# Vor dem Merge muessen die Marken da sein, damit die Pipeline sie fuellen kann.
# Nach dem Merge stehen dort Werte -- beides ist in Ordnung, nur "weder noch" ist
# ein Fehler.
#
# GESCHAUT WIRD NUR IN DEN ZWEI KOPFZEILEN UND IN DER INDEXZEILE, genau wie beim
# Fuellen. Ueber die ganze Datei zu grepen war der erste Versuch und falsch: ein
# Eintrag, der die Marke in Abschnitt 4 ZITIERT (weil dort die Ausgabe dieses
# Tores steht), sah danach aus wie ein ungefuellter Kopf. Gemessen an pr-069.
dreistellig="$(printf '%03d' "$nummer")"
kopfzeilen="$(grep -E '^\| (Merged|Size) \|' "$datei" || true)"
indexzeile="$(grep -F "$(basename "$datei")" docs/changes/README.md || true)"

for feld in datum size; do
  marke="pending-${feld}-${dreistellig}"
  imKopf=$(printf '%s' "$kopfzeilen" | grep -cF "$marke" || true)
  imIndex=$(printf '%s' "$indexzeile" | grep -cF "$marke" || true)
  if [ "$imKopf" -gt 0 ] && [ "$imIndex" -gt 0 ]; then
    gut "Marke $marke in Kopftabelle und Indexzeile (Pipeline fuellt sie beim Merge)"
  elif [ "$imKopf" -gt 0 ] || [ "$imIndex" -gt 0 ]; then
    meckern "Marke $marke nur an einer Stelle" \
      "sie muss in der Kopftabelle UND in der Indexzeile stehen, sonst fuellt die Pipeline nur eine"
  else
    echo "  [ ok  ] keine Marke $marke -- Feld ist schon gefuellt"
  fi
done

echo
if [ "$fehler" -eq 0 ]; then
  echo "Katalogpflicht erfuellt."
else
  echo "Katalogpflicht NICHT erfuellt -- siehe die -> Zeilen oben."
fi
exit "$fehler"
