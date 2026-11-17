# Trainuvo – Aufgaben und Testbefunde

Neue und zurückgestellte Einträge stehen unter **Open**. Umgesetzte Einträge stehen unter **Done** mit der internen Trainuvo-Version. Ausstehende Prüfungen stehen beim jeweiligen Eintrag.

## Open

### t05 – Trainingsdaten per iCloud synchronisieren (Prio 3)

- Übungen, Trainingsdaten und Ziele über iCloud synchronisieren, damit sie auf mehreren Geräten verfügbar sind.

## Done

### t06 – Vier kompakte Übungsziele auf dem iPhone 15 (0.1.1)

- Zielgewicht, erreichtes Arbeitsgewicht und letztes Trainingsdatum in einer Zeile darstellen.
- Prozentwert in der Titelzeile, kleinere Innenabstände und Kartenabstände. Ziel sind vier sichtbare Übungsziele im iPhone-15-Hochformat bei Standardtextgröße.
- Sichtprüfung mit vier Übungen, langen Namen, fehlenden Zielgewichten/Trainings sowie großer Textgröße und Xcode-Build ausstehend.

### t01 – Übungen und Zielgewichte verwalten (0.1.0)

- Übungen anlegen und bearbeiten. Pro Übung optional ein Zielgewicht hinterlegen.
- Den Fortschritt aus dem letzten Training der Übung berechnen: Arbeitsgewicht ÷ Zielgewicht × 100. Beispiel: 60 kg bei 100 kg Zielgewicht ergeben 60 %.

### t02 – Training pro Übung erfassen (0.1.0)

- Das aktuelle Datum vorbelegen und ein anderes Datum für nachgetragene Trainings zulassen.
- Für Sätze und Wiederholungen die Vorauswahlen 3 × 5, 3 × 3 und 5 × 3 sowie Freitext anbieten.

### t03 – Unterschiedliche Gewichte im selben Training erfassen (0.1.0)

- Gewicht pro Satz oder Satzgruppe erfassen, damit Aufwärm- und Arbeitssätze gemeinsam dokumentiert werden können.
- Beispiel: 1 × 5 mit 50 kg, 1 × 5 mit 70 kg und 3 × 5 mit 100 kg Arbeitsgewicht.

### t04 – Ziele und Training auf dem Startbildschirm anzeigen (0.1.0)

- Den Fortschritt pro Übung übersichtlich darstellen, einschließlich des Zielgewichts und des erreichten Prozentsatzes. Erreichte Ziele sichtbar hervorheben.
- Das aktuelle bzw. letzte Training auf dem Startbildschirm anzeigen.

Prüfstand für t01–t04: Umsetzung in 0.1.0 vorhanden. Xcode-Build, automatisierte Tests und Simulator-/Gerätetest ausstehend. Abnahmeschritte stehen in DeveloperDocu.md.
