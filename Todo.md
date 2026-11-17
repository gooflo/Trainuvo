# Trainuvo – Aufgaben und Testbefunde

Neue und zurückgestellte Einträge stehen unter **Open**. Umgesetzte Einträge stehen unter **Done** mit der internen Trainuvo-Version. Ausstehende Prüfungen stehen beim jeweiligen Eintrag.

## Open

### t05 – Trainingsdaten per iCloud synchronisieren (Prio 3)

- Übungen, Trainingsdaten und Ziele über iCloud synchronisieren, damit sie auf mehreren Geräten verfügbar sind.

## Done

### t15 – Zweiter Beispieltrainingstag am 14.11.2026 (0.5.1)

- Je Übung ein weiteres Training mit 2 kg weniger beim Arbeitsgewicht ergänzen: Press 50, Kniebeuge 88, Bankdrücken 83, Kreuzheben 98 kg.
- Gleiche Satztexte und Aufwärmgewichte wie am 17.11.2026 verwenden.
- Bestehende Beispieldaten über erneuten Import um den fehlenden Tag ergänzen.
- Xcode-Build, Swift-Tests und Sichtprüfung ausstehend.

### t12 – Trainingstage kompakt zusammenfassen (0.5.0)

- Alle Trainings auf der Startseite nach Kalendertag bündeln, neueste Tage zuerst.
- Pro Eintrag nur Übung, Arbeits-Satzgruppe, Gewicht und optionale Bewertung zeigen. Tageszeilen folgen der Übungsreihenfolge. Vollständige Satzgruppen bleiben im Übungsverlauf zugänglich.
- Mehrere Trainings derselben Übung am selben Tag ergeben mehrere Zeilen.
- Xcode-Build, Tests, Datumsgrenzen und Sichtprüfung mit vier Übungen ausstehend.

### t13 – Trainings löschen und Übungen erhalten (0.5.0)

- Gemeldeter Fehler: Nach dem Löschen von Trainings wurde auch die Übung gelöscht.
- Trainings-Löschpfad trennt vor dem Löschen die Übungsbeziehung. Rückbeziehungen explizit nullify. Bestätigungsaktionen für Training und Übung eindeutig zugeordnet.
- Regressionstests für einzelne und letzte Trainings, Erhalt von Ziel, Reihenfolge und Standardsätzen ergänzt.
- Exakte Ursache auf dem Gerät noch nicht abschließend nachgewiesen. Xcode-Build, Tests und erneute Löschprüfung mit bestehenden Daten ausstehend.

### t14 – Einstellungen, Alles löschen und Beispieldaten (0.5.0)

- Zahnrad mit Einstellungsseite, bestätigtem Alles löschen und Beispieldaten anlegen.
- Die vier vorgegebenen Übungen samt Standardsätzen und Trainings vom 17.11.2026 anlegen. Kreuzheben erhält drei Gruppen, die jeweils letzte Gruppe dient als Arbeitsgewicht.
- Gleichnamige Übungen wiederverwenden, identische Beispieltrainings überspringen, Import und Löschen gemeinsam speichern und bei Fehlern zurückrollen.
- Xcode-Build, Tests, Abbrechen/Bestätigen und wiederholter Import auf dem Gerät ausstehend.

### t11 – Anstrengung des Arbeitsgewichts bewerten (0.4.0)

- Pro Training optional -- (sehr schwer), - (schwer), o (OK) oder + (leicht, Steigerung möglich) auswählen.
- Unter den Satzgruppen Symbol und Bedeutung im Menü anbieten. Jedes neue Training beginnt ohne Bewertung.
- Im Verlauf und in der Startseiten-Zusammenfassung nur beim Arbeitsgewicht das Symbol links vor dem Gewicht anzeigen. Symbolplatz reservieren, sodass Gewichte ausgerichtet bleiben.
- Bewertung nachtragen, ändern und entfernen können.
- Xcode-Build, Swift-Tests, Update mit bestehenden Daten und Sichtprüfung mit vier Satzgruppen auf dem iPhone 15 ausstehend.

### t10 – Vier Satzgruppen kompakt erfassen (0.3.1)

- Vier Satzgruppen bei Standardtextgröße im iPhone-15-Hochformat gemeinsam anzeigen.
- Je Gruppe eine Zeile mit Arbeitsgewicht-Markierung, Satztext, Vorauswahl und kg-Eingabe. Übungsname und Datum in einer Zeile.
- Entfernen über das Satzmenü oder Wischgeste.
- Xcode-Build und Sichtprüfung mit vier Gruppen, geöffneter/geschlossener Tastatur, langen Satztexten und großer Textgröße ausstehend.

### t08 – Übungen auf der Startseite sortieren (0.3.0)

- Über „Sortieren“ neben „Deine Ziele“ die Reihenfolge per Griff ändern und speichern.
- Reihenfolge dauerhaft speichern. Vorhandene Übungen zunächst alphabetisch, neue Übungen am Ende anzeigen.
- Xcode-Build, Update-Test, Abbrechen, Speichern und Neustart auf dem Gerät ausstehend.

### t09 – Arbeitsgewicht links markieren und Gewichte ausrichten (0.3.0)

- Zielscheiben-Symbol links neben dem Arbeitsgewicht anzeigen. Bei anderen Gruppen denselben Symbolplatz reservieren und Gewichte rechtsbündig ausrichten.
- Gilt für Trainingsverlauf und Zusammenfassungen des letzten Trainingstags.
- Sichtprüfung mit mehreren Satzgruppen und unterschiedlichen Gewichten auf dem Gerät ausstehend.

### t07 – Standardsätze pro Übung und erweiterte Vorauswahl (0.2.0)

- Satzgruppen wie 1 × 5, 1 × 5, 3 × 5, 1 × 5 in dieser Reihenfolge pro Übung hinterlegen und umordnen.
- Eine Gruppe als Arbeitsgewicht vormerken. Neue Trainings übernehmen Gruppen und Markierung mit leeren Gewichtsfeldern, sodass nur die kg einzutragen sind.
- 1 × 3 und 1 × 5 zusätzlich als Vorauswahl anbieten.
- Xcode-Build, automatisierte Tests, Update-Test mit bestehenden Trainings und Simulator-/Gerätetest ausstehend.

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
