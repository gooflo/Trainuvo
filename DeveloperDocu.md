# Trainuvo – Entwicklerdokumentation

Interne Version **0.3.0**. Dauerhafte Regeln stehen in [AGENTS.md](AGENTS.md) und [AGENTS_general.md](AGENTS_general.md).

## Einrichtung und Build

Die Arbeitskopie liegt auf dem Mac unter `~/Developer/Trainuvo`. In Xcode `Trainuvo.xcodeproj` öffnen, über **Integrate → Pull…** den Stand von `main` holen, das Scheme **Trainuvo** und einen verfügbaren iPhone-Simulator wählen. Mit **⌘ R** bauen und starten.

Das vorhandene Projekt nutzt das Xcode-27.2-Format `project.xcproj` und Ordner mit automatischer Target-Zuordnung. Neue Swift-Dateien im Ordner Trainuvo gehören dadurch zum App-Target. Bundle-ID, Signing-Team und Mindestversion iOS 27.2 stammen aus dem Grundprojekt.

## Architektur

| Datei | Verantwortung |
|---|---|
| TrainuvoApp.swift | Persistenter SwiftData-Container, lokaler Betrieb, Anzeige eines Öffnungsfehlers |
| TrainingModels.swift | Exercise, ExerciseSetTemplate, TrainingEntry, SetGroup, Fortschrittsberechnung und Gewichtsformatierung |
| ContentView.swift | Startseite, Zielkarten, letzter Trainingstag, Übungsdetail und Hilfe |
| ExerciseOrderEditor.swift | Reihenfolge der Übungen als lokalen Entwurf bearbeiten und explizit speichern |
| TrainingEditors.swift | Eingabeentwürfe, Validierung und explizites Speichern |
| Item.swift | Unverändertes Modell aus dem Grundprojekt für vorhandene Testdaten |

Die interne Version wird über die Build-Einstellung `INFOPLIST_KEY_TrainuvoInternalVersion` in die generierte Info.plist übernommen. Die Hilfe zeigt die interne Version. Die externe Version 1.0 und Buildnummer 1 stammen aus dem Grundprojekt und werden für einen späteren Upload separat abgestimmt.

## Datenmodell und Geschäftsregeln

- Exercise speichert UUID, Name, optionales Zielgewicht und sortOrder (Int, Standardwert 0). Namen werden beim Speichern getrimmt und ohne Beachtung von Groß-/Kleinschreibung und Akzenten auf Duplikate geprüft.
- ExerciseSetTemplate speichert UUID, Reihenfolge, Satztext und Arbeitsgewicht-Markierung. Exercise hält diese Vorlagen als separate Cascade-Beziehung mit inverser Übungsbeziehung. Die Vorlage enthält keine Gewichte.
- TrainingEntry speichert UUID, Trainingsdatum, Anlegedatum und Übungsbeziehung. Das Datum kann bis heute gewählt werden. Es wird einschließlich Uhrzeit gespeichert.
- SetGroup speichert UUID, Reihenfolge, freien Satztext, Gewicht in kg und die Markierung als Arbeitsgewicht.
- Exercise → TrainingEntry und TrainingEntry → SetGroup sind Beziehungen mit Cascade-Löschung und inversen Elternbeziehungen.
- Genau eine Satzgruppe muss als Arbeitsgewicht markiert sein. Das Entfernen der markierten Gruppe markiert die erste verbleibende Gruppe.
- Fortschritt = markiertes Arbeitsgewicht des chronologisch letzten Trainings ÷ aktuelles Zielgewicht. Bei gleichem Trainingsdatum entscheidet das Anlegedatum. Werte über 100 % werden als Zahl angezeigt, der Fortschrittsbalken endet bei 100 %.
- Die Startseite zeigt die Einträge des letzten lokalen Kalendertags mit Training.
- Gewichte sind endliche Double-Werte zwischen 0 und 100.000 kg. Ziele liegen zwischen 0,01 und 100.000 kg. Komma und Punkt werden akzeptiert. Die Darstellung zeigt bis zu zwei Nachkommastellen. Freitext wird für den Fortschritt nicht ausgewertet.
- Editoren bearbeiten zunächst lokale Entwürfe. Abbrechen verändert keine gespeicherten Daten. Speichern und Löschen verwenden explizites save, bei Fehlern rollback und eine Fehlermeldung. Löschen verlangt eine Bestätigung.
- Ein neues Training verwendet zuerst die geordneten Übungsstandardsätze und deren Arbeitsgewicht-Markierung, mit leeren Gewichtsfeldern. Ohne Standardsätze werden wie bisher die Satzgruppen und Gewichte des letzten Trainings vorgeschlagen, sonst 3 × 5. Das Bearbeiten eines bestehenden Trainings verwendet immer dessen eigene Gruppen. Änderungen an Vorlagen berühren vorhandene TrainingEntry- und SetGroup-Objekte nicht.
- Neue Übungen starten im Editor mit einer Standardgruppe 3 × 5. Die Gruppen können entfernt, ergänzt, bearbeitet und mit Pfeilen umgeordnet werden. Genau eine vorhandene Standardgruppe muss als Arbeitsgewicht markiert sein. Ohne Standardgruppen ist die Markierung leer. Eingabe und Speicherung verwenden lokale Entwürfe.
- Die gemeinsame Vorauswahl TrainingFormat.prescriptions bietet 1 × 3, 1 × 5, 3 × 5, 3 × 3 und 5 × 3.

## Speicherung und spätere Synchronisierung

Der Container enthält weiterhin Item aus dem Xcode-Grundprojekt. Die bisherigen Store-Einstellungen bleiben erhalten, ergänzt um die Trainingsmodelle. 0.2.0 ergänzt ExerciseSetTemplate und eine mit leerer Liste vorbelegte Beziehung an Exercise. Bestehende Attribute und Beziehungen bleiben erhalten. Das automatische SwiftData-Update muss über einer Installation von 0.1.1 mit Trainingsdaten auf dem Mac geprüft werden. CloudKit ist ausdrücklich ausgeschaltet. Ein Öffnungsfehler zeigt eine Fehlermeldung und erhält den vorhandenen Store.

Vor der ersten Verteilung das ausgelieferte Modell als Ausgangsschema sichern. Spätere Änderungen mit vorhandenen Trainings testen und bei Bedarf einen SchemaMigrationPlan ergänzen. iCloud-Synchronisierung bleibt unter t05 auf Prio 3.

## Reihenfolge der Übungen

Die Startseite fragt Übungen nach sortOrder und danach nach Name ab. Altbestände erhalten für sortOrder den Standardwert 0 und bleiben dadurch zunächst alphabetisch. Nach der manuellen Sortierung werden alle Positionen fortlaufend gespeichert. Neue Übungen erhalten die höchste vorhandene Position plus eins.

ExerciseOrderEditor hält UUIDs als lokalen Reihenfolgeentwurf. Abbrechen ändert keine Modelldaten. Speichern ordnet die aktuell vorhandenen Übungen zu, ergänzt zwischenzeitlich angelegte Übungen am Ende und überspringt entfernte Übungen. Änderungen werden gemeinsam gespeichert, bei Fehlern zurückgerollt und als Fehlermeldung angezeigt.

0.3.0 ergänzt nur das mit 0 vorbelegte Feld sortOrder. Das Update über die vorhandene 0.2.0-Installation mit Trainingsdaten muss auf dem Mac geprüft werden.

## Zielkarten auf der Startseite

GoalCard zeigt Übungsname und Prozentwert in der Kopfzeile, darunter den Fortschrittsbalken sowie eine gemeinsame Zeile für Zielgewicht, erreichtes Arbeitsgewicht und Trainingsdatum mit zweistelligem Jahr. Fehlende Werte erscheinen als Gedankenstrich. Die Karte verwendet 12 pt Innenabstand und 8 pt Abstand zwischen ihren Zeilen, das Raster 12 pt Kartenabstand. Vier Karten sollen bei Standardtextgröße im iPhone-15-Hochformat vollständig sichtbar sein. Die Informationszeile bleibt einzeilig und kann auf 70 % ihrer Schriftgröße verkleinert werden.

Sichtprüfung auf dem iPhone-15-Simulator mit vier Übungen durchführen. Auch lange Namen, Ziele über 100 %, Übungen ohne Trainings, Übungen ohne Ziel sowie größere Bedienungshilfen-Schriften prüfen. Bei großer Textgröße darf die Übersicht scrollen. Simulatorprüfung und Xcode-Build sind ausstehend.

## Gewichtsspalte

TrainingSummary verwendet vor jeder Gewichtsangabe einen 18 pt breiten Platz für die Arbeitsgewicht-Markierung. Bei anderen Gruppen ist das Symbol unsichtbar und für VoiceOver ausgeblendet. Gewichte verwenden tabellarische Ziffern, feste horizontale Eigenbreite und stehen am rechten Rand. Diese gemeinsame Darstellung gilt für Verlauf und Startseiten-Zusammenfassung.

## Tests auf dem Mac

Automatisierte Tests mit **⌘ U** ausführen. TrainuvoTests prüft deutsche und englische Gewichtseingaben, das Arbeitsgewicht des letzten Trainings und SwiftData-Beziehungen einschließlich Cascade-Löschung in einem In-Memory-Store.

Für die Abnahme von 0.1.0 im Simulator oder auf dem Gerät prüfen:

1. Über die vorhandene Grundinstallation aktualisieren. Übung Kreuzheben mit Ziel 100 kg anlegen.
2. Ein Training mit 1 × 5 bei 50 kg, 1 × 5 bei 70 kg und 3 × 5 bei 60 kg erfassen. Die letzte Gruppe als Arbeitsgewicht markieren. Die Startseite muss 60 % zeigen.
3. Einen älteren Eintrag mit 90 kg nachtragen. Der Fortschritt muss bei 60 % bleiben. Ein zweites Training von heute hinzufügen und die Reihenfolge kontrollieren.
4. Gewichte mit Komma und Punkt testen. Leerer Name, doppelter Name, ungültiges Gewicht und Ziel 0 dürfen nicht gespeichert werden.
5. Ein bestehendes Training bearbeiten und Abbrechen prüfen. Anschließend speichern und die geänderten Gruppen im Verlauf kontrollieren.
6. Die App beenden und neu starten. Daten und Fortschritt müssen erhalten bleiben.
7. Ein Training löschen und die Neuberechnung prüfen. Das Löschen einer Übung abbrechen und danach bestätigen.
8. Eine zweite Übung mit Training anlegen. Auf der Startseite müssen alle Übungen des letzten Trainingstags erscheinen.
9. Auf iPhone und iPad, bei großem Text und im Dunkelmodus die Zielkarten, Formulare, Tastaturtaste Fertig und Hilfe prüfen.

In der Entwicklungsumgebung des Assistenten sind Xcode und Swift nicht installiert. Build, automatisierte Swift-Tests und visuelle Abnahme bleiben auf dem Mac ausstehend.

## Abnahme der Standardsätze in 0.2.0

1. Vor dem Update unter 0.1.1 eine Übung mit Training anlegen. Mit 0.2.0 über die bestehende Installation aktualisieren und gespeicherte Daten kontrollieren.
2. In der Übungsbearbeitung die Standardgruppen 1 × 5, 1 × 5, 3 × 5, 1 × 5 anlegen. Die dritte Gruppe als Arbeitsgewicht markieren und speichern.
3. Ein neues Training öffnen. Genau diese vier Gruppen müssen in dieser Reihenfolge mit leeren kg-Feldern erscheinen. Nach Eingabe von vier Gewichten muss Speichern ohne erneute Markierung möglich sein.
4. In beiden Editoren die Vorauswahlen 1 × 3 und 1 × 5 testen. Gruppen umordnen und entfernen, insbesondere die markierte Gruppe. Änderungen abbrechen und erneut öffnen.
5. Standardsätze ändern und prüfen, dass vorhandene Trainings beim Öffnen ihre bisherigen Gruppen und Gewichte behalten.
6. App neu starten und Standardsätze kontrollieren. Eine Übung ohne Standardsätze prüfen, dann eine Übung löschen und die übrigen Übungen und Trainings kontrollieren.

## Abnahme der Sortierung und Gewichtsspalte in 0.3.0

1. Über 0.2.0 aktualisieren und vorhandene Übungen samt Trainings prüfen. Ohne gespeicherte Reihenfolge müssen die Übungen alphabetisch bleiben.
2. Mit mindestens vier Übungen „Sortieren“ öffnen, die letzte Übung nach oben ziehen und abbrechen. Erneut öffnen, umordnen und speichern. Startseite und Reihenfolge nach App-Neustart prüfen.
3. Eine neue Übung anlegen. Sie muss am Ende stehen. Eine bereits sortierte Übung umbenennen und eine andere löschen. Die übrige Reihenfolge muss erhalten bleiben.
4. Im Verlauf mehrere Gruppen mit 50, 70, 100 und 102,5 kg anzeigen. Nur das Arbeitsgewicht erhält links das Zielscheiben-Symbol, alle Gewichte müssen rechtsbündig stehen. Auch die Zusammenfassung auf der Startseite prüfen.
5. Auf iPhone 15 und iPad sowie mit großer Textgröße prüfen. Xcode-Build, automatisierte Swift-Tests und Gerätetest sind ausstehend.

## Veröffentlichung

Nach erfolgreichem Test den vorgesehenen Commit mit `v0.3.0` taggen und das Tag pushen. Externe App-Version und Buildnummer vor einem Upload abstimmen, anschließend in Xcode archivieren und im Organizer prüfen. TestFlight und eine öffentliche Veröffentlichung werden separat beauftragt.
