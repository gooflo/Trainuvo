# Trainuvo

Trainuvo dokumentiert Krafttraining und zeigt den Fortschritt gegenüber persönlichen Zielgewichten.

**Interner Entwicklungsstand: 0.1.0 – erste Vorabversion**

## Funktionen

- Übungen mit optionalem Zielgewicht anlegen, bearbeiten und löschen.
- Trainings pro Übung erfassen, nachtragen, bearbeiten und löschen.
- Mehrere Satzgruppen mit unterschiedlichen Gewichten erfassen. Die Vorauswahl bietet 3 × 5, 3 × 3 und 5 × 3. Freitext ist möglich.
- Eine Satzgruppe pro Training als Arbeitsgewicht markieren.
- Startseite mit Zielfortschritt pro Übung und allen Einträgen des letzten Trainingstags.
- Trainingsverlauf pro Übung. Satzgruppen des letzten Trainings werden bei einer neuen Erfassung vorgeschlagen.
- Lokale Speicherung auf dem Gerät mit SwiftData. iCloud-Synchronisierung ist als Prio 3 vorgemerkt.

## Voraussetzungen

Die App ist für iPhone und iPad ausgelegt. Das vorhandene Xcode-Projekt setzt iOS/iPadOS 27.2 voraus. Zum Entwickeln wird eine passende Xcode-Version auf dem Mac benötigt.

## Nutzung

Über **+** eine Übung anlegen und optional ein Zielgewicht eintragen. Die Übung öffnen und **Training erfassen** wählen. Das Datum ist mit heute vorbelegt.

Für ein Training beispielsweise drei Satzgruppen erfassen:

| Sätze × Wiederholungen | Gewicht | Arbeitsgewicht |
|---|---|---|
| 1 × 5 | 50 kg | |
| 1 × 5 | 70 kg | |
| 3 × 5 | 100 kg | Ja |

Der Zielfortschritt entspricht dem Arbeitsgewicht des zeitlich letzten Trainings geteilt durch das aktuelle Zielgewicht. 60 kg bei einem Ziel von 100 kg ergeben 60 %. Bei identischem Datum einschließlich Uhrzeit entscheidet das Anlegedatum. Ein älterer nachgetragener Eintrag ersetzt den aktuellen Fortschritt daher nur, wenn er zeitlich der letzte ist.

Im Verlauf einen Eintrag zum Bearbeiten antippen oder zum Löschen nach links wischen. Die Übungsaktionen stehen im Menü **…**. Löschen einer Übung entfernt auch ihre Trainings nach Bestätigung.

Satztexte dürfen frei formuliert werden, etwa **5/5/4**. Sie werden unverändert dokumentiert. Für den Prozentwert zählt das markierte Gewicht. Gewichte können mit Komma oder Punkt eingegeben werden.

## Dokumentation

- [DeveloperDocu.md](DeveloperDocu.md) – Einrichtung, Architektur, Datenmodell, Tests und Veröffentlichung
- [Todo.md](Todo.md) – Aufgaben und Testbefunde
- [Changelog.md](Changelog.md) – Versionshistorie
- [AGENTS.md](AGENTS.md) – Projektregeln
