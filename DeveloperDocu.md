# Trainuvo – Entwicklerdokumentation

Interne Version **0.16.0**. Dauerhafte Regeln stehen in [AGENTS.md](AGENTS.md) und [AGENTS_general.md](AGENTS_general.md).

## Einrichtung und Build

Die Arbeitskopie liegt auf dem Mac unter `~/Developer/Trainuvo`. In Xcode `Trainuvo.xcodeproj` öffnen, über **Integrate → Pull…** den Stand von `main` holen, das Scheme **Trainuvo** und einen verfügbaren iPhone-Simulator wählen. Mit **⌘ R** bauen und starten.

Das vorhandene Projekt nutzt das Xcode-27.2-Format `project.xcproj` und Ordner mit automatischer Target-Zuordnung. Neue Swift-Dateien im Ordner Trainuvo gehören dadurch zum App-Target. Bundle-ID und Signing-Team stammen aus dem Grundprojekt. Das App-Target setzt inzwischen iOS/iPadOS 17.6 voraus; projektweite Vorgabe und Unit-Test-Target verbleiben bei 27.2.

## Architektur

| Datei | Verantwortung |
|---|---|
| TrainuvoApp.swift | Persistenter SwiftData-/CloudKit-Container, Migrationsplan, Öffnungsfehler und isolierte Debug-Schema-Einrichtung |
| TrainingModels.swift | Aktuelles VersionedSchema V4 mit sechs Modellen, aktuelle Typaliase und Berechnungen |
| TrainuvoSchemaV1.swift / TrainuvoMigrationPlan.swift | Unverändertes ausgeliefertes Modell und V1→V2-Migration |
| CloudSyncInfoView.swift | iCloud-Accountstatus, Offline-/Sync-Hinweise |
| ContentView.swift | Startseite, Zielkarten, gruppierte Trainingstage, Übungsdetail und Hilfe |
| SettingsView.swift | Einstellungsseite, Bestätigung für Alles löschen und Import-Rückmeldung |
| TrainingDataOperations.swift | Beispieldatenimport und vollständiges Löschen mit gemeinsamem Save/Rollback |
| ExerciseOrderEditor.swift | Reihenfolge der Übungen als lokalen Entwurf bearbeiten und explizit speichern |
| TrainingEditors.swift | Eingabeentwürfe, Validierung und explizites Speichern |
| Item.swift / TrainingDayNote.swift | Verweise auf die in TrainingModels.swift versionierten Modelle |

Die interne Version ist in der Build-Einstellung TRAINUVO_INTERNAL_VERSION (aktuell 0.16.0) hinterlegt. Trainuvo-Info.plist enthält ausdrücklich TrainuvoInternalVersion mit $(TRAINUVO_INTERNAL_VERSION); Xcode expandiert den Wert beim Build. Die Hilfe liest TrainuvoInternalVersion, CFBundleShortVersionString und CFBundleVersion aus Bundle.main. Wie Cashuvo zeigt sie eine dezente Textzeile in einem eigenen Abschnitt oberhalb der übrigen Hilfe: Version 1.0.0 (9), v0.15.0. Fehlende Metadaten erscheinen als „–“. Nächster Upload extern 1.0.0 (9) geplant; Buildnummer vor Upload prüfen.

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

## Speicherung und Migration ab 0.13.0

TrainuvoSchemaV1 friert das Modell aus dem veröffentlichten Tag v0.12.0 ein. Die persistenten Deklarationen in 0.12.1 sind damit identisch. V1 nicht nachträglich verändern. Das aktuelle TrainuvoSchemaV2 enthält dieselben sechs Modellnamen; globale Typaliase halten die übrige App lesbar. Item bleibt für alte Grundprojekt-Daten erhalten.

V2 macht ausschließlich die gespeicherten Listenbeziehungen Exercise.entries, Exercise.setTemplates und TrainingEntry.groups optional und ergänzt einen Default für Item.timestamp. Namen, IDs, inverse Beziehungen und Löschregeln bleiben erhalten. trainingEntries, templates und setGroups sind berechnete, beschreibbare Listen-Zugriffe mit leerer Liste für nil. CloudKit kann Beziehungen zeitversetzt liefern. Die Ansicht muss daher fehlende Zuordnungen und Gruppen vertragen. Alle erforderlichen Attribute haben Defaults, optionale Attribute bleiben optional; Unique-Constraints werden nicht verwendet.

TrainuvoMigrationPlan enthält ab 0.13.2 die leichtgewichtige Folge TrainuvoSchemaBeforeDayNotes → V1 → V2; der zusätzliche Ausgangsstand hat noch kein TrainingDayNote. Die App öffnet das versionierte Schema am bisherigen Standardpfad: kein eigener Containername, keine neue Store-URL und kein Reset. ModelConfiguration nutzt explizit .private("iCloud.com.vogtapps.Trainuvo"). Ein Fehler verhindert das Öffnen und zeigt eine Meldung, ohne den Store zu löschen oder einen leeren Ersatz anzulegen. Die Kompatibilität mit einer tatsächlich ausgelieferten Installation muss auf dem Mac geprüft werden.

TrainingMigrationTests erzeugt dateibasierte V1-Stores, einmal mit dem bisherigen unversionierten Schema und einmal mit VersionedSchema. Der Test migriert alle drei Übungstypen, IDs, Ziele, Sortierung, Vorlagen, Gruppen, Werte, Bewertung, Notiz und Item; danach löscht er das letzte Training der ersten Übung, öffnet erneut, legt ein Training an und prüft dessen erneutes Laden. Diese Tests sind hier mangels Xcode nicht ausgeführt. Zusätzlich bleibt ein realer Update-Test erforderlich; der Testnachbau ersetzt keinen Store aus einem alten App-Build.

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

## Bewertung des Trainings

TrainingEditor hält eine optionale TrainingEffort-Auswahl als lokalen Entwurf. Neue Trainings beginnen mit nil, auch bei Übernahme von Standardsätzen oder des letzten Trainings. Beim Bearbeiten wird die gespeicherte Auswahl geladen. Der für alle Typen verfügbare TrainingEffortSelector heißt Training bewerten und bietet fünf direkt antippbare Auswahlflächen mit Symbol und Kurzbeschriftung. Ein 3 pt breiter Rahmen in der Bewertungsfarbe und ein mit 10 % Deckkraft getönter Hintergrund zeigen die Auswahl; ungewählte Flächen haben einen 1 pt breiten neutralen Rahmen. Die volle Bedeutung steht darüber. X setzt den lokalen Entwurf auf nil. Die Auswahl verwendet bei normalen Textgrößen fünf Spalten und bei Bedienungshilfen-Schriften zwei Spalten. VoiceOver erhält die vollständige Bedeutung und den Auswahlstatus. Speichern schreibt die Auswahl zusammen mit den übrigen Trainingsdaten.

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

ContentView zeigt Zahnrad und Hilfe als ToolbarItemGroup rechts oben. Der Stift neben Übungen öffnet ein Menü für Übung anlegen und Übungen sortieren. Zielkarten kombinieren in einem ZStack einen NavigationLink zum Übungsverlauf und einen separaten 44 pt großen Plus-Button. Das Plus steht außerhalb des NavigationLinks, sodass es ausschließlich die Trainingserfassung für die gewählte Übung öffnet.

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

## Bewertungsfarben in 0.9.1

TrainingEffortStyle.swift ergänzt die reine UI-Eigenschaft displayColor. Sie liest TrainingEffort_<rawValue> aus dem Assetkatalog. Die fünf Colorsets definieren sRGB-Werte für helle und dunkle Darstellung: veryHard Dunkelrot, hard Rot, okay Grau, easy Grün und veryEasy Dunkelgrün. Die dunklen Varianten sind für dunkle Hintergründe aufgehellt; die extremen Stufen bleiben gegenüber den einfachen Stufen dunkler.

TrainingEffortSelector und die vier Bewertungsdarstellungen in DayTrainingRow und TrainingSummary verwenden diese gemeinsame Zuordnung. Unbewertete bzw. unmarkierte Gruppen bleiben leer; Symbolspalten und Ausrichtung sind unverändert. Zeichen, ausgeschriebene Bedeutungen und VoiceOver-Auswahlstatus unterstützen die Unterscheidung unabhängig von Farben. Modell, gespeicherte Rohwerte und Speichern-/Löschabläufe werden nicht verändert.

Für die Abnahme bei Krafttraining, Satzübung und Andere alle fünf Bewertungen wählen, speichern und in Tagesübersicht und Verlauf vergleichen. Rahmen, Abbrechen, Entfernen über X und Neustart prüfen. Helle/dunkle Darstellung, große Schrift und VoiceOver auf iPhone 15 einbeziehen. Swift-Syntax, JSON-Assets und Zuordnung wurden statisch geprüft. Xcode-Build und Geräteprüfung sind ausstehend.

## Veröffentlichung

Nach erfolgreichem Test den vorgesehenen Commit mit `v0.13.0` taggen und das Tag pushen. Externe App-Version und Buildnummer vor einem Upload abstimmen, anschließend in Xcode archivieren und im Organizer prüfen. TestFlight und eine öffentliche Veröffentlichung werden separat beauftragt.

## Export in 0.10.0

TrainingExportView verwendet Cashuvos PeriodMode-Konzept mit Monat/Jahr und freier Von–Bis-Auswahl. TrainingExport.selected filtert ab startOfDay(Von) bis exklusiv startOfDay(Bis)+1 Kalendertag, ohne feste Sekundendauer; Zeitumstellungen und Uhrzeiten am Bis-Tag bleiben korrekt. Alle Formate verwenden dieselbe Gruppierung wie die Startseite: neueste Kalendertage zuerst, darin die gespeicherte Übungsreihenfolge.

TrainingExport.text verwendet die absteigenden Tage aus TrainingDaySummary ohne Umkehrung. Pro Tag wird genau eine Textzeile erzeugt. Innerhalb eines Tages gilt die vorhandene Übungsreihenfolge. Satztypen verwenden workingGroup, Andere alle Gruppen mit linker/rechter Angabe und Semikolon zwischen Einheiten. Mehrfach erfasste Übungen werden nicht zusammengelegt. oneLine normalisiert Whitespace ausschließlich für diesen kompakten Text. Rohtexte im JSON/Excel behalten Zeilenumbrüche.

JSON ist ein versionierter Codable-Snapshot (schemaVersion 1) mit ISO-8601-Datumswerten, ausgewähltem Von/Bis, Zeitzone, Eintrags- und Gruppen-IDs, aktuellem Übungsnamen und aktuellen Zielen, normalisiertem und gespeichertem Typ, optionaler Bewertung und sämtlichen Gruppen. Ziele und Namen sind aktuelle Metadaten, keine historischen Momentaufnahmen. Gewicht wird nur für Krafttraining als Zahl exportiert. Es gibt keine Import-/Restore-Funktion.

TrainingExportExcel übernimmt Cashuvos unkomprimierten ZIP-Writer samt CRC32 und XML-Escaping. Die Tabelle enthält alle Satzgruppen und freien Einheiten, eine Zeile je Gruppe mit Datum, Übung, Typ, Bewertung, Position, linker Angabe, numerischem kg-Gewicht, rechter Angabe, Arbeitsmarkierung und Training-ID. Inline-Textzellen verhindern eine Interpretation eingegebener Texte als Formeln. Die Kopfzeile ist fixiert. Einträge ohne Gruppen bleiben mit leerer Detailzeile sichtbar.

TrainingExport.fileURL erstellt pro Export ein eigenes temporäres UUID-Verzeichnis mit dem Standardnamen Trainuvo_Export und passender Endung. TrainingExportFileNameView bietet vor dem System-Teilen die editierbare Dateinamen-Eingabe. Text kann zusätzlich direkt über UIPasteboard kopiert werden. Ungültige Zeiträume und leere Ergebnisse deaktivieren Aktionen. Fehler erscheinen als Meldung. Der Ablauf liest SwiftData ausschließlich; gespeicherte Daten werden nicht verändert.

Tests in TrainingExportTests.swift prüfen Tagesgrenzen einschließlich 25-Stunden-Tag, exakten OneNote-Text, freie Angaben und Zeilenumbrüche, JSON-Snapshot mit IDs und sämtlichen Gruppen sowie XLSX-Einträge inklusive CRC und XML-Parsing. Hier sind Swift-Syntax und statische Konsistenz geprüft. Auf dem Mac ⌘ U ausführen; mit Beispieldaten 14.–17.11.2026 exportieren und zwei Absätze bzw. acht JSON-Einträge und 18 Detailzeilen in Excel prüfen. Einfügen in OneNote, Monate/Schaltjahre, freie Zeiträume, leere Auswahl, Abbrechen und Speichern sowie iPhone/iPad testen. Xcode-Build und Laufzeittests sind ausstehend.

In 0.10.1 stehen die vier Aktionen Text kopieren, Textdatei, Excel und JSON unmittelbar untereinander in der Section Export; die Vorschau folgt danach. Xcode-Build, Swift-Tests und Sichtprüfung sind ausstehend.

0.10.2 entfernt ausschließlich den erklärenden Footer der Export-Section. Vier Aktionen und Vorschau bleiben direkt aufeinanderfolgend. Sichtprüfung in Xcode ausstehend.

## Tagesnotizen in 0.11.0

TrainingDayNote ist ein zusätzliches SwiftData-Modell mit UUID, dayKey (gregorianisch yyyy-MM-dd) und Text. Es hat keine Beziehung zu Übung oder Training, sodass deren Löschung die Notiz erhält. Der App-Container und betroffene In-Memory-Tests registrieren das zusätzliche Modell. Bisherige Modelle und Felder bleiben unverändert. Das Store-Update über 0.10.2 muss auf dem Mac mit Bestandsdaten geprüft werden.

TrainingDaySummary.grouped vereinigt Trainingstage und nichtleere Notiztage. Der Tageskommentar wird als noteText angeboten; Tage ohne Trainings bleiben sichtbar, auch ohne Übungen. Die Schlüssel werden in der lokalen Zeitzone gelesen und geschrieben. Der Editor arbeitet mit einem lokalen Textentwurf. Speichern trimmt Rand-Whitespace und führt ein Save mit Rollback durch. Leerer Text entfernt die Notiz, der sichtbare Löschbutton verlangt Bestätigung. Doppelte Notizen desselben Tages werden zur verlustfreien Bearbeitung zusammen angezeigt und beim Speichern zu einem Datensatz zusammengeführt. Ein Datumswechsel eines Trainings verschiebt die unabhängige Notiz nicht.

TrainingExport.selectedNotes filtert inklusive beider Randtage. Text/TXT ergänzen Notiz am Zeilenende, interne Zeilenumbrüche werden nur für diesen kompakten Text normalisiert. JSON schemaVersion 2 ergänzt dayNotes mit Tageskennung und unverändertem Text. Excel ergänzt die Spalte Tageskommentar bei den Detailzeilen; Tage ohne Trainings erhalten eine eigene Zeile. Exportaktionen bleiben bei reinen Notiztagen aktiv. TrainingDataOperations.deleteAll löscht Notizen mit demselben Save/Rollback wie übrige Daten.

Tests in TrainingDayNoteTests prüfen Speicherung, Bearbeiten, unabhängiges Löschen, Notiztage ohne Trainings, Tageszuordnung, Zeitraum, Text/JSON/XLSX und Gesamtlöschung. Auf dem Mac ⌘ U ausführen und über 0.10.2 aktualisieren. Kommentar mit Zeilenumbrüchen anlegen, abbrechen/bearbeiten/löschen, letztes Training und letzte Übung löschen, App neu starten und Notiztag einschließlich aller Exporte kontrollieren. Das Löschen einer Notiz muss Trainings erhalten. Helle/dunkle Darstellung und iPhone/iPad prüfen. Hier sind Syntax und statische Verknüpfungen geprüft; Xcode-Build, Swift-Tests, Store-Update und Sichtprüfung sind ausstehend.

0.11.1 kürzt die Startseitenüberschrift auf „Übungen“ und passt die Verweise in der Hilfe an. Reine Textänderung, statisch geprüft; Sichtprüfung auf dem Gerät ausstehend.

0.11.2 benennt die Überschrift Trainingstage auf der Startseite und in der Hilfe in Trainings um. Gruppierung und Daten bleiben erhalten. Textänderung statisch geprüft, Xcode-Build und Sichtprüfung ausstehend.

## Anpassbare Dateinamen in 0.12.0

TrainingExportFileNameView und TrainingActivityShareView übernehmen den Ablauf aus Cashuvo/AccountStatementView.swift. Die erzeugte Quelldatei wird über einen optionalen ExportFile-Wert mit eigener UUID als Sheet übergeben; die Namenseingabe ist dadurch bereits beim Öffnen initialisiert. Der Dialog zeigt den Namen ohne Endung, die feste Endung steht separat rechts. Abbrechen verändert keine Trainingsdaten und legt keine Kopie unter dem eingegebenen Namen an.

TrainingExportFileName.baseName validiert die Eingabe, trimmt äußeren Whitespace und entfernt eine bereits eingegebene passende Endung ohne Beachtung der Groß-/Kleinschreibung. Leere Namen, Punkt/Punktpunkt, Pfadtrenner, Doppelpunkt und Steuerzeichen werden abgewiesen. Teilen kopiert die Datei in ein neues temporäres UUID-Verzeichnis unter dem gewünschten Namen und öffnet UIActivityViewController. Fehler entfernen das neue Verzeichnis und zeigen eine Meldung. Temporäre Dateien bleiben für asynchron lesende Share-Erweiterungen verfügbar. Der frühere FileDocument/fileExporter-Ablauf entfällt.

Default für TXT/XLSX/JSON: Trainuvo_Export.<Endung>, ohne Zeitraum. Zeitraumfilter und Dateiinhalte bleiben unverändert. Tests prüfen gültige/ungültige Namen, Umlaute, passende Endungen und getrennte temporäre Verzeichnisse. In Xcode ⌘ U ausführen; alle Formate mit Standardname und eigenem Namen exportieren, Abbrechen und erneutes Öffnen, Teilen und In Dateien sichern auf iPhone/iPad prüfen. Swift-Syntax und statische Konsistenz hier geprüft; Xcode-Build, Swift-Tests und Geräteprüfung ausstehend.

## Veröffentlichter Stand

- 19.11.2026: Florian hat 0.12.0 als getaggt und veröffentlicht bestätigt.
- Remote-Tag v0.12.0 geprüft: a8f147782006d5b88939df1b55f06cf7c663e037.
- Die konkrete externe Versions-/Buildkennung des hochgeladenen Archivs wurde nicht separat bestätigt. Die Projektvorgabe am Tag ist extern 1.0, Build 1.
- Weitere Uploads benötigen eine neue Buildnummer; veröffentlichte Tags werden nicht verschoben.

## Hinweis zur Export-Compliance

Apple verwendet ITSAppUsesNonExemptEncryption (Boolean). NO ist für Apps ohne nicht ausgenommene Verschlüsselung vorgesehen, einschließlich verlinkter Bibliotheken. Bei generierter Info.plist kann INFOPLIST_KEY_ITSAppUsesNonExemptEncryption auf NO gesetzt werden. Die Einstellung wurde inzwischen von Florian auf NO gesetzt und im Remote-Stand vor der Vorbereitung von 0.12.1 geprüft. Vor Anwendung die App und Bibliotheken auf nicht ausgenommene Verschlüsselung prüfen. Quelle: https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption

## Bisherige Vorbereitung: 0.12.1 / 1.0.0 (3)

Die App sowie Test-Targets verwenden Buildnummer 3; die externe Version ist mit Florian auf 1.0.0 abgestimmt. Build 2 ist laut Florian bereits belegt. Interne Version und Hilfe zeigen 0.12.1. Die vom Nutzer eingestellten Werte für Export-Compliance (NO) und App-Mindestversion iOS/iPadOS 17.6 bleiben erhalten. Die projektweite Vorgabe und Unit-Test-Mindestversion bleiben 27.2. Version 0.12.0 ist weiterhin der bestätigte veröffentlichte Stand mit unverändertem Tag v0.12.0. Florian hat den Schritt anschließend als erledigt bestätigt; App Store Connect wurde hier nicht unabhängig geprüft. Versionskonsistenz und unveränderte weitere Build-Einstellungen statisch geprüft; kein Xcode-Archiv hier erstellt.

Die TestFlight-Checkliste und das WhatsApp-Format aus Cashuvo sind jetzt auch in Trainuvos AGENTS.md verbindlich festgehalten. Vor dem Hochladen im Organizer intern 0.12.1 / extern 1.0.0 (3) kontrollieren. Der tatsächliche Status und bereits verwendete Builds in App Store Connect sind hier nicht direkt abrufbar; die Meldung zu Build 2 stammt von Florian. Die interne Version bleibt auf ausdrücklichen Wunsch 0.12.1. Einstellungen statisch geprüft, kein neues Archiv erstellt.


## iCloud einrichten und 0.13.0 prüfen

Vorbereitet: intern **0.13.0**, extern weiterhin **1.0.0**, Build **4**. Build 4 vor Upload in App Store Connect auf Verfügbarkeit prüfen. Export-Compliance NO und App-Mindestversion 17.6 bleiben erhalten. Die Unit-Tests benötigen gemäß unverändertem Test-Target einen Simulator ab iOS 27.2.

### 1. Vorhandene Daten erhalten und Signierung einrichten

1. Vor dem Update vorhandene Daten über das Teilen-Symbol → Export als JSON sichern. Export ist noch kein Import. Die bestehende App nicht deinstallieren und kein „Alles löschen“ verwenden.
2. In Xcode **Integrate → Pull…** für main. Projekt → Target **Trainuvo** → **Signing & Capabilities** öffnen. Team und **Automatically manage signing** prüfen; Bundle-ID bleibt com.vogtapps.Trainuvo.
3. Über **+ Capability → iCloud** hinzufügen bzw. prüfen. **CloudKit** aktivieren und genau **iCloud.com.vogtapps.Trainuvo** auswählen. Falls noch nicht vorhanden, mit **+** diesen Container anlegen; Xcode registriert ihn für das Team. Kein iCloud Documents/Key-Value Store erforderlich. Der Assistent hat keinen Zugriff auf die Apple-Signierungsverwaltung.
4. **Push Notifications** sowie **Background Modes → Remote notifications** aktivieren bzw. prüfen. Trainuvo.entitlements und Trainuvo-Info.plist sind bereits referenziert; keine zweite Info.plist/Entitlements-Datei mit widersprüchlichen Werten erzeugen. Den Root-Plist nicht als App-Ressource kopieren. Provisioning aktualisieren lassen. Nutzer müssen keine sichtbaren Push-Nachrichten erlauben; dies dient dem Hintergrundabgleich.
5. Mit **⌘ B** bauen, dann auf einem passenden Simulator mit **⌘ U** alle Unit-Tests ausführen, insbesondere TrainingMigrationTests. Bei einem Fehler nicht Store/Simulator/App löschen, sondern Fehlermeldung prüfen.

### 2. Development-Schema initialisieren

1. Auf einem Testgerät oder Simulator unter iCloud mit einem Apple-Account anmelden; iCloud für Trainuvo erlauben. Im Scheme **Product → Scheme → Edit Scheme… → Run → Arguments → Arguments Passed On Launch** den Debug-Parameter **-initializeCloudKitSchema** hinzufügen und aktivieren.
2. Mit **⌘ R** im Debug-Build einmal starten. In der Xcode-Konsole nach **Development schema initialized** suchen. Die Initialisierung erzeugt nur Schema-/Testdaten in einem getrennten temporären Store und entfernt den lokalen Hilfsstore anschließend. Der eigentliche App-Store wird von diesem Helfer nicht geöffnet. Ein Fehler muss behoben werden, bevor fortgefahren wird.
3. Den Parameter danach wieder deaktivieren/entfernen. In der [CloudKit Console](https://icloud.developer.apple.com/) den Container **iCloud.com.vogtapps.Trainuvo → Development → Schema** prüfen. Alle sechs Modelltypen (üblicherweise CD_Exercise, CD_ExerciseSetTemplate, CD_TrainingEntry, CD_SetGroup, CD_TrainingDayNote, CD_Item) und ihre Felder müssen vorhanden sein.

### 3. Bestandsdaten und zwei Geräte testen

- Auf einem Testgerät zunächst den bisherigen 0.12.1-Build mit Beispieldaten verwenden; Ziele, alle drei Typen, Standardsätze, mehrere Tage/Gruppen, Bewertungen und Tagesnotiz ergänzen. Anzahl/IDs nach Möglichkeit per JSON vergleichen. Dann 0.13.0 **über die bestehende Installation** installieren. Keine Deinstallation. Alles muss nach Update und Neustart erhalten sein.
- Zwei Geräte mit demselben Apple-Account und derselben CloudKit-Umgebung verwenden. Xcode-Debug verwendet Development, TestFlight Production; ein Debug-Gerät und ein TestFlight-Gerät sind kein gültiges Sync-Testpaar. Zum Prüfen beide Apps im Vordergrund öffnen und dem Abgleich Zeit geben.
- Auf A eine Übung und ein Training je Typ anlegen. B muss Ziele, Typen, beide freien Felder, Satzgruppen, Arbeitsgruppe und Bewertung übernehmen. Auf B Zielgewicht, Vorlagen und Übungsreihenfolge ändern; A muss dies übernehmen.
- Tageskommentar auf A anlegen, auf B bearbeiten. Einen notiz-only Tag prüfen; Export TXT/JSON/XLSX muss dieselben Daten zeigen. Gleichzeitig offline angelegte Notizen desselben Tages bleiben zusammen sichtbar; beim Bearbeiten werden sie zu einem Text konsolidiert.
- A offline setzen, ein Training anlegen und bestehendes ändern. Nach Wiederverbindung auf B kontrollieren. Bei gleichzeitigen Änderungen desselben Datensatzes gelten die Konfliktregeln des Apple-Abgleichs; keine eigene Versionshistorie oder feldweise manuelle Konfliktauflösung.
- Auf B das letzte Training einer Übung löschen. Auf A muss das Training verschwinden; Übung, Ziel, Sortierung, Vorlagen und Tagesnotiz bleiben erhalten. Eine Notiz löschen und den Erhalt der Trainings prüfen. „Alles löschen“ nur mit entbehrlichen Testdaten testen, weil die Löschung synchronisiert wird.
- Geräte ohne iCloud-Anmeldung müssen weiter lokal arbeiten können; Accountstatus zeigt die fehlende Anmeldung. Nach Wiederanmeldung den Nachholabgleich prüfen. Ein Accountstatus „Angemeldet“ belegt lediglich die Verfügbarkeit des Accounts, keinen abgeschlossenen Upload/Download.

Unabhängig auf mehreren Geräten bereits angelegte, gleichnamige Übungen werden nicht anhand ihres Namens dedupliziert. Sync führt die Datensätze zusammen, erfindet aber keine gemeinsame Identität. Beispieldaten nicht gleichzeitig offline auf beiden Geräten erzeugen. Keine automatische Löschung anhand von Namen ergänzen.

### 4. Vor TestFlight

Nach erfolgreichen Tests in der CloudKit Console **Development → Schema → Deploy Schema Changes… → Production** ausführen und alle benötigten Typen/Felder/Indizes übernehmen. Es wird das Schema übertragen, nicht der Inhalt der Development-Datenbank. Produktionsdaten bleiben pro Apple-Account privat. Danach den Release-Build archivieren, Signierungs-Entitlements und das finale Info.plist (UIBackgroundModes remote-notification, interne Version, Export-Compliance NO) prüfen und gemäß Release-Checkliste verteilen. Vor Upload den getesteten Commit mit v0.13.0 taggen und mit **Include tags** pushen. Keine bereits veröffentlichten Tags verschieben.

Auch Production anschließend auf zwei Geräten mit demselben TestFlight-Build prüfen, einschließlich Update über Build 3. In Production später additive CloudKit-Schemaänderungen verwenden; Feld-/Typumbenennungen und Löschungen nicht als unverfängliche Refactorings behandeln.

Technische Grundlage: [Apple: Syncing model data across a person’s devices](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices).

Prüfstand: Quelltext, Swift-Syntax, XML-Plists, Projektkonfiguration und Versionen statisch geprüft. **Kein Xcode/Apple-SDK verfügbar:** kein Build, keine ausgeführten Swift-Tests, kein realer Store-Update-Test und kein CloudKit-Geräteabgleich. t05 ist implementiert, aber noch nicht für Verteilung abgenommen.


## Diagnose des Öffnungsfehlers: 0.13.1 / 1.0.0 (5)

Florian hat für Build 4 erfolgreiche Xcode-/Unit-Tests, Initialisierung des Development-Schemas, Deployment nach Production und ein erfolgreiches iPad-Update mit vollständigem Datenbestand bestätigt. Auf dem iPhone unter iOS 27.2.1 liefert Core Data dagegen Code 134504 (unknown model version) beim Öffnen von default.store. Build 3 war laut Florian sehr wahrscheinlich installiert. Das aktuelle iPadOS funktioniert; ein Betriebssystemunterschied ist nicht nachgewiesen. Aus dem Log allein folgt nicht, welche Entitäts-/Modellhashes abweichen. t38 bleibt offen.

StoreDiagnostics ermittelt nach einem fehlgeschlagenen Container-Start den bisherigen Standardpfad aus ModelConfiguration und kopiert Store/WAL/Journal in ein temporäres Verzeichnis. Core Data liest Metadaten ausschließlich von der Kopie mit NSReadOnlyPersistentStoreOption; die Originaldateien werden nicht über eine Datenbank-API geöffnet. Es startet keinen zweiten Container, ändert keine Metadaten, erzeugt keinen Ersatzstore und führt keine Reparatur aus. Existiert kein Store, wird keiner angelegt. NSManagedObjectModel.makeManagedObjectModel erzeugt nur die Referenzmodelle aus den unveränderten V1/V2-Typen; entityVersionHashesByName und isConfiguration(withName:compatibleWithStoreMetadata:) zeigen Kompatibilität und Abweichungen. Diese strukturelle Prüfung ist noch kein Nachweis einer erfolgreichen SwiftData-Migration.

StoreFailureView zeigt die bisherige Fehlermeldung sowie Diagnose kopieren (Zwischenablage), Diagnose teilen (System-Teilen) und aufklappbare technische Details. Der Bericht enthält interne/externe Version/Build, OS, Fehlertyp/-Domain/-Code, Modellversionskennungen und Entitätshashes. Keine ModelContext-Fetches, Trainingswerte, Accountkennungen, Store-UUIDs oder absoluten Dateipfade. Beliebige NSError.userInfo und localizedDescription werden nicht in den Bericht übernommen, weil sie Nutzerdaten enthalten können; nur Fehlercodes einer begrenzten NSUnderlyingError-Kette werden aufgenommen. Die bisherige lokale Fehlermeldung bleibt auf dem Bildschirm sichtbar.

Prüfung: In Xcode Integrate → Pull…, ⌘ B und ⌘ U. StoreDiagnosticsTests prüft fehlenden Store (keine Dateierzeugung), einen synthetischen V2-Store (Store-Datei unverändert, Testdaten danach ladbar, Hashvergleich erfolgreich) und private Inhalte in NSError (nicht exportieren). Die vorherigen Migrationstests bleiben bestehen. Kein Apple-SDK hier verfügbar, daher nur Swift-Syntax und statische Konsistenz geprüft.

Für das betroffene iPhone wird 1.0.0 (5) als neuer TestFlight-Diagnosebuild benötigt, intern 0.13.1. Vor Upload freien Buildwert prüfen, nach erfolgreichem Test v0.13.1 taggen/pushen. Build 4 und veröffentlichte Tags erhalten. Weder den fehlerhaften Store noch die App löschen; den Diagnosebuild darüber installieren. Bei Fehler Diagnose kopieren und Bericht zur Auswertung bereitstellen. Noch kein bestätigter Fix und keine Freigabe des Production-Abgleichs. Da kein persistentes Modell geändert wird, kein neues CloudKit-Schema deployen. Ein Debug-Build auf dem iPhone würde die CloudKit-Umgebung ändern; für diesen Befund denselben TestFlight-/Production-Pfad verwenden.


### Nachbesserung der Diagnose vor dem Upload von Build 5

Florians Xcode-Test schlug beim Bytevergleich der Store-Datei fehl. Der vorherige direkte Metadatenzugriff mit Read-only-Option genügt nicht als Absicherung gegen SQLite-Hilfsarbeiten; zusätzlich konnte ein noch abgebauter SwiftData-Testcontainer mit seinem Checkpoint die Prüfung beeinflussen. Die genaue Ursache der Byteänderung ist aus dem Screenshot allein nicht bestimmbar.

Die Diagnose kopiert jetzt den Store sowie vorhandene -wal/-journal-Dateien in ein temporäres Verzeichnis. Nur dessen URL wird an Core Data übergeben; -shm wird dort neu aufgebaut, statt aus dem Original kopiert. Nach dem Lesen wird die Kopie entfernt. Der Originalpfad wird nicht von einer Datenbank-API geöffnet, migriert oder repariert. Bei einem Kopier-/Lesefehler gibt es nur Fehlercodes; keinen direkten Ausweichzugriff auf den Originalstore. Die Kopie dient ausschließlich der Metadatenanalyse nach einem Öffnungsfehler, nicht als transaktionales Backup bei parallel aktiven Schreibern.

Der Bytevergleich bleibt erhalten und prüft alle Dateien des Teststores. Die Fixture wird nun mit Core Data erzeugt, gespeichert und explizit vom Coordinator getrennt, damit SwiftData-Hintergrundabbau den Vergleich nicht verfälscht. Danach prüft ein SwiftData-Container weiterhin den Erhalt des synthetischen Datensatzes. Version 0.13.1 / Build 5 bleibt für diese noch nicht hochgeladene Diagnoserunde bestehen. Xcode-Build und Tests müssen erneut auf dem Mac laufen; t38 bleibt offen.


## Fünf-Modell-Store migrieren: 0.13.2 / 1.0.0 (6)

Der Diagnosebericht aus dem tatsächlich installierten Build 5 auf dem iPhone (iOS 27.2.1) liefert fünf Entitäten, ohne TrainingDayNote, mit Gesamt-Prüfsumme fUgx1q3CFT6KcSI2Oh1JRNA1XDK5EFVY+Gm0LIZ6zNg=. Exercise, ExerciseSetTemplate, Item, SetGroup und TrainingEntry stimmen in ihren Hashes exakt mit V1 überein. Der Store enthält damit das ältere Modell vor Tageskommentaren. Aus diesem Befund allein lässt sich nicht ableiten, welche App-Version zuletzt installiert oder geöffnet wurde; Florians Angabe zu Build 3 bleibt davon unberührt.

TrainuvoSchemaBeforeDayNotes beschreibt diese historische Modellmenge (App-Stände 0.9.x–0.10.x). Es verwendet ausdrücklich die unveränderten fünf Typen aus TrainuvoSchemaV1; die Trainingsdeklarationen wurden gegen Commit 02fcc62076c893b781a5a9829aa8c6a7f532df1c (0.10.2) verglichen. Keine V2-Typen hineinmischen und weder diese Referenz noch V1 nachträglich ändern. Schema.Version 0.9.0 ordnet den historischen Stand vor V1 ein; sie ist nicht die externe App-Version. Die alten unversionierten Stores zeigen als Versionslabel 1.0.0. Für den passenden Migrationsstand sind Modellinhalt und Prüfsummen maßgeblich.

TrainuvoMigrationPlan ordnet BeforeDayNotes, V1 und V2. Die erste Lightweight-Stufe ergänzt ausschließlich TrainingDayNote, zunächst ohne Datensätze; die zweite ist die vorhandene CloudKit-Kompatibilitätsmigration. Bestehende Sechs-Modell-V1-Stores starten an V1, vorhandene V2-Stores behalten ihr Modell. Der Standardpfad bleibt erhalten. Keine manuell gesetzten Store-Metadaten, keine automatisch entfernten oder umbenannten Datenbanken und kein Öffnen eines unbekannten Stores ohne passenden Migrationsstand.

TrainingMigrationTests prüft jetzt drei Ausgangsvarianten: unversioniert mit fünf Modellen, unversioniert mit sechs Modellen und versioniertes V1. Vor der Fünf-Modell-Migration werden alle fünf Hashes und die Gesamt-Prüfsumme gegen den gemeldeten iPhone-Fingerprint geprüft. Die synthetischen Daten umfassen alle drei Übungstypen, UUIDs, Ziele, Reihenfolge, Vorlagen, Gruppen, Gewichte/freie Angaben, Bewertungen und Item. Beim alten Stand wird keine Notiz vorausgesetzt; nach der Migration wird eine neue Tagesnotiz gespeichert und erneut geladen. Vorhandene Notizen der Sechs-Modell-Varianten bleiben erhalten. Löschen des letzten Trainings erhält Übung/Vorlagen. Ein weiterer Test öffnet ein bestehendes V2 mit dem erweiterten Plan.

Das aktuelle V2 und CloudKit-Schema werden nicht geändert; kein erneutes Development-/Production-Deployment nötig. Diagnose zeigt auch die Fünf-Modell-Referenz. Der temporäre Diagnose-Kopierpfad bleibt bestehen.

Nächste Schritte am Mac: main pullen, ⌘ B und ⌘ U. Insbesondere alle Varianten von TrainingMigrationTests müssen bestehen. Danach den getesteten Stand mit v0.13.2 taggen/pushen; extern 1.0.0 (6) kontrollieren, Build 6 auf Verfügbarkeit prüfen und per TestFlight über Build 5 auf dem iPhone installieren. Die App nicht deinstallieren. Zuerst vollständige Übungen/Trainings/Vorlagen/Bewertungen prüfen, dann eine Tagesnotiz und ein Training anlegen, Neustart und Abgleich mit dem iPad testen. Bei erneutem Öffnungsfehler Diagnose kopieren. Kein veröffentlichter Tag wird verschoben.

Prüfstand: Historische Deklarationen, Syntax, Modell-/Migrationsfolge und Versionsangaben statisch geprüft. Kein Xcode/Apple-SDK verfügbar, daher neue Swift-Tests und reales iPhone-Update noch nicht ausgeführt. t38 ist implementiert, aber noch nicht auf dem betroffenen Gerät abgenommen.


## Tagesüberschriften: 0.13.3 / 1.0.0 (7)

ContentView formatiert ausschließlich die Tagesüberschriften der Startseite mit einem wiederverwendeten DateFormatter: de_DE, gregorianischer Kalender, autoupdatingCurrent-Zeitzone, EEEE, dd.MM.yyyy. Beispiel: Mittwoch, 18.11.2026. Auch reine Notiztage verwenden diese Überschrift. Die App-Hilfe beschreibt das Format. Xcode-Build und Sichtprüfung mit langen Wochentagen, großer Schrift, iPhone und iPad ausstehend; statische Format-/Quelltextprüfung durchgeführt.

Florian hat den erfolgreichen iPhone-Start mit TestFlight-Build 6 (0.13.2) bestätigt. Kein bestätigter vollständiger Production-Sync-Test. Nächster Upload vorbereitet als 1.0.0 (7), intern 0.13.3; freien Buildwert prüfen. Vor Upload nach erfolgreichem Test v0.13.3 taggen und mit Include tags pushen.


## Bestätigter iCloud-Test – 24.11.2026

Florian hat nach dem erfolgreichen iPhone-Update mit Build 6 auch den iCloud-Abgleich zwischen iPhone und iPad durchgeführt und als funktionierend bestätigt. Damit ist der zuvor offene Zwei-Geräte-Abgleich laut Nutzer erfolgreich; t05 und der iPhone-Öffnungsbefund t38 sind entsprechend dokumentiert. Die genaue Buildkombination beim Sync-Test sowie einzelne Offline- und Löschszenarien wurden nicht gesondert genannt. Keine darüber hinausgehenden Tests als ausgeführt behaupten. Diese Aktualisierung dokumentiert ausschließlich den Teststand und ändert weder App-Version noch Buildnummer.


## Sichtbarkeit von Übungszielen: 0.14.0 / 1.0.0 (8)

t26 wird nach Florians Präzisierung als Aus-/Einblenden der Startkarten umgesetzt. V3.Exercise ergänzt nur hiddenFromHome: Bool?; nil gilt als false, also sichtbar. Alle anderen persistenten Deklarationen bleiben gleich. Das ausgelieferte V2 aus 0.13.0–0.13.3 steht unverändert in TrainuvoSchemaV2.swift; aktuelles V3 und Typaliase stehen weiterhin in TrainingModels.swift. SchemaMigrationPlan führt BeforeDayNotes → V1 → V2 → V3 mit Lightweight-Stufen. Alle alten Schemata unverändert lassen.

Exercise.setHiddenFromHome speichert ausschließlich das Sichtbarkeitsfeld mit save/rollback. ContentView filtert nur die Karten über displayedExercises. @Query lädt weiterhin alle Übungen, Tagesübersicht und Exporte verwenden alle Einträge. Sortierung, Ziele, Vorlagen und Beziehungen bleiben erhalten. Das Detailmenü bietet Auf Startseite ausblenden/einblenden; nach erfolgreichem Save wird die Detailansicht geschlossen. Fehler bleiben sichtbar. Das Stift-Menü bietet einen lokalen @State-Schalter Ausgeblendete Übungen anzeigen, der bei einem neuen App-Start aus ist; bei vollständig verborgenen Karten gibt es einen Hinweis und das Stift-Menü bleibt erreichbar. Das persistente Flag selbst wird durch CloudKit mit synchronisiert. Die separate destruktive Aktion Übung und Trainings löschen bleibt ausdrücklich getrennt.

ExerciseVisibilityTests legt für alle drei Typen synthetische Daten dateibasiert an, blendet aus, öffnet neu und prüft Ziel, Reihenfolge, IDs, Vorlagen, Gruppen, Bewertung/Trainingszuordnung, Tagesnotiz, Tagesübersicht und Export. Danach wieder einblenden und erneut öffnen. TrainingMigrationTests migriert die drei historischen Ausgangsvarianten nach V3 (sichtbar als Default) und öffnet einen echten V2-Store mit V2-Typen im erweiterten Plan. StoreDiagnosticsTests nutzt das aktuelle V3; Diagnose referenziert alle historischen Stände und V3.

Am Mac: main pullen, ⌘ B und ⌘ U. In einer bestehenden Installation eine Übung ausblenden, Verlauf/Tagesübersicht/Export prüfen, Neustart und Wiedereinblenden testen. Alle Karten ausblenden und über Stift wiederfinden; iPhone/iPad-Abgleich des Flags prüfen. Der bestehende Store wird migriert, keine App-Deinstallation.

**Vor TestFlight erneut das CloudKit-Schema aktualisieren:** In Signing & Capabilities unverändert den bisherigen Container verwenden. Debug-Startargument -initializeCloudKitSchema einmal aktivieren, ⌘ R, Meldung Development schema initialized prüfen, Argument entfernen. CloudKit Console → iCloud.com.vogtapps.Trainuvo → Development → Schema → CD_Exercise: neues Feld CD_hiddenFromHome prüfen. Nach Tests Deploy Schema Changes… nach Production. Erst danach getesteten Commit mit v0.14.0 taggen, Include tags pushen und 1.0.0 (8) archivieren/hochladen. Freie Buildnummer prüfen. Alte TestFlight-Builds verwenden V2 und zeigen weiterhin alle Karten, weil sie das Flag nicht kennen; den Sichtbarkeitsabgleich mit zwei aktuellen Builds prüfen.

Prüfstand: Syntax, Versionierung, eingefrorenes V2 und Änderungen am Modell/Filter statisch geprüft. Kein Xcode/Apple-SDK vorhanden; neue Swift-Tests, reale Migration, UI und CloudKit-Deployment noch ausstehend.


## Löschabfrage mit Ausblendalternative – 0.14.1 / 1.0.0 (9)

ExerciseDetailView.DetailAlert.deleteExercise bietet Abbrechen, Nur auf Startseite ausblenden und die destruktive Aktion Übung und alle Trainings löschen. Der Nachrichtentext unterscheidet die Folgen. changeHomeVisibility nimmt jetzt den gewünschten Bool-Zustand ausdrücklich entgegen: Das direkte Sichtbarkeitsmenü übergibt die Umkehr des aktuellen Werts, die Löschabfrage immer true. Dadurch kann die Alternative eine bereits ausgeblendete Übung nicht versehentlich wieder einblenden. Speichern/Rollback/Fehlermeldung und Schließen nach Erfolg verwenden denselben vorhandenen Pfad. Die eigentliche Cascade-Löschung bleibt ausdrücklich der roten Löschaktion zugeordnet; Abbrechen mutiert keine Daten.

Prüfung am Mac: Pull, ⌘ B, dann eine entbehrliche Testübung mit Trainings verwenden. Alle drei Auswahlwege prüfen: Abbrechen erhält Daten und Sichtbarkeit, Ausblenden erhält Trainings/Vorlagen und verbirgt die Karte, endgültiges Löschen entfernt Übung und Trainings nach der Wahl. Eine bereits ausgeblendete Übung über den Stift sichtbar machen und dieselbe Alternative prüfen; sie bleibt ausgeblendet. Diese UI-Prüfung ist hier ohne Xcode nicht ausgeführt. Vorhandene ExerciseVisibilityTests für den Datenerhalt bleiben gültig. Modelle und Schema sind gegenüber 0.14.0 unverändert; vor der ersten Veröffentlichung dieser Funktion muss dessen V3-Feld dennoch in Development initialisiert und nach Production übertragen werden.

Nächster Upload vorbereitet: intern 0.14.1 / extern 1.0.0 (9); freie Buildnummer prüfen. Nach erfolgreichen Prüfungen v0.14.1 taggen und mit Include tags pushen.


## Sichtbarkeitsschalter – 0.14.2 / 1.0.0 (10)

Auf Wunsch von Florian steht Toggle „Einblenden auf Startseite“ unmittelbar über Training erfassen in ExerciseDetailView. Binding liest !isHiddenFromHome und speichert die Umkehr des Schalterwertes über den vorhandenen Save-/Rollback-Pfad. changeHomeVisibility schließt die Ansicht standardmäßig nicht mehr. Ausschließlich die Alternative Nur auf Startseite ausblenden in der Löschabfrage setzt closeAfterSave: true und hidden: true. Der vorige Sichtbarkeits-Menübutton und das redundante Statuslabel entfallen. Das Stift-Menü zum Anzeigen ausgeblendeter Karten und die Löschabfrage bleiben erhalten.

Am Mac Pull → ⌘ B → ⌘ R. Schalter aus/ein testen, geöffnet bleibende Ansicht prüfen; danach zur Startseite zurück, Karte und unveränderte Trainings prüfen. Alle Karten ausblenden und über das Stift-Menü wiederfinden. Die bestehende iCloud-Synchronisierung des optionalen Felds und das V3-Schema bleiben gleich. Kein zusätzliches CloudKit-Schema gegenüber 0.14.0; dessen erstmaliges Development-/Production-Deployment bleibt erforderlich. Danach getesteten Stand mit v0.14.2 taggen/pushen und freie Buildnummer 10 prüfen, bevor 1.0.0 (10) hochgeladen wird.

Statisch geprüft; kein Xcode/Apple-SDK verfügbar, daher UI-/Gerätetest ausstehend.


## Kennzeichnung ausgeblendeter Karten – 0.14.3 / 1.0.0 (8)

GoalCard zeigt bei exercise.isHiddenFromHome unter dem Namen eine kompakte Plakette mit Label Ausgeblendet und eye.slash sowie VoiceOver Auf Startseite ausgeblendet. Der sekundäre Text/Symbolstil und dezente Kapselhintergrund unterscheiden die Karten ohne ihre Trainingswerte abzublenden. Die Plakette liegt im bestehenden Titelbereich mit minHeight 44; reguläre Karten verändern sich nicht. Sichtbarkeit basiert auf dem gespeicherten Flag, nicht nur auf dem globalen Ansichtsschalter. Nach dauerhaftem Einblenden entfällt die Markierung.

Prüfung auf dem Mac: Pull → ⌘ B → ⌘ R. Eine sichtbare und eine verborgene Übung vorhalten, im Stift-Menü ausgeblendete Übungen anzeigen: Nur die verborgene Karte muss die Plakette tragen. Wieder einblenden und Verschwinden der Plakette prüfen. Hell/Dunkel, lange Namen, große Schrift und VoiceOver prüfen. Statische Syntax-/Versionsprüfung durchgeführt; keine Xcode-/Geräteprüfung hier möglich.

Version 0.14.3 / 1.0.0 (8) vorbereitet; Buildnummer vor Upload auf Verfügbarkeit prüfen. Nach Tests v0.14.3 taggen/pushen. Keine neue Modelländerung; erstmaliges V3-CloudKit-Deployment aus 0.14.0 bleibt Voraussetzung, falls noch nicht erfolgt.


## Verbindliche Buildzuordnung – 24.11.2026

Florian bestätigt Build 7 als letzte Veröffentlichung. Für die gesamte aktuelle Testrunde einschließlich der Zwischenstände 0.14.0–0.14.3 wird Build 8 verwendet; aktuell intern 0.14.3 / extern 1.0.0 (8). Frühere Erwähnungen der Builds 9–11 waren vorläufige Planungen, keine Upload-Bestätigungen, und sind überholt. Alle drei Targets sind auf Build 8 gesetzt. Interne Zwischenstände ohne Upload erfordern keine weitere Buildnummer. Keine Änderung an App-Code, Datenmodell oder Schema durch diese Korrektur.


## Kopierbestätigung – 0.14.4

TrainingExportView kopiert weiterhin preview unverändert nach UIPasteboard.general.string. Die Bestätigung lautet „Text in die Zwischenablage kopiert“, ohne Nennung einer Ziel-App. Intern 0.14.4, nächster Upload extern 1.0.0 (9) geplant; Verfügbarkeit vor Upload prüfen. Keine Änderung an Datenmodell, Exportformat oder Schema. Am Mac main pullen, ⌘ B, Export mit Trainings öffnen, Text kopieren antippen, Bestätigung prüfen und in eine beliebige Notiz einfügen. Xcode-/Geräteprüfung hier nicht möglich.


## Versionsanzeige in der Hilfe – 0.14.5

HelpView in ContentView.swift zeigt interne Version und Buildnummer aus dem installierten Bundle. Cashuvos Hilfe erfüllt die gemeinsame Regel bereits. Am Mac main pullen, ⌘ B und ⌘ R; ? öffnen und 0.14.5 (Build 9) mit den Target-Einstellungen vergleichen. Kein Xcode-/Gerätetest in dieser Umgebung möglich. Build 9 bleibt für den nächsten Upload geplant; keine Modell-/Schemaänderung.


## Expliziter Versionsschlüssel – 0.15.0

Auf Florians Wunsch interne Version 0.15.0, Build unverändert 9 (extern 1.0.0, geplanter nächster Upload). Die vorherige INFOPLIST_KEY_TrainuvoInternalVersion-Einstellung durch TRAINUVO_INTERNAL_VERSION ersetzen und den benutzerdefinierten Schlüssel ausdrücklich in Trainuvo-Info.plist eintragen. Dadurch hängt die Aufnahme des Schlüssels nicht allein vom generierten Info.plist ab. HelpView zeigt Interne Version und Build als separate LabeledContent-Zeilen. Auf dem Mac pullen, ⌘ B/⌘ R und ? prüfen: 0.15.0 und 9. Keine Modell-/CloudKit-Änderung. Nur statische Prüfung hier; finales Bundle und Anzeige in Xcode prüfen.


## Versionszeile analog Cashuvo – 0.15.1

HelpView verwendet einen eigenen Section-Block mit Text in footnote/secondary. Der folgende Abschnitt Trainuvo enthält ausschließlich die Nutzungshinweise. Alle drei Versionswerte stammen aus Bundle.main. Auf dem Mac main pullen, ⌘ R, ? öffnen: eigene Versionszeile oberhalb der abgesetzten Hilfetexte prüfen. Intern 0.15.1, nächster Upload extern 1.0.0 (9) geplant. Kein Xcode-/Gerätetest in dieser Umgebung möglich.


## Satz-Checkboxen t40 – 0.15.0 / 1.0.0 (9) geplant

Florian legt für diese gesamte Runde intern 0.15.0 fest; Zwischenstand 0.15.1 ist abgelöst, kein neues Tag durch den Assistenten. Die Hilfe bleibt eine eigene dezente Versionszeile analog Cashuvo.

TrainuvoSchemaV3.swift friert das bisherige V3 unverändert ein. TrainingModels.swift enthält aktuelles V4, ergänzt ausschließlich optionales SetGroup.completedSetsRawValue und den berechneten Zugriff completedSets. Migrationsfolge BeforeDayNotes → V1 → V2 → V3 → V4 mit Lightweight-Stufen, bisheriger default.store bleibt erhalten. nil bedeutet keine Häkchen. Satznummern ab 1 werden sortiert kommasepariert gespeichert, ungültige Nummern beim Zugriff verworfen. Alle bisherigen Modelle unverändert lassen. App, Schema-Initialisierung, Diagnose und aktuelle Test-Fixtures verwenden V4; Diagnose behält V3-Referenz zusätzlich.

TrainingSetProgress erkennt eindeutiges NxM mit x/×, Leerzeichen und positivem Wiederholungswert; Satzanzahl 1–100 schützt vor unbeschränkter UI-Erzeugung. Andere/Freitext ohne eindeutige Vorgabe zeigt keine Checkboxen. TrainingEditor hält Häkchen im lokalen SetGroupDraft, lädt sie ausschließlich bei Bearbeitung des konkreten Eintrags und schreibt sie erst über den bestehenden Save-/Rollback-Pfad. Neue Trainings aus Vorlagen oder vorherigem Training kopieren keine Häkchen. Abbrechen speichert nicht. Bei Änderung der Vorgabe nur weiterhin vorhandene Satznummern behalten. SetCompletionButtons zeigt bis fünf Kästchen in derselben Zeile; weitere horizontal scrollbar, mit VoiceOver-Satznummer/Status. Satzvorgabe, Gewichte und Zielfortschritt unverändert. JSON ergänzt das optionale Feld completedSets mit Satznummern ab 1 (additiv, schemaVersion weiterhin 2), Text und Excel unverändert.

Neue TrainingSetProgressTests prüfen Parsergrenzen, dateibasierte V3→V4-Migration für beide Satztypen, erhaltene IDs/Beziehungen/Sichtbarkeit/Werte/Bewertung, initial leere Häkchen, Speichern/Wiederöffnen, einzelne Abwahl, Satzreduktion und JSON. Bestehende Migrations-/Sichtbarkeits-/Diagnosetests öffnen V4. Kein Xcode/Apple-SDK in dieser Umgebung; Tests hier nicht ausgeführt.

Am Mac: main pullen, ⌘ B und ⌘ U. Mit bestehender Installation für Krafttraining und Satzübung 1×5/3×5/5×5/5×3 prüfen. Vier Satzgruppen auf iPhone-15-Hochformat mit offener/geschlossener Tastatur und großer Schrift prüfen; Abhaken/Abwählen, Speichern, Abbrechen, erneut öffnen, neue Trainings ohne geerbte Häkchen sowie Freitext/Andere testen. JSON prüfen.

Vor TestFlight zwingend neues CloudKit-Schema: Scheme Run Debug -initializeCloudKitSchema aktivieren, auf iCloud-angemeldetem Simulator starten, Development schema initialized bestätigen, Argument wieder deaktivieren. CloudKit Console iCloud.com.vogtapps.Trainuvo → Development → Schema → CD_SetGroup → CD_completedSetsRawValue prüfen. Deploy Schema Changes… → Production; dort Feld kontrollieren. Erst danach getesteten Commit mit v0.15.0 taggen/pushen, freien Buildwert 9 prüfen und 1.0.0 (9) hochladen. Auf beiden Geräten denselben aktuellen TestFlight-Build verwenden und Häkchen nach Speicherung/iCloud-Abgleich prüfen. Keine Deinstallation und kein Reset.


## Abnahme der Checkboxen – 25.11.2026

Florian bestätigt für die aktuelle Runde intern 0.15.0 / extern 1.0.0 (9) zunächst den erfolgreichen iPhone-Test und anschließend den erfolgreichen iPad-/Abgleichstest. t40 ist damit abgenommen. Die Schema-Initialisierung war nach Anmeldung des Simulators bei iCloud erfolgreich; der vorherige Initialisierungsfehler ist damit nicht als nachgewiesener Migrationsfehler zu behandeln. Einzelne automatisierte Testergebnisse, Offline-/Konfliktfälle und Bedienungshilfen wurden nicht separat bestätigt. Keine öffentliche App-Store-Verfügbarkeit ableiten. Reine Dokumentation, App-Version und Build unverändert.


## Kompaktere Oberfläche – 0.16.0 / 1.0.0 (10) geplant

Trainingsüberschrift in ContentView mit Divider oben/unten. GoalCard prüft UIUserInterfaceIdiom.phone: auf iPhone nur Titel/Prozent/Status und Fortschrittsbalken mit reduzierter vertikaler Polsterung; Plus bleibt ein separater Button über der NavigationLink-Karte. iPad zeigt die bisherigen Details. ExerciseDetailView ergänzt Erreicht bzw. Zuletzt für den aktuellen Übungstyp und zeigt das Datum der latestEntryForCurrentType beim Aktuellen Fortschritt. Ohne Prozentwert eigener Datumswert. Datenabfragen, Sortierung und Zielformel bleiben unverändert.

TrainingEditor ordnet den bestehenden DatePicker nach der Satzgruppen-/Bewertungs-Section an. Derselbe lokale Datumsentwurf, Validierung, Save-/Rollback und Fokus bleiben erhalten. TrainingEffortSelector behält die fünf Werte/Farben/VoiceOver-Labels und Auswahlrahmen, zeigt aber nur Symbole unter „Bewertung (sehr schwer ... sehr leicht)“. Große Bedienungshilfen-Schrift behält die Zweispalten-Variante.

Abnahme am Mac: main pullen, ⌘ B/⌘ R. iPhone 15 mit vier Zielkarten, langen Namen, fehlendem Ziel/Training, >100 %, Satzübung/Andere und Ausgeblendet-Plakette prüfen; Plus und Kartenlink getrennt testen. iPad bisherige Details vergleichen. Übungsansicht Ziel/Erreicht/Prozent/Datum prüfen. Neues und altes Training: vier Gruppen mit Checkboxen, Tastatur, Bewertung aller fünf Werte/Entfernen, Datumsnachtrag und Speichern prüfen. Auch Hell/Dunkel, große Schrift und VoiceOver testen. Hier kein Xcode/Apple-SDK; nur statische Syntax-/Konfigurationsprüfung. Keine neuen Tests für reine Darstellungsänderungen. Modell V4/Store/Migration unverändert, daher kein neues Development-/Production-Schema nötig.

Florian bestätigt Build 9 als bereits veröffentlichten TestFlight-Stand (intern 0.15.0). Nächster Upload ausdrücklich intern 0.16.0 / extern 1.0.0 (10), Verfügbarkeit vor Upload prüfen. Öffentlich im App Store weiterhin nicht bestätigt. Nach erfolgreicher Abnahme v0.16.0 taggen und mit Include tags pushen; veröffentlichte Tags erhalten.


### Kräftigere Trennlinien vor Abnahme von 0.16.0

Die beiden Divider an der Trainingsüberschrift durch dekorative Rechtecke mit 3 pt Höhe und Color.secondary.opacity(0.6) ersetzen. Hell-/Dunkeldarstellung folgt der Systemfarbe, Linien für VoiceOver verborgen. Version bleibt innerhalb der aktuellen Testrunde 0.16.0 / 1.0.0 (10) geplant. Am Mac pullen, ⌘ R und Startseite mit Trainings in Hell/Dunkel prüfen. Kein Xcode-/Gerätetest hier möglich; Änderung statisch geprüft.


### Identische Linien für Übungen – 0.16.0

Die vorhandene HStack aus Übungen und Stift-Menü in einen VStack mit denselben dekorativen Rechtecken wie Trainings setzen: 3 pt, Color.secondary.opacity(0.6), Abstand 8 pt, äußere vertikale Polsterung 4 pt. Aktionen unverändert, Überschrift für VoiceOver als Header. Pull/⌘ R: beide Überschriften in Hell/Dunkel vergleichen und Stift-Menü prüfen. Quelltext statisch geprüft, Xcode-/Sichtprüfung ausstehend. Intern 0.16.0, nächster Upload extern 1.0.0 (10) geplant.


### Zentrierter Startseitentitel – 0.16.0

ContentView setzt direkt nach navigationTitle("Trainuvo") navigationBarTitleDisplayMode(.inline). Dadurch erscheint der Titel oben zentriert in der nativen Navigationsleiste statt als großer linksbündiger Titel. Toolbar-Aktionen bleiben erhalten. Statisch geprüft; am Mac main pullen, ⌘ R und Startseite auf iPhone/iPad prüfen. Kein Xcode-/Sichttest hier ausgeführt. Intern 0.16.0, extern 1.0.0 (10) weiterhin geplant.


### Finale Titel-/Linienkorrektur innerhalb 0.16.0

Florian wünscht die bisherige große Schrift, nur zentriert. ContentView verwendet deshalb einen eigenen Text Trainuvo mit largeTitle.bold, voller Inhaltsbreite und zentrierter Ausrichtung oberhalb von Übungen. Native navigationTitle ist leer/inline, Toolbar-Aktionen bleiben oben rechts; große Schrift und VoiceOver-Header sind erhalten. Die nachträglich eingebauten Linien und die äußere Polsterung am Übungsheader entfernt; die originale HStack mit Stift-Menü bleibt. Die zwei 3-pt-Linien bei Trainings bleiben unverändert. Frühere Zwischenstände zur Inline-Versionsanzeige des Startseitentitels bzw. zu Übungslinien sind hiermit abgelöst. Pull/⌘ R und großen zentrierten Titel, Übungsheader ohne Linien und Trainingsheader mit Linien auf iPhone/iPad prüfen. Statisch geprüft; Xcode-/Sichtprüfung ausstehend. Version unverändert intern 0.16.0 / extern 1.0.0 (10) geplant.


### Zentrierte Trainingsüberschrift – 0.16.0

Text Trainings erhält volle Inhaltsbreite und zentrierte mehrzeilige Ausrichtung; die beiden 3-pt-Linien bleiben unverändert. Auf main pullen und mit ⌘ R die Startseite prüfen. Quelltext statisch geprüft; Xcode-/Sichtprüfung ausstehend. Intern 0.16.0 / extern 1.0.0 (10) weiterhin geplant.


### Datum bei Erreicht – 0.16.0

ExerciseDetailView zeigt das Datum von latestEntryForCurrentType direkt unter workingGroup.valueText bei Erreicht, auch für Satzübungen ohne Prozentfortschritt. Aktueller Fortschritt enthält ausschließlich den Prozentwert. Andere bzw. Einträge ohne Arbeitsgruppe behalten den separaten Wert Letztes Training. Frühere Platzierung des Datums beim Fortschritt abgelöst. Am Mac pullen, ⌘ R und Krafttraining/Satzübung/Andere prüfen. Quelltext statisch geprüft; Xcode-/Sichttest ausstehend. Intern 0.16.0 / extern 1.0.0 (10) geplant bleiben gleich.
