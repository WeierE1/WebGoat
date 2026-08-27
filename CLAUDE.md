# Agent context

## Was dieses Repository ist

**Testobjekt des CRA-Piloten** — ein Fork von `WebGoat/WebGoat`. Seine Rolle:
der **BOM-Fall** (spec.md §18 — rund 44 von 69 Abhängigkeiten ohne eigenes
`<version>`, verwaltet über `spring-boot-starter-parent`) und die **große
Testsuite** (306 Unit + 65 Integration), an der das Testintegritäts-Tor arbeitet.

Gesteuert wird alles aus [`WeierE1/CRA-Private`](https://github.com/WeierE1/CRA-Private)
— Spec, Issues, Presets, Learnings liegen **dort**. Hier liegt nur, was zwingend
im Zielrepo liegen muss: CI-Workflow, `renovate.json`, dieser Katalog.

## Regeln

- **Die BOM-Verwaltung ist der Zweck.** Keine Version aus `dependencyManagement`
  in ein `<version>`-Element umziehen — das zerstört den einzigen Testfall für
  den Anhebungs-Agenten (§18, §32/7).
- **Kein Direktpush auf `main`** — Ruleset aktiv, 409. Alles per PR.
- **JDK 25 festgenagelt** (Workflow, `java.version` im POM).
- **Bekannter Flake:** `LoginUITest.loginLogout` (Playwright, Timeout ~31 s,
  belegt durch rot→grün auf demselben Commit, Lauf 32950956266). Ein roter Lauf
  mit genau diesem Test ist erst nach Wiederholung ein Befund.
- **Kein Test wird abgeschwächt, gelöscht oder übersprungen, um grün zu werden**
  (spec.md §24.1).

## Dokumentation

**Nach jedem gemergten PR:** Eintrag in [`docs/changes/`](docs/changes/README.md)
— Konvention steht im Index von `CRA-Private/docs/changes/` und im Skill
`change-catalogue`. Repo-übergreifende Learnings nach `CRA-Private/LEARNINGS.md`.
