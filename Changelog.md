# Changelog

## 0.5.1 – Zweiter Beispieltrainingstag

- Beispieltrainings vom 14.11.2026 ergänzt. Die Arbeitsgewichte liegen jeweils 2 kg unter denen vom 17.11.2026: Press 50 kg, Kniebeuge 88 kg, Bankdrücken 83 kg, Kreuzheben 98 kg.
- Erneuter Beispieldatenimport ergänzt den fehlenden Tag und überspringt identische vorhandene Einträge.
- Hilfe, Dokumentation und Importtests aktualisiert. Xcode-Build, Swift-Tests und Sichtprüfung auf dem Mac ausstehend.

## 0.5.0 – Trainingstage und Einstellungen

- Startseite nach Trainingstag zusammengefasst. Pro Trainingseintrag eine kompakte Zeile mit Übung, Arbeits-Satzgruppe, Gewicht und optionaler Bewertung.
- Löschablauf überarbeitet. Die Verbindung vom Training zur Übung wird vor dem Löschen gelöst, die Rückbeziehungen sind explizit nullify. Eine eindeutig zugeordnete Bestätigung unterscheidet Training und Übung.
- Regressionstests für das Löschen einzelner und letzter Trainings mit Erhalt der Übung und ihrer Standardsätze ergänzt. Die genaue Ursache des auf dem Gerät beobachteten Fehlers ist ohne Xcode-Lauf nicht abschließend nachgewiesen.
- Einstellungsseite über Zahnrad mit bestätigtem Alles löschen und wiederholt nutzbarem Beispieldatenimport.
- Press, Kniebeuge, Bankdrücken und Kreuzheben mit den vorgegebenen Zielen, Standardsätzen und Trainings vom 17.11.2026 ergänzt. Kreuzheben verwendet die drei aufgeführten Gruppen. Die letzte Gruppe ist jeweils das Arbeitsgewicht.
- Dokumentation und Hilfe aktualisiert. Xcode-Build, Swift-Tests, Update-Test und Geräteprüfung sind ausstehend.

## 0.4.0 – Anstrengung beim Arbeitsgewicht

- Optionale Bewertung pro Training ergänzt: -- Sehr schwer, - Schwer, o OK und + Leicht – Steigerung möglich.
- Kompakte Menüauswahl unter den Satzgruppen. Neue Trainings beginnen ohne Bewertung, bestehende Bewertungen lassen sich bearbeiten und entfernen.
- Bewertungssymbol links vor dem Arbeitsgewicht im Verlauf und in der Startseiten-Zusammenfassung. Feste, mit der Textgröße skalierende Symbolspalte erhält die Ausrichtung der Gewichte.
- Trainingsmodell additiv um ein optionales Bewertungsfeld erweitert. Bestehende Einträge bleiben zunächst unbewertet.
- Hilfe, Dokumentation und Tests aktualisiert. Xcode-Build, Swift-Tests, Update-Test und Sichtprüfung auf dem Mac ausstehend.

## 0.3.1 – Kompakte Trainingserfassung

- Jede Satzgruppe zeigt Arbeitsgewicht-Markierung, Satztext, Vorauswahl und kg-Eingabe in einer Zeile.
- Vier Satzgruppen auf einem iPhone-15-Bildschirm bei Standardtextgröße als Layoutziel. Übungsname und Datum stehen in einer Zeile.
- Entfernen über das Satzmenü oder per Wischgeste. Kurze Hinweise, Hilfe und Dokumentation angepasst.
- Swift-Syntaxprüfung erfolgt. Xcode-Build und Sichtprüfung auf dem Gerät sind ausstehend.

## 0.3.0 – Übungen sortieren und Gewichte ausrichten

- Zielkarten auf der Startseite über „Sortieren“ manuell anordnen. Die Reihenfolge wird dauerhaft gespeichert, neue Übungen werden angehängt.
- Bestehende Übungen starten alphabetisch, bis eine Reihenfolge gespeichert wird.
- Arbeitsgewicht-Markierung links neben das Gewicht verschoben. Die Gewichte stehen rechtsbündig untereinander, auch bei mehreren Satzgruppen.
- Hilfe und Dokumentation aktualisiert.
- Xcode-Build, automatisierte Tests, Update- und Sichtprüfung sind auf dem Mac ausstehend.

## 0.2.0 – Standardsätze pro Übung

- Satzgruppen in fester Reihenfolge pro Übung hinterlegen und mit Pfeilen umordnen.
- Standardsatzgruppe als Arbeitsgewicht markieren. Neue Trainings übernehmen die Gruppen und Markierung mit leeren Gewichtsfeldern.
- Vorauswahl 1 × 3 und 1 × 5 in Übungsverwaltung und Trainingserfassung ergänzt.
- Bestehende Trainings behalten ihre Satzgruppen und Gewichte. Ohne hinterlegte Standardsätze bleibt das letzte Training der Vorschlag.
- Datenmodell um ExerciseSetTemplate ergänzt. Hilfe, Dokumentation und Testfälle erweitert.
- Xcode-Build, automatisierte Tests, Update-Test über 0.1.1 und Sichtprüfung auf dem Mac ausstehend.

## 0.1.1 – Kompakte Zielkarten

- Zielgewicht, erreichtes Arbeitsgewicht und Trainingsdatum in einer gemeinsamen Zeile.
- Prozentwert in die Titelzeile verschoben und Kartenabstände reduziert, damit vier Übungsziele bei Standardtextgröße auf einen iPhone-15-Bildschirm im Hochformat passen.
- Hilfe und Dokumentation angepasst.
- Sichtprüfung auf dem iPhone 15 und Xcode-Build ausstehend.

## 0.1.0 – Erste Vorabversion

- Übungen und optionale Zielgewichte verwalten.
- Trainings mit Datum und frei formulierbaren Satzgruppen erfassen, bearbeiten und löschen.
- Vorauswahl für 3 × 5, 3 × 3 und 5 × 3 sowie unterschiedliche Gewichte für Aufwärm- und Arbeitssätze.
- Arbeitsgewicht pro Training markieren und daraus den Zielfortschritt berechnen.
- Startseite mit Zielkarten und letztem Trainingstag sowie Verlauf pro Übung.
- Lokale SwiftData-Speicherung und Hilfe in der App.
- README und gemeinsame technische Dokumentation angelegt.
- Git ignoriert lokale Finder- und Xcode-Benutzereinstellungen.

### Prüfstand

Quelltexte und Projektverknüpfung statisch geprüft. Xcode-Build, automatisierte Swift-Tests und Simulator-/Gerätetest sind auf dem Mac ausstehend. Die konkreten Schritte stehen in DeveloperDocu.md.
