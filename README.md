# Trainuvo

Trainuvo dokumentiert Krafttraining und zeigt den Fortschritt gegenüber persönlichen Zielgewichten.

**Interner Entwicklungsstand: 0.2.0 – Vorabversion**

## Funktionen

- Übungen mit optionalem Zielgewicht und geordneten Standardsatzgruppen anlegen, bearbeiten und löschen.
- Trainings pro Übung erfassen, nachtragen, bearbeiten und löschen.
- Mehrere Satzgruppen mit unterschiedlichen Gewichten erfassen. Die Vorauswahl bietet 1 × 3, 1 × 5, 3 × 5, 3 × 3 und 5 × 3. Freitext ist möglich.
- Eine Satzgruppe pro Training als Arbeitsgewicht markieren.
- Kompakte Zielkarten mit Zielgewicht, erreichtem Arbeitsgewicht und letztem Trainingsdatum in einer Zeile. Vier Übungsziele sollen bei Standardtextgröße auf einen iPhone-15-Bildschirm im Hochformat passen.
- Startseite mit Zielfortschritt pro Übung und allen Einträgen des letzten Trainingstags.
- Trainingsverlauf pro Übung. Neue Trainings übernehmen die Standardsätze mit leeren Gewichtsfeldern. Ohne Standardsätze dient das letzte Training als Vorschlag.
- Lokale Speicherung auf dem Gerät mit SwiftData. iCloud-Synchronisierung ist als Prio 3 vorgemerkt.

## Voraussetzungen

Die App ist für iPhone und iPad ausgelegt. Das vorhandene Xcode-Projekt setzt iOS/iPadOS 27.2 voraus. Zum Entwickeln wird eine passende Xcode-Version auf dem Mac benötigt.

## Nutzung

Über **+** eine Übung anlegen und optional ein Zielgewicht eintragen. Die Übung öffnen und **Training erfassen** wählen. Das Datum ist mit heute vorbelegt.

Beim Anlegen oder Bearbeiten einer Übung unter **Standardsätze in Trainingsreihenfolge** die gewünschten Gruppen hinterlegen, etwa **1 × 5, 1 × 5, 3 × 5, 1 × 5**. Mit den Pfeilen die Reihenfolge ändern und eine Gruppe als Arbeitsgewicht markieren. Beim neuen Training sind diese Gruppen bereits angelegt, und du ergänzt die kg. Die Gruppen können für das einzelne Training angepasst werden. Änderungen an den Standardsätzen beeinflussen künftige Erfassungen. Bestehende Trainings behalten ihre Satzgruppen und Gewichte.

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
