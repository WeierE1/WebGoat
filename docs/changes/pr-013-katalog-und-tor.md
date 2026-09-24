# pr-013 — Katalogrückstand aufholen und das Tor mitziehen

|        |                                                                  |
|--------|------------------------------------------------------------------|
| PR     | [WeierE1/WebGoat#13](https://github.com/WeierE1/WebGoat/pull/13) |
| Branch | `docs/katalog-und-tor` → `main`                                  |
| Merged | 2026-09-09 09:07 UTC                                             |
| Size   | +799 / −8 über 9 Dateien                                         |
| Issues | CRA-Private#44 (Nachlauf)                                        |
| Review | Mensch                                                           |

## 1. Why

Drei gemergte Pull Requests dieses Forks hatten keinen Katalogeintrag: #9, #10
und #12. Die Pflicht steht seit dem 27.08.2026 09:37 UTC in der `CLAUDE.md`
(PR #3) — der früheste fehlende PR wurde **drei Minuten später** gemergt. Es lag
also nicht am Alter, sondern am Mechanismus: es gab **kein Tor**, und der
Wortlaut sagte *„nach jedem gemergten PR"* statt *„im PR"*.

## 2. What changed

- **Die drei fehlenden Einträge** (`pr-009`, `pr-010`, `pr-012`), jeder mit den
  sechs Pflichtabschnitten und einem ehrlichen Abschnitt 6: sie sind
  **rekonstruiert**, nicht zeitgleich geschrieben.
- **Das Tor:** `.github/workflows/katalog.yml` plus `infra/katalog-pruefen.sh`
  und `infra/katalog-nachtragen.sh`, wörtlich aus `CRA-Private`. Kein Secret,
  GitHub-gehostet, fasst den Bau nicht an.
- **Der Wortlaut in `CLAUDE.md`:** der Eintrag gehört ab jetzt **in** den Pull
  Request; die Marken `pending-datum-NNN` / `pending-size-NNN` füllt die Pipeline
  beim Merge.
- **Ein toter Verweis behoben:** `CRA-Private/LEARNINGS.md` gibt es seit
  `a0db55a` nicht mehr — es ist `docs/solutions/`.

**Die Ausnahme, ohne die das Tor mehr kaputtmacht als es hilft:** ein Engine-PR
*kann* keinen Katalogeintrag tragen — er darf nach `spec.md` §18.3
**ausschließlich Manifeste** berühren. Ohne Ausnahme wäre jeder Renovate- und
Agenten-PR hier rot, §18.4 nie erfüllt und die Zahl aus §30.3 dauerhaft 0.
Branches `renovate/**`, `cra/anhebung/**`, `cra/migration/**` sind deshalb
ausgenommen — am Branch erkannt, laut protokolliert, Exit 0.

## 3. Files

|                            Path                             |        Change         |
|-------------------------------------------------------------|-----------------------|
| `docs/changes/pr-009-…`, `pr-010-…`, `pr-012-…`, `pr-013-…` | neu                   |
| `docs/changes/README.md`                                    | vier Indexzeilen      |
| `.github/workflows/katalog.yml`                             | neu                   |
| `infra/katalog-pruefen.sh`, `infra/katalog-nachtragen.sh`   | neu                   |
| `CLAUDE.md`                                                 | Katalogabsatz ersetzt |

## 4. Verification

```
bash infra/katalog-pruefen.sh 9|10|12|13   → Katalogpflicht erfuellt
PR_BRANCH=renovate/x            … 999      → AUSGENOMMEN: Engine-Vorgang (Exit 0)
PR_BRANCH=docs/katalog-und-tor  … 999      → Exit 1   (richtig: rot ohne Eintrag)
mvn -B -ntp spotless:check                 → BUILD SUCCESS
```

**Das Tor hat sich beim ersten Lauf selbst bewiesen.** Der erste Push dieses Pull
Requests enthielt die Einträge für #9, #10 und #12 — aber keinen für **sich
selbst**, und `pruefen` wurde rot. Genau die Lücke, die dieser PR beschreibt
(PR #9 hatte sie im eigenen Text vorhergesagt und nie geschlossen), fing das Tor
in dem Moment, in dem es scharf war. Dieser Eintrag ist die Antwort darauf.

## 5. Known gaps

- **Drei Dateien liegen jetzt doppelt** (`katalog.yml` und die zwei Skripte, hier
  und in `CRA-Private`). Bewusste Doppelung: `CRA-Private` ist privat, ein Fork
  kann das Skript nicht holen. Sie driftet, wenn jemand nur eine Kopie ändert.
- **Ein Workflow mehr im Testobjekt.** Er prüft nur unsere eigenen Dateien, aber
  der Fork entfernt sich damit ein Stück weiter vom Upstream.
- **Die Ausnahme kennt drei Branch-Präfixe.** Ein vierter (ein neuer Agent) fiele
  als *rotes Tor* auf, nicht still — die sichere Richtung, aber sie kostet einen
  Handgriff.
- **Jeder künftige Eintrag muss spotless-formatiert sein** (`**/*.md`), sonst ist
  `main` wieder rot. `mvn spotless:apply` vor dem Commit.

## 6. Provenance

**Zeitgleich geschrieben**, im Pull Request und vor dem Merge — anders als die
drei Einträge, die er nachträgt.
