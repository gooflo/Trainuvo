# Trainuvo – Entwicklerdokumentation

Interne Version **0.9.0**. Dauerhafte Regeln stehen in [AGENTS.md](AGENTS.md) und [AGENTS_general.md](AGENTS_general.md).

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

## Übungstypen und Einheiten in 0.9.0

ExerciseType bietet genau strength (Krafttraining), sets (Satzübung) und other (Andere). usesWeights gilt nur für strength, usesSets für strength und sets. ExerciseType.storedType liest nil und unbekannte Werte wie bisher als strength. Die früheren Rohwerte ergometer, swimming und jogging werden als other gelesen. Die gespeicherten Rohwerte werden beim Lesen nicht verändert. Jeder TrainingEntry behält seinen eigenen Typ, unabhängig von Änderungen der Übung.

Krafttraining verwendet numerische Gewichte und Prozentfortschritt. Satzübungen verwenden dieselben Satzgruppen, Vorauswahlen, Arbeitsgruppen-Markierung und die freie rechte Angabe detailText ohne feste Einheit. workingGroup berücksichtigt beide Satztypen; workingWeight liefert nur für Krafttraining einen Wert. Ein optionales Freitextziel steht in Exercise.targetDescription und wird als Zieltext ohne Prozentberechnung angezeigt. Zielgewicht und Freitextziel bleiben bei Typwechsel erhalten.

Andere verwendet SetGroup.prescription links und detailText rechts. Mindestens eine Angabe je Einheit muss nach dem Trimmen vorhanden sein. Bei Satzübungen müssen im Training beide Angaben vorhanden sein, in Vorlagen darf rechts leer bleiben. Krafttraining behält seine Gewichtsvalidierung. TrainingFormat.isValidUnit bündelt diese Regeln für beide Editoren. Bei freien Typen sind numerisches Gewicht 0 und Arbeitsmarkierung false bzw. bei Satzübungen die gewählte Gruppe gesetzt; 0 wird dort nicht als Gewicht angezeigt.

Die optionale fünfstufige Bewertung gilt für den gesamten TrainingEntry und steht bei allen drei Typen zur Verfügung. Neue Trainings beginnen ohne Bewertung. Bestehende Bewertungen werden geladen; X entfernt sie. Tagesübersicht und Verlauf zeigen sie einmal links vor der Arbeitsgruppe bzw. vor der ersten freien Einheit. Bei Andere benötigen Bewertungen keine Arbeitsmarkierung.

Exercise.sortedSetTemplates filtert nach dem aktuellen Übungstyp. sortedSetTemplates(for:) erlaubt den gezielten Zugriff auf andere Typen. Frühere Freitextvorlagen sind als Andere verfügbar; bei gleichen Positionen sorgt die gespeicherte UUID für eine stabile Reihenfolge. Beim Speichern werden nur Vorlagen des ausgewählten Typs ersetzt. Die übrigen bleiben erhalten. Der Editor puffert je Typ die Vorlagenentwürfe und Arbeitsmarkierung. Abbrechen verändert keine Modelldaten.

ExerciseSetTemplate.prescription und detailText belegen die linke und rechte Angabe vor. Bei Andere darf eines oder beide Felder belegt sein. TrainingEditor übernimmt beide als unabhängige Entwürfe, erzeugt eigene SetGroup-Objekte und verändert die Vorlage nicht. Ohne Vorlagen startet Andere mit zwei leeren Feldern. Bei Satzübungen und Krafttraining werden ohne Vorlagen die Gruppen des letzten passenden Trainings oder 3 × 5 angeboten.

Die neuen Felder targetDescription an Exercise und detailText an ExerciseSetTemplate und SetGroup sind optional. IDs, Modellnamen, bisherige Attribute, Gewichte und Beziehungen werden nicht entfernt. Ein echtes Store-Update über 0.8.0 muss mit Bestandsdaten auf dem Mac geprüft werden. Die Tests mit alten Rohwerten laufen im aktuellen In-Memory-Schema und ersetzen diesen Update-Test nicht.

## Datenmodell und Geschäftsregeln

- Exercise speichert UUID, Name, optionales Zielgewicht und sortOrder (Int, Standardwert 0). Namen werden beim Speichern getrimmt und ohne Beachtung von Groß-/Kleinschreibung und Akzenten auf Duplikate geprüft.
- ExerciseSetTemplate speichert UUID, Reihenfolge, Satztext bzw. freien Einheitstext, Arbeitsgewicht-Markierung und das optionale Feld activityTypeRawValue. Fehlende Typwerte gelten als strength. Exercise hält diese Vorlagen als separate Cascade-Beziehung mit inverser Übungsbeziehung. Die Vorlage enthält keine numerischen Gewichte, darf aber die rechte freie Angabe für Satzübung und Andere vorgeben.
- TrainingEntry speichert UUID, Trainingsdatum, Anlegedatum, Übungsbeziehung und das optionale String-Feld effortRawValue. TrainingEffort bietet die stabilen Werte veryHard, hard, okay, easy und veryEasy mit den Symbolen --, -, o, + und ++. Die Bezeichnungen sind Sehr schwer, Schwer, Neutral, Leicht und Sehr leicht; okay und easy behalten ihre bisherigen Rohwerte. Der berechnete Zugriff effort bildet den String auf das Enum ab. Fehlende oder unbekannte Werte werden als unbewertet dargestellt. Das Datum kann bis heute gewählt werden. Es wird einschließlich Uhrzeit gespeichert.
- SetGroup speichert UUID, Reihenfolge, freien Satztext, Gewicht in kg und die Markierung als Arbeitsgewicht.
- Exercise → TrainingEntry und TrainingEntry → SetGroup sind Beziehungen mit Cascade-Löschung und inversen Elternbeziehungen. TrainingEntry.exercise, SetGroup.entry und ExerciseSetTemplate.exercise haben explizit nullify als Löschregel. Diese entspricht dem bisher impliziten Standard. Es werden keine bestehenden Felder entfernt.
- Bei Krafttraining und Satzübung muss genau eine Satzgruppe als Arbeitsgruppe markiert sein. Das Entfernen der markierten Gruppe markiert die erste verbleibende Gruppe.
- Nur Krafttraining berechnet numerischen Fortschritt = markiertes Arbeitsgewicht des chronologisch letzten Trainings ÷ aktuelles Zielgewicht. Bei gleichem Trainingsdatum entscheidet das Anlegedatum. Werte über 100 % werden als Zahl angezeigt, der Fortschrittsbalken endet bei 100 %.
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

## Akzentfarbe

Die primäre Akzentfarbe ist Blau. ContentView verwendet die Systemfarbe blue für den Tint, die Fortschrittsanzeigen und die Markierung des Arbeitsgewichts. TrainingEditor verwendet dieselbe Farbe für die gewählte Arbeitsgruppe. Das Asset AccentColor enthält zusätzlich blaue Farbwerte für helle und dunkle Darstellung. Die Sichtprüfung von Zielkarten, Schaltflächen, Menüs und Tastaturleiste auf dem Gerät ist ausstehend.

## Zielkarten auf der Startseite

GoalCard zeigt Übungsname und Prozentwert in der Kopfzeile, darunter den Fortschrittsbalken sowie eine gemeinsame Zeile für Zielgewicht, erreichtes Arbeitsgewicht und Trainingsdatum mit zweistelligem Jahr. Fehlende Werte erscheinen als Gedankenstrich. Die Karte verwendet 12 pt Innenabstand und 8 pt Abstand zwischen ihren Zeilen, das Raster 12 pt Kartenabstand. Ihre Kopfzeile reserviert rechts 44 pt für den separaten Plus-Button und hat mindestens 44 pt Höhe. Vier Karten sollen bei Standardtextgröße im iPhone-15-Hochformat vollständig sichtbar sein. Die Informationszeile bleibt einzeilig und kann auf 70 % ihrer Schriftgröße verkleinert werden.

Sichtprüfung auf dem iPhone-15-Simulator mit vier Übungen durchführen. Auch lange Namen, Ziele über 100 %, Übungen ohne Trainings, Übungen ohne Ziel sowie größere Bedienungshilfen-Schriften prüfen. Bei großer Textgröße darf die Übersicht scrollen. Simulatorprüfung und Xcode-Build sind ausstehend.

## Gewichtsspalte

TrainingSummary verwendet vor jeder Gewichtsangabe einen 18 pt breiten Platz für die Arbeitsgewicht-Markierung. Bei anderen Gruppen ist das Symbol unsichtbar und für VoiceOver ausgeblendet. Gewichte verwenden tabellarische Ziffern, feste horizontale Eigenbreite und stehen am rechten Rand. Diese Darstellung gilt für den vollständigen Verlauf. Die Startseite verwendet DayTrainingRow mit nur der Arbeitsgruppe.

## Kompakte Trainingserfassung

TrainingEditor zeigt unterhalb der Buttonleiste einen Header mit Training erfassen bzw. Training bearbeiten und dem Übungsnamen in title2.bold darunter. Der Navigationstitel ist leer, damit der Modustext den vollständigen Platz unter den Buttons nutzt. safeAreaInset am oberen Rand hält die Überschrift auch beim Scrollen und bei geöffneter Tastatur sichtbar. Lange Namen laufen mehrzeilig. Der DatePicker steht separat im Formular mit der Beschriftung Datum. Alle Satzgruppen liegen in einer Section. Jede Zeile enthält die 44 pt große Arbeitsgewicht-Schaltfläche, das frei editierbare Satzfeld, ein 44 pt großes Vorauswahl-/Aktionsmenü und das rechtsbündige kg-Feld. Die Zeilen haben keine vertikalen Inhaltsabstände und eine natürliche Mindesthöhe von 44 pt. Ein kurzer Footer erklärt Markierung und Aktionsmenü. Entfernen ist zusätzlich per Wischgeste möglich. Die letzte Gruppe kann nicht entfernt werden.

Vier Gruppen sollen bei Standardtextgröße auf dem iPhone 15 im Hochformat gemeinsam sichtbar sein. Sichtprüfung mit offener und geschlossener Tastatur, längeren Freitexten, vorausgefüllten Standardsätzen und großer Textgröße ist ausstehend. Bei großer Textgröße bleibt die Form scrollbar. Speichern, Vorlagenübernahme und Datenmodell verwenden die vorhandene Logik.

## Bewertung des Arbeitsgewichts

TrainingEditor hält eine optionale TrainingEffort-Auswahl als lokalen Entwurf. Neue Trainings beginnen mit nil, auch bei Übernahme von Standardsätzen oder des letzten Trainings. Beim Bearbeiten wird die gespeicherte Auswahl geladen. Der für alle Typen verfügbare TrainingEffortSelector heißt Training bewerten und bietet fünf direkt antippbare Auswahlflächen mit Symbol und Kurzbeschriftung. Eine blaue Fläche zeigt die Auswahl, die volle Bedeutung steht darüber. X setzt den lokalen Entwurf auf nil. Die Auswahl verwendet bei normalen Textgrößen fünf Spalten und bei Bedienungshilfen-Schriften zwei Spalten. VoiceOver erhält die vollständige Bedeutung und den Auswahlstatus. Speichern schreibt die Auswahl zusammen mit den übrigen Trainingsdaten.

TrainingSummary zeigt das Symbol bei Satztypen ausschließlich bei der markierten Arbeitsgruppe und bei Andere ausschließlich vor der ersten Einheit. Alle Zeilen reservieren links vor den Sätzen eine 26 pt breite Bewertungsspalte, die mit der Bedienungshilfen-Textgröße skaliert. Nicht angezeigte Bewertungen sind für VoiceOver ausgeblendet. VoiceOver spricht die ausgeschriebene Bewertung. DayTrainingRow verwendet dieselbe Bewertungsspalte neben der einzigen Arbeitsgruppe in der Tagesübersicht.

0.4.0 ergänzt effortRawValue als optionales Feld ohne Pflichtwert. Vorhandene Einträge beginnen ohne Bewertung. Das Store-Update muss auf dem Mac über einer Installation mit gespeicherten Trainings geprüft werden.

## Löschabläufe

TrainingEntry.deleteKeepingExercise löst zuerst die optionale Verbindung zur Übung und löscht dann den Trainingseintrag mit seinen eigenen Satzgruppen. Speichern und Rollback liegen in derselben Methode. ExerciseDetailView und der sichtbare Löschbutton in TrainingEditor verwenden genau diesen Einstieg. Damit hat der zu löschende Eintrag beim Löschen keine Elternreferenz mehr.

ExerciseDetailView verwendet einen einzelnen typisierten Alert-Zustand für Trainingsbestätigung, Übungsbestätigung und Fehlermeldung. Die Bestätigungsbuttons nennen das jeweilige Objekt ausdrücklich. Übungen werden über die separate Übungsaktion oder den bestätigten Gesamtlöschvorgang entfernt. Der auf dem Gerät gemeldete Fehler ist hier ohne Simulator nicht reproduziert, die Änderungen sichern beide möglichen Fehlerbereiche ab. Tests prüfen insbesondere den letzten Trainingseintrag.

## Trainingstage auf der Startseite

TrainingDaySummary.grouped verwendet Calendar.startOfDay mit dem lokalen Kalender. DayTrainingRow zeigt pro Trainingseintrag Übungsname, die optionale Anstrengungsbewertung, den Text der markierten Arbeitsgruppe, @ und das Gewicht. Ohne markierte Gruppe wird Kein Arbeitsgewicht angezeigt. Vier Übungen mit je einem Eintrag ergeben vier Zeilen. Eine Tageszeile öffnet direkt TrainingEditor für diesen Datensatz. Die vollständigen Satzgruppen und der sichtbare Löschbutton sind dort verfügbar. Der gesamte Übungsverlauf wird über die Zielkarte geöffnet. Ein Eintrag ohne Übungszuordnung zeigt Unbekannte Übung und bleibt sichtbar.

## Einstellungen und Beispieldaten

SettingsView wird über das Zahnrad als Sheet geöffnet. TrainingDataOperations.createExamples legt die vier Übungsvorgaben aus der README an. Die Beispieldaten verwenden den 14.11.2026 und 17.11.2026, jeweils um 12 Uhr in der lokalen Zeitzone im gregorianischen Kalender. Alle Satzgruppen werden in der angegebenen Reihenfolge angelegt, die letzte als Arbeitsgruppe. Am 14.11. werden nur von der letzten Gruppe jeweils 2 kg abgezogen, sodass die Arbeitsgewichte 50, 88, 83 und 98 kg betragen. Neue Einträge sind unbewertet.

Der Import verwendet gleichnamige Übungen ohne Beachtung von Groß-/Kleinschreibung und Akzenten wieder, erhält vorhandene Ziele und ergänzt Standardsätze nur bei leerem Bestand. Ein identischer Beispiel-Trainingseintrag wird anhand von Tag, geordnetem Satztext und Gewicht erkannt. Mehrfaches Importieren ergänzt fehlende Einträge. Der gesamte Import wird einmal gespeichert und bei Fehlern zurückgerollt.

TrainingDataOperations.deleteAll löscht Übungen, Trainings, Satzgruppen, Standardsatzvorlagen und alte Item-Datensätze nach Bestätigung. Zuerst werden alle Daten geladen und die Kind-Eltern-Verbindungen gelöst, danach erfolgt das Löschen mit einem gemeinsamen Save. Fehler führen zu Rollback. Die Aktion führt keine Teil-Saves aus.

## Direkte Trainingserfassung und Fokus

ContentView zeigt Zahnrad und Hilfe als ToolbarItemGroup rechts oben. Der Stift neben Deine Übungen öffnet ein Menü für Übung anlegen und Übungen sortieren. Zielkarten kombinieren in einem ZStack einen NavigationLink zum Übungsverlauf und einen separaten 44 pt großen Plus-Button. Das Plus steht außerhalb des NavigationLinks, sodass es ausschließlich die Trainingserfassung für die gewählte Übung öffnet.

TrainingEditor verwendet einen typisierten FocusState mit prescription(UUID) und weight(UUID). Neue Trainings warten in einem abbrechbaren task 350 ms auf den Aufbau des Sheets und der Tastatur-Toolbar. Dieses Muster stammt aus Cashuvo/AddTransactionView.swift. Wenn noch kein Feld fokussiert ist, wird bei Krafttraining das erste kg-Feld aktiviert, bei Satzübungen die rechte freie Angabe und bei Andere links (bei nur links vorbelegter Vorlage rechts). Freie Angaben verwenden die normale Tastatur. Bestehende Einträge erhalten beim Öffnen keinen automatischen Fokus. Die Fertig-Taste setzt den Fokus auf nil. Beim Entfernen der fokussierten Gruppe wird der Fokus ebenfalls gelöst.

Auf dem iPhone 15 vier Zielkarten einschließlich langer Namen und erreichter Ziele prüfen. Plus muss ausschließlich die neue Erfassung öffnen, die übrige Karte den Verlauf. Erstes kg-Feld, numerische Tastatur und Fertig-Taste auf Gerät und Simulator prüfen. Eine weitere Gruppe fokussieren und entfernen, während die Tastatur offen ist. Erneutes Öffnen und schnelles Schließen der Maske müssen den task korrekt abbrechen. Xcode-Build und Gerätetest sind ausstehend.

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

## Sichtbares Löschen eines Trainingseintrags in 0.5.3

TrainingEditor zeigt beim Bearbeiten eines gespeicherten Eintrags unter den Satzgruppen „Dieses Training löschen“. Nach Bestätigung ruft er deleteKeepingExercise auf und schließt sich nach erfolgreichem Speichern. Abbrechen verändert keine Modelldaten. Bei einem Fehler bleibt der Editor mit Fehlermeldung geöffnet. Die Tageszeile auf der Startseite öffnet den Datensatz direkt zum Bearbeiten. Die vorhandene Wischaktion im Übungsverlauf bleibt zusätzlich verfügbar, mit deaktiviertem Full Swipe.

Auf dem Gerät einen von zwei Einträgen einer Übung löschen, anschließend den letzten. Die Übung mit Ziel, Reihenfolge und Standardsätzen muss weiter auf der Startseite stehen. App neu starten und prüfen. Abbrechen in der Bestätigung sowie das Anlegen eines neuen Trainings für die erhaltene Übung prüfen. Xcode-Build und Gerätetest sind ausstehend.

## Abnahme der Übungsüberschrift in 0.6.5

Über das Plus einer Zielkarte ein neues Training öffnen und den Übungsnamen oberhalb des Formulars prüfen. Bei geöffneter numerischer Tastatur mit vier Satzgruppen scrollen. Der Name muss sichtbar bleiben. Ein bestehendes Training vom Trainingstag und aus dem Übungsverlauf öffnen und denselben Kontext prüfen. Lange Übungsnamen, iPhone 15, iPad und große Textgröße prüfen. Xcode-Build und Sichtprüfung sind ausstehend.

## App-Icon und Header in 0.6.6

Das ausgewählte Logo mit der schrägen Hantel liegt als Trainuvo-AppIcon.png im Assetkatalog unter AppIcon.appiconset. Es wurde für den Icon-Export auf 1024 × 1024 Pixel skaliert und als RGB-PNG ohne Alphakanal gespeichert. Contents.json verweist auf diese Datei als universelles iOS-App-Icon. Motiv ist die schräge weiße Langhantel auf blauem Verlauf. Die korrigierte Variante ist seit 0.6.7 eingebaut.

Im TrainingEditor die Titelzeilen unter Abbrechen und Speichern auf iPhone 15 bei geöffneter Tastatur prüfen. Lange Übungsnamen, vier Satzgruppen und große Textgröße einbeziehen. Nach dem Build das Icon auf dem Home-Bildschirm und im App-Umschalter prüfen. Xcode-Build und Sichtprüfung sind ausstehend.

## Abnahme der Bewertungsauswahl in 0.6.9

Ein neues Training mit vier Satzgruppen öffnen. Alle vier Flächen einzeln antippen und die blaue Auswahl sowie die ausgeschriebene Bedeutung prüfen. Insbesondere + muss Leicht – Steigerung möglich anzeigen. Speichern, erneut öffnen und die Auswahl mit X entfernen. Abbrechen einer Änderung muss den gespeicherten Wert erhalten. Die Anzeige im Verlauf und in der Tagesübersicht prüfen. iPhone 15 mit offener/geschlossener Tastatur, Dunkelmodus, großer Bedienungshilfen-Schrift und VoiceOver einbeziehen. Xcode-Build und Geräteprüfung sind ausstehend.

## Abnahme der Übungstypen in 0.7.0

1. Unter 0.6.9 Trainings, Standardsätze, Ziele, Bewertungen und Reihenfolge anlegen bzw. prüfen. Mit 0.7.0 über die vorhandene Installation aktualisieren. Die gespeicherten Daten müssen als Krafttraining weiter funktionieren.
2. Je eine Übung der Typen Ergometer, Schwimmen, Joggen und Andere anlegen. Freie Texte mit Minuten, Watt, Metern und eigenen Angaben eingeben. Die Auswahl darf keine kg-Felder oder Satzvorgaben zeigen.
3. Eine zweite freie Einheit ergänzen, speichern, neu öffnen und ändern. Zeilenumbrüche, Abbrechen und Neustart prüfen. Tagesübersicht und Verlauf müssen den Text anzeigen.
4. Ein einzelnes Freitexttraining und anschließend das letzte dieser Übung löschen. Die Übung muss erhalten bleiben.
5. Eine Kraftübung in Joggen ändern, einen freien Eintrag hinzufügen und ältere Krafttrainings öffnen. Sie müssen ihre ursprünglichen Gruppen, Gewichte und Bewertungen zeigen. Zurück zu Krafttraining wechseln und Ziel, Vorlagen und Fortschritt kontrollieren.
6. Startkarten auf iPhone 15 und iPad, normale und große Textgrößen sowie beide Tastaturarten mit Fertig-Taste prüfen.
7. Xcode-Build und Swift-Tests mit ⌘ U ausführen. Die Tests decken Typ-Altwerte, alle vier Freitexttypen, Persistenz, Typwechsel, Löschung und den Beispieldatenimport ab. Laufzeit- und Geräteprüfung sind ausstehend.

## Abnahme von 0.8.0

1. Über 0.7.0 mit vorhandenen Trainings, Bewertungen und Krafttrainingsvorlagen aktualisieren. Ziele, IDs, Reihenfolge, Gewichte und Vorlagen kontrollieren. Alte o- und +-Bewertungen müssen erhalten bleiben und Neutral bzw. Leicht heißen.
2. Alle fünf Bewertungen auswählen, speichern und nach Neustart prüfen. X und Abbrechen testen. Tagesübersicht und Verlauf müssen das Symbol vor den Sätzen zeigen; Aufwärmgruppen bleiben ohne Bewertung und Gewichte stehen rechtsbündig.
3. Für Ergometer, Schwimmen, Joggen und Andere je mehrere Vorlageneinheiten anlegen, sortieren und speichern. Neue Trainings müssen Texte und Reihenfolge übernehmen. Einheiten im Training ändern und prüfen, dass die Vorlage unverändert bleibt.
4. Vorlagen ändern oder entfernen und gespeicherte Trainings erneut öffnen. Sie müssen ihre eigenen Texte behalten. Ohne Vorlage muss ein neues Freitexttraining mit einer leeren Einheit beginnen.
5. Zwischen Krafttraining und Freitexttypen wechseln, einschließlich Wechsel während der Bearbeitung. Die Vorlagen anderer Typen sowie die Arbeitsmarkierung müssen erhalten bleiben. Abbrechen und Neustart prüfen.
6. Letztes Freitexttraining löschen: Übung und Vorlagen müssen bleiben. iPhone 15 mit vier Satzgruppen, offener Tastatur, Dunkelmodus, großer Schrift und VoiceOver prüfen.
7. Xcode-Build und Swift-Tests mit ⌘ U ausführen. Neue Tests decken fünf Symbole, Rohwertkompatibilität, ++-Persistenz, Vorlagentypen, Altwert-Fallback, Sortierung und unabhängige Trainings ab. Hier wurden nur Swift-Syntax und statische Konsistenz geprüft; alle Laufzeit- und Updateprüfungen sind ausstehend.

## Abnahme von 0.9.0

1. Unter 0.8.0 Krafttrainingsdaten und Vorlagen sowie je einen Eintrag/Vorlage der bisherigen Typen Ergometer, Schwimmen, Joggen und Andere anlegen. Über diese Installation aktualisieren. Alte Texte, Gewichte, IDs, Bewertungen, Reihenfolge und Vorlagen müssen erhalten bleiben. Frühere Freitexttypen müssen als Andere erscheinen; Krafttraining bleibt unverändert.
2. Die Typauswahl muss genau Krafttraining, Satzübung und Andere anbieten. Eine Satzübung Klimmzüge mit vier Satzgruppen anlegen. Rechts freie Texte ohne kg, Vorauswahl, Arbeitsmarkierung, optionales Freitextziel, Übernahme der Vorlagen und normale Tastatur mit Fertig prüfen.
3. Andere mit zwei Vorlagen anlegen: 200 W / leer und 100 W / 10 min. Sortieren, speichern und neues Training öffnen. Beide Felder müssen übernommen sein, die leere rechte Angabe ergänzbar. Nur rechts, beide leer, mehrzeilige Angaben und mehrere Einheiten prüfen. Leere Einheiten dürfen nicht speicherbar sein.
4. Vorlagen ändern, Einträge bearbeiten/abbrechen, App neu starten und den Verlauf prüfen. Bestehende Trainings behalten beide eigenen Angaben. Typwechsel müssen die anderen Vorlagen und Ziele erhalten.
5. Bei allen drei Typen jede Bewertung auswählen, speichern, erneut öffnen, ändern und mit X entfernen. Ein neues Training beginnt unbewertet. In Tagesübersicht und Verlauf erscheint die Bewertung einmal vor der Arbeitsgruppe bzw. ersten freien Einheit.
6. Einzelne und letzte Trainings löschen. Übung und Vorlagen müssen erhalten bleiben. Beispieldaten weiterhin nur als Krafttraining ergänzen.
7. Xcode-Build mit ⌘ R und Tests mit ⌘ U ausführen. iPhone 15 mit vier Gruppen, Tastatur, großer Schrift, VoiceOver, Dunkelmodus und langen Angaben prüfen.

Hier sind nur Swift-Syntax und statische Konsistenz geprüft. Xcode-Build, Swift-Tests, Store-Migration und Geräteprüfung sind ausstehend.

## Veröffentlichung

Nach erfolgreichem Test den vorgesehenen Commit mit `v0.9.0` taggen und das Tag pushen. Externe App-Version und Buildnummer vor einem Upload abstimmen, anschließend in Xcode archivieren und im Organizer prüfen. TestFlight und eine öffentliche Veröffentlichung werden separat beauftragt.
