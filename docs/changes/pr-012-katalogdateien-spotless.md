# pr-012 — Katalogdateien nach spotless formatieren

|        |                                                                  |
|--------|------------------------------------------------------------------|
| PR     | [WeierE1/WebGoat#12](https://github.com/WeierE1/WebGoat/pull/12) |
| Branch | `style/spotless-katalogdateien` → `main`                         |
| Merged | 2026-09-08 20:38 UTC                                             |
| Size   | +35 / −35 über 4 Dateien                                         |
| Issues | CRA-Private#44 (Vorbedingung), CRA-Private#10 (Nullbedingung)    |
| Review | Mensch                                                           |

## 1. Why

`main` war seit dem **27.08.2026 rot** — und der Grund waren **unsere eigenen**
Dateien, nicht Upstream-Code.

Im POM ist `spotless` mit `<goal>check</goal>` an den Build gebunden, und
`<markdown>` nimmt `<include>**/*.md</include>`. Der Change catalogue aus PR #2
und #3 schreibt Markdown-Tabellen kompakt; spotless will die Spalten
ausgerichtet. Aus Lauf
[33059656116](https://github.com/WeierE1/WebGoat/actions/runs/33059656116):

```
[ERROR] Failed to execute goal com.diffplug.spotless:spotless-maven-plugin:3.9.0:check
        (default) on project webgoat: The following files had format violations:
[ERROR]     docs/changes/pr-002-change-catalogue-anlegen.md
```

Derselbe Befund im Job *Pre-commit check*, wo der Hook `maven-spotless-apply` die
Dateien ändert und deshalb fehlschlägt.

**Warum es gerade jetzt anstand:** der Anhebungs-Agent aus CRA-Private#44 sollte
seinen ersten Live-Lauf auf diesem Fork machen. Erfolg ist dort *„ein Pull
Request, dessen Build grün ist"* (`spec.md` §18.4). Solange `main` rot ist, kann
kein Vorschlag grün sein — und die Zahl aus §30.3 bekäme als ersten Wert einen
Fehlschlag, der mit der Anhebung nichts zu tun hat. CRA-Private#44 nennt genau
das als Vorbedingung.

## 2. What changed

`mvn -B -ntp spotless:apply`, und das änderte **genau vier Dateien, alle von
uns**: `docs/changes/README.md` und die drei `pr-00*.md`. Kein Upstream-Code,
keine Konfigurationsänderung.

**Bewusst nicht gewählt:** `docs/changes/**` in der spotless-Konfiguration
auszuschließen. Das wäre eine Änderung an der Build-Konfiguration des
Testobjekts, und ein Fork, an dessen Konfiguration wir schrauben, taugt
schlechter als Messgegenstand.

**Folge für alle künftigen Einträge:** jeder neue Katalogeintrag in diesem Fork
muss ebenfalls spotless-formatiert sein, sonst ist `main` wieder rot.
`mvn spotless:apply` vor dem Commit, oder einmal `pre-commit install`.

## 3. Files

|                            Path                             | Change  |
|-------------------------------------------------------------|---------|
| `docs/changes/README.md`                                    | +10/−10 |
| `docs/changes/pr-001-renovate-konfiguration-description.md` | +11/−11 |
| `docs/changes/pr-002-change-catalogue-anlegen.md`           | +7/−7   |
| `docs/changes/pr-003-claude-md-rolle-regeln-katalog.md`     | +7/−7   |

## 4. Verification

```
$ mvn -B -ntp spotless:check      # vorher
[INFO] BUILD FAILURE   — 4 Dateien mit Formatverstößen
$ mvn -B -ntp spotless:apply && mvn -B -ntp spotless:check
[INFO] BUILD SUCCESS
```

CI des Pull Requests: `nullbedingung` grün aus `push` (4 min 07 s) **und** aus
`pull_request` (4 min 22 s).

Nach dem Merge auf `main`, Lauf
[34317247064](https://github.com/WeierE1/WebGoat/actions/runs/34317247064):
`Pre-commit check`, `build (ubuntu-latest)`, `build (macos-15-intel)`,
`build (windows-latest)` — **alle `success`**. Damit ist die Nullbedingung aus
CRA-Private#10 wieder erfüllt.

**Nicht geprüft, ausdrücklich:** ein vollständiger `mvn clean verify` auf der
Werkbank, auf der der Pull Request vorbereitet wurde. Dieses Repository verlangt
**Java 25** (`<java.version>25</java.version>`, CI: `temurin 25`); dort lief
JDK 21, und der Bau bricht vor dem Kompilieren ab. Den Rest hat die CI belegt.

## 5. Known gaps

- **Die Ursache bleibt bestehen:** spotless nimmt `**/*.md`, also fällt jede
  Markdown-Datei darunter, die wir dem Fork hinzufügen — seit PR #10 auch
  `.claude/PR-PROFILE.md`. Wer das vergisst, rötet `main` erneut.
- **Der Katalogeintrag zu diesem PR entstand erst später** (mit diesem Nachtrag),
  weil dieser Fork ihn *nach* dem Merge vorsah. Behoben im selben Pull Request
  wie dieser Eintrag.

## 6. Provenance

**Teilweise rekonstruiert am 09.09.2026.** Die Abschnitte 1 bis 3 stammen
wörtlich aus dem PR-Text, der zeitgleich geschrieben wurde; die
Nach-dem-Merge-Messung in Abschnitt 4 (Lauf 34317247064) ist am 09.09.2026
nachgetragen.
