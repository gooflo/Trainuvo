# Changelog

## 0.9.0 – Satzübungen und freie Einheiten mit zwei Feldern

- Auswahl auf Krafttraining, Satzübung und Andere beschränkt. Bisherige Typwerte ergometer, swimming und jogging werden als Andere gelesen; Daten und Vorlagen bleiben erhalten.
- Satzübungen bieten Sätze, Vorauswahl, Arbeitsgruppe und freie rechte Angaben ohne kg. Ein optionales Freitextziel wird ohne Prozentwert angezeigt.
- Andere verwendet zwei freie Felder je Einheit, etwa 200 W / 30 min. Vorlagen unterstützen ein oder beide Felder. Neue Trainings übernehmen beide Angaben als unabhängige Kopien.
- Alle fünf Bewertungen für jeden Übungstyp aktiviert. Die Bewertung gilt für den gesamten Eintrag und steht vor den Sätzen bzw. der ersten freien Einheit.
- Optionale Felder detailText an SetGroup und ExerciseSetTemplate sowie targetDescription an Exercise ergänzt. Bestehende Gewichte und Beziehungen unverändert.
- t31–t33 erledigt, Hilfe, Dokumentation und Tests angepasst.
- Swift-Syntax und statische Konsistenz geprüft. Xcode-Build, Swift-Tests, Store-Update und Geräteprüfung ausstehend.

## 0.8.0 – Symmetrische Bewertung und Freitextvorlagen

- Bewertung auf -- Sehr schwer, - Schwer, o Neutral, + Leicht und ++ Sehr leicht erweitert. Bestehende Rohwerte und Symbole bleiben erhalten.
- Bewertung in Tagesübersicht und Verlauf links vor die Sätze verschoben; Gewichtsspalte bleibt rechtsbündig.
- Geordnete Vorlagen für Freitext-Trainingseinheiten in der Übungsbearbeitung ergänzt. Neue Trainings übernehmen die passenden Texte; bestehende Trainings bleiben unabhängig.
- Vorlagen speichern ihren Typ als optionales Feld. Bestehende Vorlagen gelten als Krafttraining; Typwechsel erhalten die Vorlagen anderer Typen.
- t29 und t30 erledigt, Hilfe, Tests und Dokumentation aktualisiert.
- Swift-Syntax und statische Konsistenz geprüft. Xcode-Build, Swift-Tests, Store-Update und Geräteprüfung ausstehend.

## 0.7.0 – Weitere Übungstypen mit Freitext

- Übungstypen Krafttraining, Ergometer, Schwimmen, Joggen und Andere ergänzt.
- Die vier zusätzlichen Typen verwenden freie Trainingseinheiten mit normaler Tastatur. Mehrere Einheiten sind möglich.
- Karten, Tagesübersicht und Verlauf zeigen passende Texte bzw. Krafttrainingsdaten. Der Startbereich heißt Deine Übungen.
- Übung und Trainingseintrag speichern ihren Typ als optionalen String. Datensätze ohne Typ gelten als Krafttraining. Jeder neue Eintrag erhält seinen eigenen Typ, damit spätere Änderungen der Übung bestehende Trainings erhalten.
- Krafttrainingsvorgaben werden bei Typwechsel beibehalten. Der Beispieldatenimport überspringt gleichnamige Übungen mit einem anderen Typ.
- Hilfe, Dokumentation und Tests aktualisiert. t28 unter Done verschoben.
- Swift-Syntax geprüft. Xcode-Build, Swift-Tests, Update-Test und Geräteprüfung ausstehend.

## 0.6.9 – Bewertung direkt auswählen

- Vier direkt antippbare Flächen mit --, -, o und + sowie kurzen Beschriftungen eingeführt.
- Die Auswahl wird blau hervorgehoben, die vollständige Bedeutung steht darüber. X entfernt die Bewertung.
- Bei großer Bedienungshilfen-Schrift werden zwei Spalten verwendet. VoiceOver erhält die volle Bedeutung und den Auswahlstatus.
- t22 unter Done verschoben. Hilfe und Dokumentation aktualisiert.
- Xcode-Build und Geräteprüfung ausstehend.

## 0.6.8 – Weitere Übungsarten vorgemerkt

- Weitere Übungsarten neben Krafttraining mit Prio 2 in Todo.md aufgenommen. Übungstypen mit passenden Einheiten und ein freier Typ Andere sind als offene Alternativen dokumentiert.

## 0.6.7 – Gewünschtes Logo eingebaut

- App-Icon durch die schräge weiße Langhantel auf blauem Verlauf ersetzt.
- Logo-Beschreibung in Projektregeln und technischer Dokumentation korrigiert.
- Iconformat geprüft. Xcode-Build und Darstellung auf dem Gerät ausstehend.

## 0.6.6 – App-Icon und Überschrift

- Ausgewähltes Logo 3 als App-Icon eingebaut: blaue Langhantel mit Fortschrittsring auf Weiß.
- Training erfassen bzw. Training bearbeiten unter die obere Buttonleiste verschoben, mit dem Übungsnamen direkt darunter.
- Ziele löschen mit Erhalt der Trainings und einen gemeinsamen Tageskommentar mit Prio 3 in Todo.md aufgenommen.
- Swift-Syntax, Iconformat und Assetverknüpfung geprüft. Xcode-Build und Sichtprüfung auf dem Gerät ausstehend.

## 0.6.5 – Übung bei der Trainingserfassung deutlich anzeigen

- Übungsname als eigenständige große Überschrift oberhalb der Eingabemaske ergänzt. Er bleibt beim Scrollen und bei geöffneter Tastatur sichtbar.
- Datum separat beschriftet. Lange Übungsnamen können mehrzeilig angezeigt werden. Gilt für neue und bestehende Trainings.
- t21 unter Done verschoben und Hilfe sowie technische Dokumentation aktualisiert.
- Swift-Syntax geprüft. Xcode-Build und Sichtprüfung auf dem Gerät ausstehend.

## 0.6.4 – Zweisprachigkeit vorgemerkt

- Deutsch und Englisch für App-Oberfläche, Hilfe und Fehlermeldungen mit Prio 3 in Todo.md aufgenommen.

## 0.6.3 – Blaue Akzentfarbe

- Bedienelemente, Fortschrittsanzeigen und Arbeitsgewicht-Markierungen auf Blau umgestellt.
- AccentColor für helle und dunkle Darstellung mit Blau belegt und Farbvorgabe in den Projektregeln festgehalten.
- Xcode-Build und Sichtprüfung auf dem Gerät ausstehend.

## 0.6.2 – Weitere Verbesserungen vorgemerkt

- Eindeutige Übungsanzeige bei der Trainingserfassung mit Prio 1 in Todo.md aufgenommen.
- Überarbeitung der Darstellung der Arbeitsgewicht-Bewertung mit Prio 2 aufgenommen.

## 0.6.1 – Export und Logo vorgemerkt

- JSON-, Excel- und formatierten Text-Export für OneNote unter Prio 2 in Todo.md aufgenommen.
- Logo und App-Icon mit Langhantelmotiv unter Prio 2 vorgemerkt.

## 0.6.0 – Training direkt von der Zielkarte erfassen

- Zahnrad und Hilfe nach rechts oben verschoben.
- Stift neben Deine Ziele öffnet die Verwaltung zum Anlegen und Sortieren von Übungen.
- Jede Zielkarte erhält einen eigenen Plus-Button für die direkte Trainingserfassung.
- Neue Trainings fokussieren nach dem Aufbau der Maske das erste kg-Feld mit numerischer Tastatur und Fertig-Taste, analog zum Cashuvo-Ablauf.
- Tastaturfokus nach Satzgruppe und Eingabefeld eindeutig zugeordnet. Hilfe, Dokumentation und Projektregeln aktualisiert.
- Xcode-Build und Sicht-/Tastaturprüfung auf dem Gerät ausstehend.

## 0.5.3 – Einzelnes Training sichtbar löschen

- Im geöffneten bestehenden Training einen sichtbaren Button „Dieses Training löschen“ mit Bestätigung ergänzt.
- Tageszeilen auf der Startseite öffnen direkt den jeweiligen Trainingseintrag.
- Der Löschbutton verwendet denselben abgesicherten Löschpfad mit getrennter Übungsbeziehung. Die Übung, Standardsätze und andere Trainingseinträge werden erhalten.
- Vollständiges Durchwischen im Übungsverlauf deaktiviert, sodass die Löschaktion bewusst ausgewählt wird.
- Hilfe und Dokumentation aktualisiert. Xcode-Build und Geräteprüfung ausstehend.

## 0.5.2 – Explizite Identifizierung in SwiftUI-Listen

- Die Satzgruppen-Schleife in TrainingSummary verwendet die gespeicherte UUID explizit als ForEach-ID. Damit benötigt diese Schleife keine abgeleitete Identifiable-Konformität des Elements.
- Weitere ForEach-Schleifen über gespeicherte Übungen und Trainings ebenfalls auf explizite IDs umgestellt.
- Swift-Syntaxprüfung erfolgt. Xcode-Build und Sichtprüfung auf dem Mac ausstehend.

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
