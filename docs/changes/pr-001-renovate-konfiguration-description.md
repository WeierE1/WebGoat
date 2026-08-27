# pr-001 — Renovate-Konfiguration: description statt //

| | |
|---|---|
| PR | [WeierE1/WebGoat#1](https://github.com/WeierE1/WebGoat/pull/1) |
| Branch | `fix/renovate-config` → `main` |
| Merged | 2026-08-27 07:05 UTC |
| Size | +7 / −9 über 1 Datei |
| Issues | CRA-Private#24 (Schritt H) |
| Review | kein menschliches Review; Merge durch den Repo-Inhaber |

## 1. Why

Renovate 44.46.2 lehnt `//`-Schlüssel als JSON-Kommentar ab
(`Invalid configuration option: //`) — der erste schreibende Lauf scheiterte
daran in beiden Forks.

## 2. What changed

`renovate.json` auf `description` umgestellt; erweitert weiter das gemeinsame
Preset `github>WeierE1/CRA-Private//renovate-presets/kontext-a` (spec.md §15.3 —
je Fork nur wirklich Lokales).

## 3. Files

| Path | Change |
|---|---|
| `renovate.json` | +7/−9 |

## 4. Verification

Vorlage mit `renovate-config-validator` geprüft
(`Config validated successfully against 4 file(s)`, im Automatisierungs-Repo).
Bemerkenswert am Weg: **der Direktpush wurde vom frisch gesetzten Ruleset mit
409 abgelehnt** — dieser PR existiert, weil die Leitplanke funktioniert hat.

## 5. Known gaps

Der erste schreibende Renovate-Lauf gegen diesen Fork stand zum Merge-Zeitpunkt
noch aus (Engine-PAT ohne Push-Recht).

## 6. Provenance

Geschrieben am 2026-08-27, am Merge-Tag, aus der Arbeitssitzung, die den PR
verfasst hat.
