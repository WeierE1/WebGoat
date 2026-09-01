# PR-PROFILE — WeierE1/WebGoat

Profil für den Skill `pr-check` und die §22.1-Vorprüfung des Migrations-Agenten
(WeierE1/CRA-Private, Issue #35). **Alle Zahlen stammen aus einem echten Lauf,
nicht aus der Konfiguration** — Beleg ist jeweils die Lauf-ID.

Default-Branch: `main`.

## Welche Branches die CI auslöst

Zwei aktive Workflows, zwei inerte:

- `.github/workflows/nullbedingung.yml` (Name: `nullbedingung`) — **jeder Push
  auf jeden Branch, jeder Pull Request, dazu manuell** (`push:` /
  `pull_request:` / `workflow_dispatch:` ohne Filter).
- `.github/workflows/build.yml` (Name: `Main / Pull requests build`) — Pushes
  auf `main` und Pull Requests **gegen `main`**, dort mit `paths-ignore` für
  `.txt`, `LICENSE` und `docs/**`.
- `release.yml` reagiert nur auf Tags und ist zusätzlich an
  `repository == 'WebGoat/WebGoat'` gebunden — **auf diesem Fork inert.**
  `welcome.yml` (Issues) ebenso.
- `branchbuild.txt` ist als `.txt` abgelegt und damit **kein** Workflow.

## Die echten Build- und Testkommandos

Wörtlich aus den Workflows (nicht aus dem README):

- `nullbedingung`: `mvn -B -ntp verify`, danach (auch bei rot) Surefire-XML als
  Artefakt `surefire-reports` und SBOM per
  `mvn -B -ntp org.cyclonedx:cyclonedx-maven-plugin:2.9.1:makeAggregateBom`.
- `Main / Pull requests build`: erst ein `pre-commit`-Job (Hooks u. a.
  `mvn clean compile` und `maven-spotless-apply`), dann
  `mvn --no-transfer-progress verify` in einer Matrix aus `windows-latest`,
  `ubuntu-latest`, `macos-15-intel` mit `max-parallel: 1` (seriell).

Wichtig für jede Fehlerdeutung: `verify` führt **spotless:check** aus, und der
prüft neben Java auch **jede `*.md`-Datei** (flexmark). Ein roter Lauf kann
also ein reiner Formatverstoß sein, bei dem **kein einziger Test lief.**

## Festgenagelte JDK-Version

**JDK 25** (Temurin, x64). In `nullbedingung.yml` direkt festgenagelt, in
`build.yml` über die Composite-Action `.github/actions/java-setup`, die
ebenfalls Temurin 25 setzt.

## Altlasten (Vorbestand)

Aus dem letzten grünen `nullbedingung`-Lauf auf `main`,
[33048299994](https://github.com/WeierE1/WebGoat/actions/runs/33048299994)
(2026-08-27):

- Surefire (Unit): `Tests run: 306, Failures: 0, Errors: 0, Skipped: 1`
- Failsafe (Integration/Playwright): `Tests run: 65, Failures: 0, Errors: 0, Skipped: 0`

Also **371 Tests, 0 vorbestehend rot, genau 1 vorbestehend abgeschaltet**:
`org.owasp.webgoat.lessons.sqlinjection.introduction.SqlInjectionLesson5aTest`
(dieselbe Zahl wie in CRA-Private Issue #10). Surefire schließt
`**/*IntegrationTest.java` und `**/*UITest.java` aus; die UI-Tests laufen als
Failsafe-Integrationstests aus `src/it`.

**Aktueller Zustand von `main` (Stand 2026-09-01): rot, aber nicht wegen
Tests.** Seit 2026-08-27 scheitert `spotless:check` (spotless-maven-plugin
3.9.0) an Formatverstößen in `docs/changes/pr-001…pr-003…*.md` — der Build
stirbt **vor** den Tests (Beleg: Lauf
[33059656116](https://github.com/WeierE1/WebGoat/actions/runs/33059656116)).
Für die §22.1-Vorprüfung heißt das: „Zielzweig rot" ist hier zurzeit ein
Format-, kein Testbefund. Die Testbasis ist der oben zitierte grüne Lauf.

## Laufzeit eines vollständigen Laufs

- `nullbedingung`: **3 min 31 s** (Lauf 33048299994; Maven selbst: 02:58 min).
- `Main / Pull requests build`: **15 min 31 s** grün (Lauf
  [33048299964](https://github.com/WeierE1/WebGoat/actions/runs/33048299964)) —
  die serielle 3-OS-Matrix kostet den Faktor.

Für §22.4: eine Dreierschleife über `nullbedingung` kostet ~11 min und ist
bezahlbar; über die OS-Matrix kostet sie ~45 min und ist es kaum.

## Bekannte Flakes

- **`LoginUITest.loginLogout`** (Playwright, `src/it`): belegter Flake,
  rot→grün auf demselben Commit (dokumentiert in CRA-Private `STATUS.md`,
  2026-08-26, dortige Lauf-Referenz 32950956266; der Lauf ist inzwischen nicht
  mehr abrufbar — vermutlich durch einen Re-Run ersetzt). Ein roter
  `loginLogout` allein ist **kein** Migrationsfall: erst Re-Run, dann urteilen.
- **Plugin-Auflösung auf `macos-15-intel`**: Lauf
  [32950622438](https://github.com/WeierE1/WebGoat/actions/runs/32950622438)
  scheiterte, weil `spotless-maven-plugin:3.9.0` nicht aufgelöst werden konnte
  (Repo-/Netzfehler des Runners); derselbe Stand baute auf `ubuntu-latest` und
  `windows-latest` grün. Infrastruktur-, kein Projektbefund.

