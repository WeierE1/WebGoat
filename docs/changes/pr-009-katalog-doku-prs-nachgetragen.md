# pr-009 — Katalog: Doku-PRs nachgetragen

|        |                                                                |
|--------|----------------------------------------------------------------|
| PR     | [WeierE1/WebGoat#9](https://github.com/WeierE1/WebGoat/pull/9) |
| Branch | `docs/katalog-nachtrag` → `main`                               |
| Merged | 2026-08-27 09:40 UTC                                           |
| Size   | +72 / −0 über 3 Dateien                                        |
| Issues | —                                                              |
| Review | kein menschliches Review; Merge durch den Repo-Inhaber         |

## 1. Why

Die Katalogpflicht kam mit PR #3 (`CLAUDE.md`, 09:37 UTC). PR #1 und #2 waren zu
diesem Zeitpunkt schon gemergt und hatten deshalb keinen Eintrag. Dieser PR trug
sie nach.

## 2. What changed

Einträge für `pr-002` (Change catalogue anlegen) und `pr-003` (CLAUDE.md: Rolle
im CRA-Piloten) plus die zugehörigen Indexzeilen. `pr-001` war bereits Teil von
PR #2.

**Der PR-Text nannte die Lücke, die er selbst erzeugte** — wörtlich:

> Dieser Nachtrags-PR selbst bekommt seinen Eintrag mit dem naechsten Nachzug —
> der jeweils letzte Katalog-PR ist naturgemaess noch nicht im Katalog.

Der „nächste Nachzug" kam nicht. Dieser Eintrag ist er, dreizehn Tage später.

## 3. Files

|                          Path                           | Change |
|---------------------------------------------------------|--------|
| `docs/changes/README.md`                                | +2/−0  |
| `docs/changes/pr-002-change-catalogue-anlegen.md`       | +35/−0 |
| `docs/changes/pr-003-claude-md-rolle-regeln-katalog.md` | +35/−0 |

## 4. Verification

Nur Dokumentation; kein Bau, keine Tests berührt. Die CI dieses Forks lief auf
dem Merge-Commit und war grün.

**Ehrlich gesagt:** was 2026-08-27 tatsächlich geprüft wurde, ist heute nicht
mehr rekonstruierbar. Dieser Abschnitt ist deshalb dünn — genau der Grund, warum
`CRA-Private` den Eintrag inzwischen **in** den Pull Request verlangt und mit
einem Tor erzwingt.

## 5. Known gaps

- **Der Eintrag entstand 13 Tage nach dem Merge.** Abschnitt 4 kann deshalb nicht
  mehr leisten, was er soll.
- **Die Ursache war strukturell und blieb es bis heute:** ein Katalog, der *nach*
  dem Merge gepflegt wird, kann nie vollständig sein — der Nachtrag ist selbst
  ein gemergter Pull Request und erzeugt die nächste Lücke. Genau das ist hier
  passiert, und der PR-Text sagte es voraus. Behoben wird es mit dem Tor, das im
  selben Pull Request wie dieser Eintrag in den Fork kommt.

## 6. Provenance

**Rekonstruiert am 09.09.2026**, nicht zeitgleich geschrieben. Quellen:
`gh pr view 9` (Titel, Zeitpunkt, Größe, Dateiliste, PR-Text). Eine
rekonstruierte Quelle ist schwächer als eine zeitgleiche, und der Leser soll das
wissen.
