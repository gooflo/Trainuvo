# Trainuvo – Entwicklerdokumentation

Interne Version **0.5.2**. Dauerhafte Regeln stehen in [AGENTS.md](AGENTS.md) und [AGENTS_general.md](AGENTS_general.md).

## Einrichtung und Build

Die Arbeitskopie liegt auf dem Mac unter `~/Developer/Trainuvo`. In Xcode `Trainuvo.xcodeproj` öffnen, über **Integrate → Pull…** den Stand von `main` holen, das Scheme **Trainuvo** und einen verfügbaren iPhone-Simulator wählen. Mit **⌘ R** bauen und starten.

Das vorhandene Projekt nutzt das Xcode-27.2-Format `project.xcproj` und Ordner mit automatischer Target-Zuordnung. Neue Swift-Dateien im Ordner Trainuvo gehören dadurch zum App-Target. Bundle-ID, Signing-Team und Mindestversion iOS 27.2 stammen aus dem Grundprojekt.

## Architektur

| Datei | Verantwortung |
|---|---|
| TrainuvoApp.swift | Persistenter SwiftData-Container, lokaler Betrieb, Anzeige eines Öffnungsfehlers |
| TrainingModels.swift | Exercise, ExerciseSetTemplate, TrainingEntry, SetGroup, Fortschrittsberechnung und Gewichtsformatierung |
| ContentView.swift | Startseite, Zielkarten, gruppierte Trainingstage, Übungsdetail und Hilfe |
| SettingsView.swift | Einstellungsseite, Bestätigung für Alles löschen und Import-Rückmeldung |
| TrainingDataOperations.swift | Beispieldatenimport und vollständiges Löschen mit gemeinsamem Save/Rollback |
| ExerciseOrderEditor.swift | Reihenfolge der Übungen als lokalen Entwurf bearbeiten und explizit speichern |
| TrainingEditors.swift | Eingabeentwürfe, Validierung und explizites Speichern |
| Item.swift | Unverändertes Modell aus dem Grundprojekt für vorhandene Testdaten |

Die interne Version wird über die Build-Einstellung `INFOPLIST_KEY_TrainuvoInternalVersion` in die generierte Info.plist übernommen. Die Hilfe zeigt die interne Version. Die externe Version 1.0 und Buildnummer 1 stammen aus dem Grundprojekt und werden für einen späteren Upload separat abgestimmt.

## Datenmodell und Geschäftsregeln

- Exercise speichert UUID, Name, optionales Zielgewicht und sortOrder (Int, Standardwert 0). Namen werden beim Speichern getrimmt und ohne Beachtung von Groß-/Kleinschreibung und Akzenten auf Duplikate geprüft.
- ExerciseSetTemplate speichert UUID, Reihenfolge, Satztext und Arbeitsgewicht-Markierung. Exercise hält diese Vorlagen als separate Cascade-Beziehung mit inverser Übungsbeziehung. Die Vorlage enthält keine Gewichte.
- TrainingEntry speichert UUID, Trainingsdatum, Anlegedatum, Übungsbeziehung und das optionale String-Feld effortRawValue. TrainingEffort bietet die stabilen Werte veryHard, hard, okay und easy mit den Symbolen --, -, o und +. Der berechnete Zugriff effort bildet den String auf das Enum ab. Fehlende oder unbekannte Werte werden als unbewertet dargestellt. Das Datum kann bis heute gewählt werden. Es wird einschließlich Uhrzeit gespeichert.
- SetGroup speichert UUID, Reihenfolge, freien Satztext, Gewicht in kg und die Markierung als Arbeitsgewicht.
- Exercise → TrainingEntry und TrainingEntry → SetGroup sind Beziehungen mit Cascade-Löschung und inversen Elternbeziehungen. TrainingEntry.exercise, SetGroup.entry und ExerciseSetTemplate.exercise haben explizit nullify als Löschregel. Diese entspricht dem bisher impliziten Standard. Es werden keine bestehenden Felder entfernt.
- Genau eine Satzgruppe muss als Arbeitsgewicht markiert sein. Das Entfernen der markierten Gruppe markiert die erste verbleibende Gruppe.
- Fortschritt = markiertes Arbeitsgewicht des chronologisch letzten Trainings ÷ aktuelles Zielgewicht. Bei gleichem Trainingsdatum entscheidet das Anlegedatum. Werte über 100 % werden als Zahl angezeigt, der Fortschrittsbalken endet bei 100 %.
- TrainingDaySummary gruppiert alle Einträge nach lokalem Kalendertag. Die Tage sind absteigend sortiert. Innerhalb eines Tages gilt die manuelle Übungsreihenfolge, danach Übungsname und absteigendes Trainings-/Anlegedatum. Mehrfache Einträge derselben Übung bleiben als einzelne Trainingszeilen sichtbar.
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

## Identifizierung in SwiftUI-Listen

ForEach-Schleifen über Exercise, TrainingEntry und SetGroup verwenden explizit id: \.id mit der gespeicherten UUID. Dies umfasst Zielkarten, Tageszeilen, Trainingsverlauf, Satzgruppen und den Sortierdialog. Die Datenmodelle und ihre gespeicherten IDs werden dafür nicht geändert. TrainingDaySummary und lokale Eingabeentwürfe definieren ihre Identifiable-Konformität selbst.

## Zielkarten auf der Startseite

GoalCard zeigt Übungsname und Prozentwert in der Kopfzeile, darunter den Fortschrittsbalken sowie eine gemeinsame Zeile für Zielgewicht, erreichtes Arbeitsgewicht und Trainingsdatum mit zweistelligem Jahr. Fehlende Werte erscheinen als Gedankenstrich. Die Karte verwendet 12 pt Innenabstand und 8 pt Abstand zwischen ihren Zeilen, das Raster 12 pt Kartenabstand. Vier Karten sollen bei Standardtextgröße im iPhone-15-Hochformat vollständig sichtbar sein. Die Informationszeile bleibt einzeilig und kann auf 70 % ihrer Schriftgröße verkleinert werden.

Sichtprüfung auf dem iPhone-15-Simulator mit vier Übungen durchführen. Auch lange Namen, Ziele über 100 %, Übungen ohne Trainings, Übungen ohne Ziel sowie größere Bedienungshilfen-Schriften prüfen. Bei großer Textgröße darf die Übersicht scrollen. Simulatorprüfung und Xcode-Build sind ausstehend.

## Gewichtsspalte

TrainingSummary verwendet vor jeder Gewichtsangabe einen 18 pt breiten Platz für die Arbeitsgewicht-Markierung. Bei anderen Gruppen ist das Symbol unsichtbar und für VoiceOver ausgeblendet. Gewichte verwenden tabellarische Ziffern, feste horizontale Eigenbreite und stehen am rechten Rand. Diese Darstellung gilt für den vollständigen Verlauf. Die Startseite verwendet DayTrainingRow mit nur der Arbeitsgruppe.

## Kompakte Trainingserfassung

TrainingEditor zeigt Übungsname und DatePicker in einer gemeinsamen Form-Zeile. Alle Satzgruppen liegen in einer Section. Jede Zeile enthält die 44 pt große Arbeitsgewicht-Schaltfläche, das frei editierbare Satzfeld, ein 44 pt großes Vorauswahl-/Aktionsmenü und das rechtsbündige kg-Feld. Die Zeilen haben keine vertikalen Inhaltsabstände und eine natürliche Mindesthöhe von 44 pt. Ein kurzer Footer erklärt Markierung und Aktionsmenü. Entfernen ist zusätzlich per Wischgeste möglich. Die letzte Gruppe kann nicht entfernt werden.

Vier Gruppen sollen bei Standardtextgröße auf dem iPhone 15 im Hochformat gemeinsam sichtbar sein. Sichtprüfung mit offener und geschlossener Tastatur, längeren Freitexten, vorausgefüllten Standardsätzen und großer Textgröße ist ausstehend. Bei großer Textgröße bleibt die Form scrollbar. Speichern, Vorlagenübernahme und Datenmodell verwenden die vorhandene Logik.

## Bewertung des Arbeitsgewichts

TrainingEditor hält eine optionale TrainingEffort-Auswahl als lokalen Entwurf. Neue Trainings beginnen mit nil, auch bei Übernahme von Standardsätzen oder des letzten Trainings. Beim Bearbeiten wird die gespeicherte Auswahl geladen. Das Menü bietet Nicht bewertet zum Entfernen sowie alle vier ausgeschriebenen Bewertungen. Speichern schreibt die Auswahl zusammen mit den übrigen Trainingsdaten.

TrainingSummary zeigt das Symbol ausschließlich bei der markierten Arbeitsgruppe. Alle Zeilen reservieren eine 26 pt breite Bewertungsspalte, die mit der Bedienungshilfen-Textgröße skaliert. Nicht angezeigte Bewertungen sind für VoiceOver ausgeblendet. VoiceOver spricht die ausgeschriebene Bewertung. DayTrainingRow verwendet dieselbe Bewertungsspalte neben der einzigen Arbeitsgruppe in der Tagesübersicht.

0.4.0 ergänzt effortRawValue als optionales Feld ohne Pflichtwert. Vorhandene Einträge beginnen ohne Bewertung. Das Store-Update muss auf dem Mac über einer Installation mit gespeicherten Trainings geprüft werden.

## Löschabläufe

TrainingEntry.deleteKeepingExercise löst zuerst die optionale Verbindung zur Übung und löscht dann den Trainingseintrag mit seinen eigenen Satzgruppen. Speichern und Rollback liegen in derselben Methode. ExerciseDetailView verwendet genau diesen Einstieg. Damit hat der zu löschende Eintrag beim Löschen keine Elternreferenz mehr.

ExerciseDetailView verwendet einen einzelnen typisierten Alert-Zustand für Trainingsbestätigung, Übungsbestätigung und Fehlermeldung. Die Bestätigungsbuttons nennen das jeweilige Objekt ausdrücklich. Übungen werden über die separate Übungsaktion oder den bestätigten Gesamtlöschvorgang entfernt. Der auf dem Gerät gemeldete Fehler ist hier ohne Simulator nicht reproduziert, die Änderungen sichern beide möglichen Fehlerbereiche ab. Tests prüfen insbesondere den letzten Trainingseintrag.

## Trainingstage auf der Startseite

TrainingDaySummary.grouped verwendet Calendar.startOfDay mit dem lokalen Kalender. DayTrainingRow zeigt pro Trainingseintrag Übungsname, den Text der markierten Arbeitsgruppe, @, die optionale Anstrengungsbewertung und das Gewicht. Ohne markierte Gruppe wird Kein Arbeitsgewicht angezeigt. Vier Übungen mit je einem Eintrag ergeben vier Zeilen. Die vollständigen Satzgruppen sind weiter im Übungsdetail verfügbar. Ein Eintrag ohne Übungszuordnung zeigt Unbekannte Übung und bleibt sichtbar.

## Einstellungen und Beispieldaten

SettingsView wird über das Zahnrad als Sheet geöffnet. TrainingDataOperations.createExamples legt die vier Übungsvorgaben aus der README an. Die Beispieldaten verwenden den 14.11.2026 und 17.11.2026, jeweils um 12 Uhr in der lokalen Zeitzone im gregorianischen Kalender. Alle Satzgruppen werden in der angegebenen Reihenfolge angelegt, die letzte als Arbeitsgruppe. Am 14.11. werden nur von der letzten Gruppe jeweils 2 kg abgezogen, sodass die Arbeitsgewichte 50, 88, 83 und 98 kg betragen. Neue Einträge sind unbewertet.

Der Import verwendet gleichnamige Übungen ohne Beachtung von Groß-/Kleinschreibung und Akzenten wieder, erhält vorhandene Ziele und ergänzt Standardsätze nur bei leerem Bestand. Ein identischer Beispiel-Trainingseintrag wird anhand von Tag, geordnetem Satztext und Gewicht erkannt. Mehrfaches Importieren ergänzt fehlende Einträge. Der gesamte Import wird einmal gespeichert und bei Fehlern zurückgerollt.

TrainingDataOperations.deleteAll löscht Übungen, Trainings, Satzgruppen, Standardsatzvorlagen und alte Item-Datensätze nach Bestätigung. Zuerst werden alle Daten geladen und die Kind-Eltern-Verbindungen gelöst, danach erfolgt das Löschen mit einem gemeinsamen Save. Fehler führen zu Rollback. Die Aktion führt keine Teil-Saves aus.

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

## Abnahme der Bewertung in 0.4.0

1. Über die vorhandene Installation aktualisieren. Trainings, Gewichte und Zielfortschritt müssen erhalten bleiben. Ältere Einträge dürfen kein Bewertungssymbol erhalten.
2. Ein Training mit vier Gruppen erfassen. Alle vier Bewertungen nacheinander auswählen und die Symbolzuordnung prüfen. Mit + speichern und im Verlauf sowie beim letzten Trainingstag kontrollieren. Nur die Arbeitsgruppe erhält +.
3. Ein weiteres Training für dieselbe Übung öffnen. Die Bewertung muss Nicht bewertet sein. Abbrechen, anschließend den bewerteten Eintrag bearbeiten. + muss erhalten bleiben.
4. Auf -- ändern, speichern, App neu starten und prüfen. Danach über Nicht bewertet entfernen und prüfen. Abbrechen einer Bewertungsänderung darf den gespeicherten Wert nicht ändern.
5. Mit unterschiedlichen Gewichten sowie offener und geschlossener Tastatur auf iPhone 15 prüfen, ob die vier Gruppen weiterhin kompakt dargestellt werden. Große Textgröße und VoiceOver prüfen.

## Abnahme von Trainingstagen und Einstellungen in 0.5.0

1. Über die bestehende Installation aktualisieren und den vorhandenen Datenbestand kontrollieren.
2. In einer Testinstallation die Beispieldaten anlegen. Ein Tag mit vier Zeilen muss Press 1 × 5 @ 52 kg, Kniebeuge 3 × 5 @ 90 kg, Bankdrücken 3 × 3 @ 85 kg und Kreuzheben 3 × 5 @ 100 kg zeigen.
3. Erneut Beispieldaten anlegen. Die vier Einträge dürfen keine identischen Duplikate erhalten. Ziele, Standardsätze und alle Aufwärmgruppen im Übungsdetail kontrollieren.
4. Einen älteren Tag und ein zweites Training derselben Übung am selben Tag ergänzen. Gruppierung, Datum und Übungsreihenfolge prüfen.
5. Ein Training löschen, danach alle verbleibenden Trainings derselben Übung löschen. Die Übung muss mit identischer ID, Ziel, Reihenfolge und Standardsätzen erhalten bleiben. Die App neu starten und erneut prüfen.
6. Abbrechen bei Training löschen und Übung löschen prüfen. Die separate Übungsaktion bestätigen und prüfen, ob nur die gewählte Übung mit ihren Daten gelöscht wird.
7. Alles löschen zunächst abbrechen. Danach bestätigen und die leere Startseite kontrollieren. Beispieldaten erneut anlegen.
8. Auf iPhone 15 mit vier Übungen, langer Beschriftung und großer Textgröße prüfen. Xcode-Build und Swift-Tests mit ⌘ U ausführen.

## Abnahme des zweiten Beispieltags in 0.5.1

1. Über eine Installation mit Beispielen vom 17.11.2026 aktualisieren. In den Einstellungen erneut Beispieldaten anlegen.
2. Zwei Trainingstage mit je vier Zeilen prüfen. Am 14.11. müssen Press 50, Kniebeuge 88, Bankdrücken 83 und Kreuzheben 98 kg als Arbeitsgewicht stehen.
3. Die Satztexte und Aufwärmgewichte beider Tage vergleichen. Erneut importieren und prüfen, dass keine identischen Duplikate entstehen.
4. Xcode-Build, Swift-Tests und Sichtprüfung sind ausstehend.

## Veröffentlichung

Nach erfolgreichem Test den vorgesehenen Commit mit `v0.5.2` taggen und das Tag pushen. Externe App-Version und Buildnummer vor einem Upload abstimmen, anschließend in Xcode archivieren und im Organizer prüfen. TestFlight und eine öffentliche Veröffentlichung werden separat beauftragt.
