# Trainuvo

Lies vor der Arbeit an diesem Repository auch [AGENTS_general.md](AGENTS_general.md).

## Entwicklung und Git

- Trainuvo ist eine native iOS- und iPadOS-App zur Dokumentation von Krafttraining und Trainingszielen. Verwende SwiftUI und SwiftData.
- Halte die lokale Arbeitskopie auf dem Mac außerhalb von iCloud Drive. Arbeite direkt auf `main` im privaten GitHub-Repository. Der Assistent committet vereinbarte Änderungen, Florian pullt und testet in Xcode und setzt und pusht anschließend das Release-Tag.
- Beschreibe Bedienungsschritte zuerst für Xcode. Gib bei der Übergabe einen konkreten Simulator- oder Gerätetest an und vermerke, wenn kein Xcode-Build oder Gerätetest möglich war.

## Versionierung und Veröffentlichung

- Pflege die interne SemVer-Version in README und Changelog. `0.x.x` bezeichnet Vorstufen, `1.0.0` die erste nutzbare Version.
- Führe die externe App-Store-Version und die Buildnummer separat. Stimme Änderungen der externen Version ab und ordne jeden hochgeladenen Build einem Commit oder Tag zu.
- TestFlight und die öffentliche App-Store-Veröffentlichung separat abstimmen.

## Trainingsdaten

- Erhalte vorhandene Trainingseinheiten, Übungen, Sätze und Ziele bei Updates. Prüfe Änderungen am SwiftData-Modell mit Daten aus einer älteren App-Version, sobald eine solche Version verteilt wurde.
- Verwende in Tests Beispieldaten und prüfe bei Änderungen an der Trainingserfassung auch den Verlauf und die davon betroffenen Ziele.

- Das Löschen eines Trainings erhält die zugehörige Übung und ihre Standardsätze, auch beim letzten Training. Eine Übung wird über ihre separate Löschaktion oder das bestätigte „Alles löschen“ entfernt. Löschänderungen mit einem Test für den letzten Trainingseintrag absichern.

- Neue Trainings über das Plus auf der Zielkarte direkt öffnen. Das erste kg-Feld nach dem Aufbau der Maske fokussieren und die numerische Tastatur mit „Fertig“ anbieten. Die automatische Fokussierung soll vorhandene Benutzereingaben nicht überschreiben.

## Aufgaben und Testbefunde

- Führe Aufgaben und Testbefunde in [Todo.md](Todo.md). Vergib fortlaufende Kennungen wie `t01` und behalte sie bei.
- Führe neue und zurückgestellte Einträge unter **Open**. Verschiebe umgesetzte Einträge mit der internen Trainuvo-Version nach **Done** und vermerke ausstehende Prüfungen beim Eintrag.

## Dokumentation

- Pflege `README.md` als kompakten Einstieg mit Zweck, aktuellem Funktionsumfang, Voraussetzungen, Nutzung, interner Version und Entwicklungsstand sowie Links zur weiteren Dokumentation.
- Führe Änderungen pro interner Version in `Changelog.md`.
- Führe die gesamte technische Dokumentation gemeinsam in `DeveloperDocu.md`. Sie umfasst Entwicklungsumgebung und Einrichtung, Architektur und Datenmodell, Geschäftsregeln und technische Abläufe, Build und Tests sowie Veröffentlichung.
- Pflege `DeveloperDocu.md` bei Änderungen an diesen Themen im selben Commit mit. Lege README, Changelog und DeveloperDocu mit der ersten App-Version an.
