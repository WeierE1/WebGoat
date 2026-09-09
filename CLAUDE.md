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

**Der Katalogeintrag gehört IN den Pull Request, nicht dahinter** — und das ist
ein Tor, keine Bitte: [`.github/workflows/katalog.yml`](.github/workflows/katalog.yml)
macht jeden PR ohne vollständigen Eintrag rot.

```
Branch → Arbeit → PR öffnen (jetzt ist die Nummer bekannt)
       → Eintrag in docs/changes/ + Indexzeile committen, die zwei Marken
         pending-datum-NNN / pending-size-NNN stehenlassen
       → Merge: die Pipeline füllt sie
```

Selbst prüfen: `bash infra/katalog-pruefen.sh <pr-nummer>`.

**Warum nicht „nach jedem gemergten PR":** genau so stand es hier bis zum
09.09.2026 — und **sieben** gemergte PRs hatten keinen Eintrag, darunter der
Nachtrags-PR #9, der seine eigene Lücke im PR-Text vorhergesagt hatte. Ein
Katalog, der nach dem Merge gepflegt wird, kann nie vollständig sein: der
Nachtrag ist selbst ein gemergter Pull Request. Oder kürzer, wie `CRA-Private`
es aufgeschrieben hat: *ein Feld, das ein Mensch beim Merge nachtragen soll,
wird nicht nachgetragen.*

**Engine-Vorgänge sind ausgenommen** — Branches `renovate/**`, `cra/anhebung/**`,
`cra/migration/**`. Sie dürfen nach `spec.md` §18.3 **ausschließlich Manifeste**
berühren und können deshalb gar keinen Katalogeintrag tragen; das Umfangs-Tor des
Anhebungs-Agenten würde den Durchlauf verwerfen. Das Katalog-Tor lässt sie mit
einer **protokollierten** Zeile durch, statt sie rot zu machen. Ihr Nachweis ist
der Nachweis-Block am Pull Request (§12.1), nicht der Katalog.

Konvention (sechs Abschnitte, Index-Regeln, Ehrlichkeitsregeln) steht im Index
von `CRA-Private/docs/changes/` und im Skill `change-catalogue`. Learnings, die
über dieses Repo hinausgehen, gehören nach `CRA-Private/docs/solutions/` — die
frühere `LEARNINGS.md` gibt es seit `a0db55a` nicht mehr.
