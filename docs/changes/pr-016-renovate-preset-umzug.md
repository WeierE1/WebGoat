# pr-016 — Renovate-Preset-Verweis auf WeierE1/cra-renovate-presets umgestellt

|        |                                                                  |
|--------|------------------------------------------------------------------|
| PR     | [WeierE1/WebGoat#16](https://github.com/WeierE1/WebGoat/pull/16) |
| Branch | `chore/renovate-preset-umzug` → `main`                           |
| Merged | pending-datum-016                                                |
| Size   | pending-size-016                                                 |
| Issues | —                                                                |
| Review | kein menschliches Review; Merge durch den Repo-Inhaber           |

## 1. Why

`WeierE1/CRA-Private` ist nach `Possehl-Pioneers/c1-security-compliance-cra`
umgezogen (gemessen 24.09.2026). Dieser Fork verwies in `renovate.json` auf
`github>WeierE1/CRA-Private//renovate-presets/kontext-a`; Renovate liest das
Preset mit dem Engine-PAT (Eigentümer `WeierE1`), der das umgezogene
Repository nicht mehr erreicht (HTTP 404, gemessen). Entscheidung des
Menschen: das Preset liegt jetzt im privaten Repository
`WeierE1/cra-renovate-presets` (Datei `kontext-a.json` im Wurzelverzeichnis).

## 2. What changed

`renovate.json`: nur der eine `extends`-Eintrag geändert, von
`github>WeierE1/CRA-Private//renovate-presets/kontext-a` auf
`github>WeierE1/cra-renovate-presets//kontext-a`. Rest der Datei byte-gleich
(Einrückung, Reihenfolge, Zeilenenden LF).

## 3. Files

|      Path       | Change |
|-----------------|--------|
| `renovate.json` | +1/−1  |

## 4. Verification

`git diff` zeigt genau die eine geänderte Zeile. JSON-Gültigkeit geprüft mit
`node -e "JSON.parse(require('fs').readFileSync('renovate.json','utf8'))"`.
`renovate-config-validator` bewusst nicht installiert (kein npm-Download für
diese eine Zeile) — das ist im PR-Text benannt. Dieser Eintrag selbst mit
`mvn -B -ntp spotless:apply` formatiert (WebGoats spotless nimmt `**/*.md`),
danach `mvn -B -ntp spotless:check` grün.

## 5. Known gaps

Wirkt erst, wenn der Engine-PAT `WeierE1/cra-renovate-presets` mit
`Contents: Read` erreicht — das stellt der Mensch außerhalb dieses PR ein. Bis
dahin scheitert ein Renovate-Lauf gegen diesen Fork weiterhin am Preset,
diesmal am neuen statt am alten Repository.

## 6. Provenance

Geschrieben am 2026-09-24, im selben Zug wie der PR, aus der Arbeitssitzung,
die den Umzug in allen drei betroffenen Forks mechanisch nachvollzogen hat.
