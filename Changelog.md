# Changelog

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
