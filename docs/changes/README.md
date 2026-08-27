# Change catalogue

Ein Eintrag je gemergtem Pull Request **dieses Forks**. Konvention und
Begründung: `docs/changes/` im Automatisierungs-Repository
[`WeierE1/CRA-Private`](https://github.com/WeierE1/CRA-Private/tree/main/docs/changes).

**Was dieses Repository ist:** ein Fork von `WebGoat/WebGoat`, Testobjekt des
CRA-Piloten. Seine Rolle: der **BOM-Fall** (§18 — rund 44 von 69 Abhängigkeiten
ohne eigenes `<version>`) und die **große Testsuite** (306 Unit + 65 Integration),
an der das Testintegritäts-Tor arbeitet. Die Upstream-Historie gehört nicht zu
diesem Katalog.

<!-- INDEX:BEGIN -->

| PR | Merged (UTC) | Title | Issues | Size | Detail |
|---|---|---|---|---|---|
| [pr-003](https://github.com/WeierE1/WebGoat/pull/3) | 2026-08-27 09:37 | CLAUDE.md: Rolle im CRA-Piloten, Regeln, Katalog-Pflicht | — | +31/−0 · 1 | [→](pr-003-claude-md-rolle-regeln-katalog.md) |
| [pr-002](https://github.com/WeierE1/WebGoat/pull/2) | 2026-08-27 09:30 | Change catalogue anlegen | — | +81/−0 · 2 | [→](pr-002-change-catalogue-anlegen.md) |
| [pr-001](https://github.com/WeierE1/WebGoat/pull/1) | 2026-08-27 07:05 | Renovate-Konfiguration: description statt // | CRA-Private#24 | +7/−9 · 1 | [→](pr-001-renovate-konfiguration-description.md) |

<!-- INDEX:END -->

## Was der Katalog nicht abdeckt

**Vier Commits erreichten den Standardzweig direkt, ohne PR und ohne Review** —
per Contents-API, bevor das Ruleset `kein-merge-durch-automatik` (27.08.2026)
den Direktpush unterband:

| Commit | Datum | Was |
|---|---|---|
| `8e06dec7` | 26.08. 08:11 | `nullbedingung.yml` — CI-Workflow nach spec.md §34, JDK 25 festgenagelt |
| `bfa8f870` | 26.08. 08:59 | SBOM-Schritt (CycloneDX 2.8.0), V8-Messung, Integritätslog |
| `78be6d5e` | 26.08. 09:05 | Test: liefert 2.9.1 den Maven-Scope? (Ergebnis: nein) |
| `4767d287` | 27.08. 07:02 | erste `renovate.json` — trug noch `//`-Schlüssel, korrigiert in pr-001 |

Begründung und Verifikation stehen in pr-051, pr-053 und pr-058 des
Automatisierungs-Repositories. Bekannter Flake dieses Forks:
`LoginUITest.loginLogout` (belegt, Lauf 32950956266) — gehört in `PR-PROFILE.md`.
