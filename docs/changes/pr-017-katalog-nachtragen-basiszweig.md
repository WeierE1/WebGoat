# pr-017 — katalog nachtragen: Zielzweig aus dem Ereignis, Ruleset-Fall eindeutig

|        |                                                                  |
|--------|------------------------------------------------------------------|
| PR     | [WeierE1/WebGoat#17](https://github.com/WeierE1/WebGoat/pull/17) |
| Branch | `fix/katalog-nachtragen-basiszweig` → `main`                     |
| Merged | pending-datum-017                                                |
| Size   | pending-size-017                                                 |
| Issues | —                                                                |
| Review | offen (Mensch)                                                   |

## 1. Why

Der Push des Jobs `nachtragen` scheiterte am Ruleset
`kein-merge-durch-automatik` (`bypass_actors: []`) — gemessen 24.09.2026,
Lauf 35985931079: `remote: error: GH013: Repository rule violations found
for refs/heads/main.` Die Schleife hielt das für einen Wettlauf und
versuchte es dreimal mit Rebase. Derselbe Fehler seit dem 09.09.2026 — die
Marken von pr-013 standen seither offen. Das Literal `main` ist hier zwar
richtig (Standardzweig `main`), die Datei soll aber in allen drei Forks
gleich sein, und in den beiden petclinic-Forks war es falsch.

Entscheidung des Menschen vom 24.09.2026: das Ruleset bekommt **keine**
Ausnahme für GitHub Actions (§32/16 bleibt ohne Ausnahme). Der Job bleibt
hier also rot — aber mit einer Meldung, die sagt, was zu tun ist.

## 2. What changed

`.github/workflows/katalog.yml`, nur Job `nachtragen` (Job `pruefen` und
`permissions` unverändert; die Datei ist in allen drei Forks byte-gleich):

- Zielzweig aus dem Ereignis statt Literal `main`: `env: BASIS:
  ${{ github.event.pull_request.base.ref }}` auf Jobebene;
  `actions/checkout` mit `ref: ${{ github.event.pull_request.base.ref }}`;
  Push als `git push origin "HEAD:refs/heads/$BASIS"`, Rebase gegen
  `"$BASIS"`. In `run:` steht der Zweigname nur als Umgebungsvariable, nie
  als Ausdruck (Skript-Injektion über Zweignamen).
- Ruleset-Fall: enthält die Push-Ausgabe `GH013` oder `Repository rule
  violations`, wird nicht erneut versucht. Meldung in `$GITHUB_STEP_SUMMARY`
  und stderr („Ruleset verlangt einen Pull Request auf <Zweig> -- Marken
  dieses PR im naechsten PR von Hand fuellen: bash
  infra/katalog-nachtragen.sh <nr> …") und Exit 1. Andere Push-Fehler
  behalten Rebase und bis zu drei Versuche.
- PR-Nummer für die Meldung über `env: NUMMER` des Commit-Schritts.

`infra/katalog-nachtragen.sh` enthält kein fest verdrahtetes `main` und ist
unverändert.

Offene Marken gefüllt:

- pr-013 → Merged `2026-09-09 09:07 UTC`, Size `+799 / −8 über 9 Dateien`.
- pr-016 → Merged `2026-09-24 10:12 UTC`, Size `+65 / −10 über 3 Dateien`.

Merged und Indexzeile mit `GH_REPO=WeierE1/WebGoat bash
infra/katalog-nachtragen.sh <nr>`. **Die Kopfzeile Size nicht:** spotless
richtet die Tabelle aus (`| Size   |`), das Skript adressiert nur `| Size |`,
lässt die Marke stehen und meldet trotzdem Exit 0 — seine Gegenprobe hat
dasselbe Muster. Dort ist derselbe Wert, aus `gh pr view` gebildet wie im
Skript, mit einem ausrichtungstoleranten `sed` eingesetzt. Danach
`mvn -B -ntp spotless:apply`.

## 3. Files

|                          Path                          |                        Change                        |
|--------------------------------------------------------|------------------------------------------------------|
| `.github/workflows/katalog.yml`                        | Job `nachtragen`: Zielzweig, Ruleset-Fall            |
| `docs/changes/pr-013-katalog-und-tor.md`               | Marken gefüllt                                       |
| `docs/changes/pr-016-renovate-preset-umzug.md`         | Marken gefüllt                                       |
| `docs/changes/README.md`                               | Indexzeilen pr-013/pr-016 gefüllt, Indexzeile pr-017 |
| `docs/changes/pr-017-katalog-nachtragen-basiszweig.md` | neu                                                  |

## 4. Verification

- Commit-Schritt aus der Datei ausgeschnitten und mit einem Stub für `git`
  gefahren (`BASIS=1.5.x`, `NUMMER=104`): GH013 → Meldung auf stderr und in
  der Zusammenfassung, **ein** Push-Versuch, Exit 1; Ablehnung ohne GH013 →
  drei Rebase-Versuche, dann „Push nach drei Versuchen nicht moeglich.",
  Exit 1; Erfolg → `HEAD:refs/heads/<BASIS>`, Exit 0.
- `grep -n main .github/workflows/katalog.yml` trifft nur noch Kommentare.
- Mojibake-Prüfung (`grep -c` auf U+00C3 über `docs/changes/*.md`): 0.
- `bash infra/katalog-pruefen.sh 17`: Katalogpflicht erfüllt (lokal vor dem
  Push).
- `actionlint` liegt nicht vor und wurde nicht installiert. Dass GitHub die
  Datei parst, belegt der Lauf von `katalog / pruefen` an diesem PR.

## 5. Known gaps

- **`nachtragen` bleibt nach dem Merge rot** am Ruleset (GH013), mit der
  Meldung, welche Marken im nächsten PR von Hand zu füllen sind. Entschieden
  24.09.2026, kein neuer Befund. Die Marken **dieses** PR füllt der nächste
  PR: `bash infra/katalog-nachtragen.sh 17` — und die Kopfzeile Size dabei
  von Hand, siehe nächster Punkt.
- **`infra/katalog-nachtragen.sh` ist in diesem Fork blind** für
  spotless-ausgerichtete Kopfzeilen (`| Size   |`; `| Merged |` trifft nur,
  weil „Merged" die breiteste Zelle ist) und meldet dabei Exit 0.
  `katalog-pruefen.sh` wurde am 09.09.2026 dafür ausgerichtet, das
  Nachtrage-Skript nicht. Nicht in diesem PR behoben — eigenes Bauteil.
- Dass die Ruleset-Meldung im echten Lauf erscheint, ist nur simuliert, nicht
  gemessen.
- `Main / Pull requests build` (3-OS-Matrix) ist auf `main` bereits rot —
  vorbestehend, nicht angefasst.

## 6. Provenance

Geschrieben am 2026-09-24, im selben Zug wie der PR, von der Arbeitssitzung,
die den Job in allen drei Forks nach der Entscheidung des Menschen repariert
hat. Die Marken-Werte kommen aus `gh pr view`, nicht abgetippt.
