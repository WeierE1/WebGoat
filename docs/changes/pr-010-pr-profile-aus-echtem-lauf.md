# pr-010 — PR-PROFILE.md aus echtem Lauf

|        |                                                                  |
|--------|------------------------------------------------------------------|
| PR     | [WeierE1/WebGoat#10](https://github.com/WeierE1/WebGoat/pull/10) |
| Branch | `cra/pr-profile` → `main`                                        |
| Merged | 2026-09-09 06:01 UTC                                             |
| Size   | +129 / −0 über 1 Datei                                           |
| Issues | CRA-Private#35                                                   |
| Review | Mensch                                                           |

## 1. Why

Der Skill `pr-check` und die Vorprüfung aus `spec.md` §22.1 brauchen je
Repository ein Profil: welche Prüfungen laufen, was der **Vorbestand** ist (rote
und abgeschaltete Tests, die es schon vor einer Änderung gab), wie lange ein Lauf
dauert, welches JDK. Ohne diese Angaben liest ein Reviewer jeden vorhandenen
Fehlschlag als neu.

## 2. What changed

`.claude/PR-PROFILE.md`, **aus einem echten Lauf** und nicht aus der
Konfiguration abgeschrieben — das ist die Regel aus `spec.md` §32: *ausführen und
die Ausgabe zitieren.*

- Grüner Referenzlauf (`nullbedingung`, `main`):
  [33048299994](https://github.com/WeierE1/WebGoat/actions/runs/33048299994),
  27.08.2026
- Surefire `306/0/0, Skipped: 1` plus Failsafe `65/0/0/0` — **Vorbestand: 0 rot,
  1 abgeschaltet** (`SqlInjectionLesson5aTest`), deckungsgleich mit
  CRA-Private#10
- Laufzeiten: `nullbedingung` 3 min 31 s, `Main / Pull requests build` grün
  15 min 31 s
- JDK 25 (Temurin, festgenagelt)
- Der Flake `LoginUITest.loginLogout` steht **namentlich** im Profil — nicht als
  Ausnahmeliste, sondern als benannter Preis (CRA-Private, Naht 2,
  Entscheidung 5: *kein Flake-Wissen, rot ist rot*)

## 3. Files

|          Path           | Change  |
|-------------------------|---------|
| `.claude/PR-PROFILE.md` | +129/−0 |

## 4. Verification

CI dieses Pull Requests: **alle Checks grün**, einschließlich der vollen Matrix —
`Pre-commit check`, `build (ubuntu-latest)`, `build (macos-15-intel)`,
`build (windows-latest)` sowie beide `nullbedingung`-Läufe.

Der grüne `Pre-commit check` ist hier mehr als Formsache: er belegt, dass die neue
Markdown-Datei die spotless-Regel `**/*.md` dieses Forks erfüllt — dieselbe Regel,
an der `main` bis PR #12 gescheitert war.

## 5. Known gaps

- **Das Profil altert.** Vorbestand, Laufzeiten und JDK stammen vom 27.08.2026;
  ändert sich der Fork, stimmt das Profil still nicht mehr. Es trägt sein
  Messdatum, damit das auffällt.
- **`.claude/PR-PROFILE.md` fällt ab jetzt unter spotless** (`**/*.md`). Wer die
  Datei fortschreibt, ohne `mvn spotless:apply` zu laufen, rötet `main`.

## 6. Provenance

**Teilweise rekonstruiert am 09.09.2026.** Abschnitte 1 bis 3 stammen aus dem
zeitgleich geschriebenen PR-Text; die Check-Liste in Abschnitt 4 ist am
09.09.2026 aus `gh pr checks 10` nachgetragen.
