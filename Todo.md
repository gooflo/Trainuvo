# Trainuvo – Aufgaben und Testbefunde

Neue und zurückgestellte Einträge stehen unter **Open**. Umgesetzte Einträge stehen unter **Done** mit der internen Trainuvo-Version. Ausstehende Prüfungen stehen beim jeweiligen Eintrag.

## Open

### t45 – Öffentliche App-Store-Veröffentlichung (Prio 3)

- Erste öffentliche Veröffentlichung von Trainuvo vorbereiten und gemeinsam durchführen; separat von TestFlight.
- App-Store-Texte, Screenshots, Support-/Datenschutzangaben, App-Informationen und erforderliche Compliance-Angaben vervollständigen. Händlerstatus und vorgesehene Länder einschließlich Deutschland vor Freigabe prüfen.
- Getesteten Build auswählen, App Review und Veröffentlichung begleiten; tatsächliche öffentliche Verfügbarkeit anschließend kontrollieren.
- Öffentlichen Versions-/Buildstand mit interner Version, Tag/Commit und Datum in AppStoreRelease.md dokumentieren. Bisher keine öffentliche Veröffentlichung bestätigt.
- Dieser Eintrag ist eine Planungsaufgabe, noch kein Auftrag zum Einreichen oder Veröffentlichen.

### t24 – Zweisprachigkeit Deutsch und Englisch (Prio 9, zurückgestellt)

- Auf Wunsch von Florian zurückgestellt. App-Oberfläche, Hilfe und Fehlermeldungen später auf Deutsch und Englisch bereitstellen.

## Done

### t47 – Externe App-Version auf zwei Komponenten umstellen (0.17.0; Prio 3)

- Auf ausdrücklichen Auftrag extern 1.0 (12), intern unverändert 0.17.0. MARKETING_VERSION und CURRENT_PROJECT_VERSION in allen drei Targets angepasst.
- Hilfe liest die Bundlewerte und zeigt automatisch „Version 1.0 (12), v0.17.0“. Regeln, Dokumentation und Ankündigungsbeispiel nachgezogen.
- Florian bestätigt den Upload von Build 11 unter 1.0.0; dieser Build und vorhandene Tags bleiben erhalten.
- Erledigt: Florian bestätigt am 28.11.2026 den erfolgreichen Upload von 1.0 (12) und schließt die Formatumstellung ab. Remote-Tag v0.17.0-build12 geprüft: zeigt auf ed96d47397ecd985ced9c3fd7143897df9605d16. Testgruppen-Verfügbarkeit und zusätzlicher TestFlight-Gerätetest damit nicht separat bestätigt.

### t46 – Separater Zielgewichtsrechner (0.17.0)

- Einstellungen → Zielgewichte berechnen: Körpergewicht in kg eingeben; Kniebeuge 100 %, Press 40 %, Kreuzheben 130 %, Bankdrücken 75 % direkt anzeigen.
- Dezimalkomma/-punkt, positive endliche Eingaben; Anzeige mit maximal zwei Nachkommastellen ohne Rundung auf Hantelscheiben. Körpergewicht als lokale Geräteeinstellung speichern und nach erneutem Öffnen bzw. App-Neustart vorbelegen; keine iCloud-Synchronisierung.
- Übungen und Zielgewichte ausschließlich manuell eintragen; keinerlei automatische Änderung bestehender Daten.
- Abgestimmten Text zur Herkunft der Werte von Work it Training Hamburg und persönliche Empfehlung durch Florian, Entwickler von Trainuvo, unter den Ergebnissen anzeigen. Offizieller Link https://workittraining.de/.
- Hilfe/Dokumentation sowie Tests für vier Faktoren, Dezimaleingaben und ungültige Werte ergänzt. Statische Prüfungen durchgeführt; Xcode-Build/⌘ U, Tastatur/Fertig, Ergebnisdarstellung und Link auf iPhone/iPad ausstehend.
- Build 11 (extern 1.0.0, intern 0.17.0) laut Florian hochgeladen; nächster Upload nach Formatumstellung extern 1.0 (12), intern 0.17.0. Kein neues Datenmodell/CloudKit-Schema. Nachbesserung: lokale Körpergewichtsspeicherung ergänzt; Wiederöffnen, App-Neustart und Löschen der Eingabe auf dem Gerät prüfen.

### t41 – Bewertung kompakter beschriften (0.16.0)

- Überschrift „Bewertung (sehr schwer ... sehr leicht)“, darunter ausschließlich --, -, o, +, ++ ohne Einzelbeschriftungen. Farben, Auswahlrahmen, Entfernen und VoiceOver-Bedeutung erhalten.
- Statisch geprüft; Xcode-Build und Sichtprüfung für alle Übungstypen, Hell/Dunkel und große Schrift ausstehend.

### t42 – Überschrift Trainings auf der Startseite stärker absetzen (0.16.0)

- Horizontale Trennlinien oberhalb und unterhalb von Trainings mit Abstand und Überschrift für VoiceOver.
- Statisch geprüft; Xcode-Build und Sichtprüfung mit/ohne Trainings ausstehend.

### t43 – Trainingsdatum unter die Satzgruppen verschieben (0.16.0)

- Datum in eigener Section unter Satzgruppen/Trainingseinheiten und Bewertung. Vorbelegung, Nachtragen, Bearbeiten und Eingabefokus erhalten.
- Statisch geprüft; Xcode-/Gerätetest mit Tastatur für alle drei Übungstypen ausstehend.

### t44 – Übungskarten auf dem iPhone kompakter darstellen (0.16.0)

- iPhone zeigt Namen, Prozentwert und Plus mit schmalem Fortschrittsbalken; Detailangaben entfallen. Ohne numerischen Fortschritt kompakte Namenszeile mit Plus. Ausgeblendet-Plakette und Kennzeichnung erreichter Ziele bleiben.
- iPad behält bisherige Karteninformationen. Ziel, erreichter Wert und Datum in der Übungsansicht; Datum beim aktuellen Fortschritt, ohne Prozentfortschritt als Letztes Training.
- Statisch geprüft; iPhone-15-/iPad-Sichtprüfung mit langen Namen, großer Schrift, allen Übungstypen und ein-/ausgeblendeten Karten ausstehend.

### t40 – Einzelne Sätze während des Trainings abhaken (0.15.0)

- In Krafttraining und Satzübungen je Satz eine Checkbox direkt in der Erfassungszeile, unabhängig von den Wiederholungen: 1×5 → eine, 3×5 → drei, 5×5/5×3 → fünf. Abhaken und wieder abwählen; ab sechs Kästchen horizontal scrollen. Keine Kästchen für Andere oder nicht eindeutig auswertbaren Freitext.
- Häkchen mit dem Training speichern und beim erneuten Bearbeiten übernehmen; neue Trainings aus Vorlagen oder letztem Training starten leer. Abbrechen verwirft Änderungen. Entfernte Satznummern beim Verkleinern der Vorgabe verwerfen. Gewicht, Satzvorgabe und Fortschrittsberechnung bleiben unverändert.
- Optionales SetGroup.completedSetsRawValue in V4; V3 unverändert eingefroren, Lightweight V3→V4. Alte Trainings starten ohne Häkchen. Abhakstatus per iCloud synchronisieren und zusätzlich als completedSets (Satznummern ab 1) in JSON exportieren; Text/Excel unverändert.
- Parser-, V3-Migrations-, Persistenz-/Wiederöffnungs- und JSON-Tests für Krafttraining/Satzübung ergänzt; vorhandene Migrationstests auf V4 erweitert. Swift-Syntax statisch geprüft.
- Abnahme laut Florian am 25.11.2026: iPhone-Test erfolgreich, anschließend auch iPad-/Abgleichstest erfolgreich bestätigt. t40 damit für die aktuelle Testrunde abgenommen. Einzelne automatisierte Testergebnisse sowie Sonderprüfungen mit großer Schrift, Offline-Nachholen und Löschkonflikten wurden nicht separat protokolliert.
- Schema-Initialisierung funktionierte nach Anmeldung des Simulators bei iCloud laut Florian. Veröffentlichungsrunde intern 0.15.0 / extern 1.0.0 (9); Production-Deployment und Verteilung wurden begleitet. Keine öffentliche App-Store-Veröffentlichung damit behauptet.

### t26 – Übungsziele ausblenden und Trainings erhalten (0.14.0; ergänzt bis 0.14.3)

- Auf Wunsch von Florian als Sichtbarkeitseinstellung statt Löschen umsetzen. Seit 0.14.2 direkt über Training erfassen: Schalter „Einblenden auf Startseite“. An zeigt die Karte, Aus verbirgt sie; Detailansicht bleibt geöffnet.
- Seit 0.14.1 auch in der Löschabfrage: Nur auf Startseite ausblenden, Übung und alle Trainings löschen oder Abbrechen. Ausblenden setzt immer true, auch bei bereits versteckter Übung. Bedienprüfung aller drei Wege ausstehend.
- Seit 0.14.3 zusätzlich angezeigte ausgeblendete Karten mit eye.slash und „Ausgeblendet“ kennzeichnen; sichtbare Karten ohne Plakette. Sichtprüfung mit gemischten Karten ausstehend.
- Im Stift-Menü „Ausgeblendete Übungen anzeigen“ anbieten. Auch wenn alle Karten verborgen sind, bleibt Wiederherstellen erreichbar.
- Übung, Ziel, Reihenfolge, Vorlagen, Trainings und Tagesnotizen bleiben erhalten; Verlauf, Tagesübersicht und Exporte werden nicht gefiltert. Einstellung pro Übung per iCloud synchronisieren.
- Optionales Feld hiddenFromHome in neuem V3 mit V2→V3-Lightweight-Migration. Bestehende Datensätze sind sichtbar.
- Tests für dauerhafte Sichtbarkeit, Daten-/ID-Erhalt und Exporte sowie Migration aus alten Modellmengen ergänzt.
- Statische Prüfungen durchgeführt. **Ausstehend:** Xcode-Build/⌘ U, Update auf Bestandsinstallation, Aus-/Einblenden (auch alle Karten), Verlauf/Export und Abgleich auf iPhone/iPad. Development-Schema initialisieren, Feld prüfen und nach Production deployen, bevor Build 8 über TestFlight verteilt wird.

### t39 – Wochentag und kurzes Datum in Trainingsüberschriften (0.13.3)

- Auf der Startseite beispielsweise „Mittwoch, 18.11.2026“ anzeigen, auch bei Tagen mit ausschließlich Kommentar. Ausgeschriebener deutscher Wochentag zuerst; Tag/Monat zweistellig, Jahr vierstellig, lokale Zeitzone.
- Hilfe aktualisiert. Statisch geprüft; Xcode-Build und Sichtprüfung auf iPhone/iPad, mit langen Wochentagen und großer Schrift ausstehend.

### t38 – Älteren Fünf-Modell-Store im Migrationsplan berücksichtigen (0.13.2)

- iPhone unter iOS 27.2.1: Build 4/5 konnte den vorhandenen Store wegen 134504 nicht öffnen. iPad-Update mit bestehenden Daten funktioniert laut Florian.
- Diagnose aus 1.0.0 (5) zeigt exakt die fünf alten Entitäten Exercise, ExerciseSetTemplate, Item, SetGroup, TrainingEntry; TrainingDayNote fehlt. Alle fünf Hashes stimmen mit den eingefrorenen alten Entitäten überein. Gesamt-Prüfsumme: fUgx1q3CFT6KcSI2Oh1JRNA1XDK5EFVY+Gm0LIZ6zNg=.
- Historisches Schema vor Tageskommentaren ergänzen; Lightweight-Folge BeforeDayNotes → V1 → V2. V1/V2 nicht verändern, Store/IDs erhalten. Kein neues CloudKit-Schema.
- Neue dateibasierte Tests bilden den exakten Fünf-Modell-Fingerprint nach und prüfen Migration, Daten-/Beziehungserhalt, neue Tagesnotiz und Wiederöffnen. Sechs-Modell-V1-Tests sowie aktualisiertes V2 weiter prüfen.
- Diagnose und temporäre Kopie aus 0.13.1 bleiben verfügbar. Die nachgebesserten Diagnosetests wurden von Florian als erfolgreich bestätigt; neue Migrationstests sind davon nicht abgedeckt.
- Florian hat erfolgreichen Build/Deployment und iPhone-Start mit Build 6 bestätigt. Am 24.11.2026 wurde auch der iCloud-Abgleich zwischen iPhone und iPad als funktionierend bestätigt. Einzelne Offline-/Löschtests und neue Migrationstest-Ergebnisse wurden nicht separat protokolliert.

### t05 – Trainingsdaten per iCloud synchronisieren (0.13.0)

- Private CloudKit-Datenbank für den Apple-Account aktivieren; Übungen, Ziele, Sortierung, Vorlagen, Trainings, Satzgruppen, Bewertungen und Tageskommentare abgleichen. Lokal und offline weiterarbeiten.
- Ausgeliefertes Modell als V1 sichern, CloudKit-kompatibles V2 und leichtgewichtigen Migrationsplan ergänzen. Optionalen Beziehungen sichere Listen-Zugriffe geben; bestehenden Store ohne Reset weiterverwenden.
- Accountstatus in Einstellungen, Hinweis zu zeitversetztem Abgleich und geräteübergreifenden Löschungen ergänzen.
- Development-Schema nur im Debug-Build mit getrenntem temporären Store initialisieren. Entitlements und Hintergrundbenachrichtigungen vorbereiten.
- Regressionstests für echte dateibasierte unversionierte und versionierte V1-Stores, Daten-/ID-Erhalt, erneutes Öffnen und Löschen des letzten Trainings ergänzt.
- Stand 24.11.2026 laut Florian: Xcode-/Unit-Tests erfolgreich, Signierung/Container eingerichtet, Development-Schema initialisiert und nach Production deployed. Bestandsdaten auf dem Simulator und iPad sichtbar. iPhone-Öffnungsfehler t38 mit Build 6 behoben und von Florian bestätigt. Der iCloud-Abgleich zwischen iPhone und iPad wurde am 24.11.2026 als funktionierend bestätigt. Offline-Nachholen und geräteübergreifende Löschungen wurden nicht separat als Einzelszenarien protokolliert.

### t37 – Dateinamen analog Cashuvo anpassen (0.12.0)

- Vor TXT-/Excel-/JSON-Teilen editierbaren Namen mit fester Endung anbieten. Standard Trainuvo_Export.<Endung>.
- Validierung, Abbrechen und System-Teilen analog Cashuvo. Text kopieren unverändert.
- Tests ergänzt, Xcode-Build, Swift-Tests und Teilen/Speichern auf iPhone/iPad ausstehend.

### t36 – Überschrift Trainings verwenden (0.11.2)

- Trainingstage auf der Startseite und in der Hilfe durch Trainings ersetzen.
- Statisch geprüft, Xcode-Build und Sichtprüfung ausstehend.

### t35 – Startseitenüberschrift kürzen (0.11.1)

- Übungen statt Deine Übungen anzeigen; Verweise in Hilfe und Dokumentation anpassen.
- Statisch geprüft, Xcode-Build und Sichtprüfung ausstehend.

### t27 – Kommentar für den gesamten Trainingstag (0.11.0)

- Unabhängige Tagesnotiz für alle Übungen, über Notizsymbol am Datum erfassen/bearbeiten, unter Übungen anzeigen und bestätigt löschen.
- Notizen bleiben beim Löschen von Trainings/Übungen erhalten. Notiztage ohne Trainings bleiben sichtbar und exportierbar.
- OneNote/TXT, JSON und Excel enthalten Tageskommentare; Alles löschen entfernt sie ebenfalls.
- Xcode-Build, Swift-Tests, Store-Update über 0.10.2 und Gerätetest einschließlich Neustart und Löschabläufen ausstehend.

### t19 – Export als JSON, Excel und formatierten Text (0.10.0; angepasst in 0.10.1 und 0.10.2)

- Zeitraumwahl Monat/Jahr und Von–Bis analog Cashuvo.
- Seit 0.10.2 ohne Erklärungstext unter den Exportaktionen.
- Seit 0.10.1 neueste Tage zuerst in allen Formaten; Text kopieren, Textdatei, Excel und JSON gemeinsam unter Export.
- OneNote-Text: ein Absatz pro Trainingstag, neueste zuerst, Übungsreihenfolge, Bewertung vor Angaben, nur Arbeitsgruppen bei Satztypen und alle freien Einheiten bei Andere.
- Vorschau, Text kopieren und Textdatei ergänzen. JSON und XLSX enthalten sämtliche Satzgruppen und Einheiten des Zeitraums.
- Tests für Zeitraum, Text, JSON und XLSX ergänzt. Xcode-Build, Swift-Tests, Öffnen in Excel, Dateidialog auf iPhone/iPad und Einfügen in OneNote ausstehend.

### t34 – Farbige Trainingsbewertungen (0.9.1)

- -- Dunkelrot, - Rot, o Grau, + Grün und ++ Dunkelgrün bei allen drei Übungstypen in Auswahl, Tagesübersicht und Verlauf anzeigen.
- Auswahl über kräftigen Rahmen in derselben Farbe und dezenten Hintergrund kennzeichnen; Symbole und VoiceOver erhalten.
- Adaptive Hell-/Dunkelfarben verwenden. Xcode-Build und Sichtprüfung bei beiden Darstellungen, großer Schrift und VoiceOver ausstehend.

### t31 – Drei Übungstypen und Satzübung (0.9.0)

- Auswahl auf Krafttraining, Satzübung und Andere reduzieren. Satzübungen behalten Satzgruppen und Arbeitsmarkierung, rechts steht Freitext ohne kg; optionales Freitextziel ohne Prozentberechnung.
- Bisherige Typen Ergometer, Schwimmen und Joggen mit Texten und Vorlagen als Andere erhalten.
- Xcode-Build, Swift-Tests, Update über 0.8.0 und Geräteprüfung ausstehend.

### t32 – Zwei Felder je freier Trainingseinheit (0.9.0)

- Für Andere links und rechts freie Angaben erfassen, z. B. 200 W und 30 min.
- Vorlagen dürfen eines oder beide Felder vorgeben. Neue Trainings übernehmen beide Angaben; vorhandene Einträge bleiben unabhängig.
- Tests für Speicherung, Vorlagen, Typwechsel und Löschen ergänzt. Xcode-Ausführung und Sichtprüfung ausstehend.

### t33 – Bewertung für jeden Übungstyp (0.9.0)

- Alle fünf Bewertungen für Krafttraining, Satzübung und Andere anbieten, speichern, bearbeiten und entfernen.
- Bewertung gilt für den gesamten Trainingseintrag und wird einmal angezeigt: vor der Arbeitsgruppe bzw. der ersten freien Einheit.
- Xcode-Tests und Geräteprüfung ausstehend.

### t29 – Symmetrische Bewertung und Position (0.8.0)

- -- Sehr schwer, - Schwer, o Neutral, + Leicht und ++ Sehr leicht anbieten.
- Bewertung in der Tagesübersicht und im Verlauf links vor den Sätzen anzeigen.
- Bestehende Rohwerte und Symbole erhalten. Xcode-Build, Swift-Tests und Sichtprüfung mit fünf Flächen ausstehend.

### t30 – Vorlagen für Freitext-Trainingseinheiten (0.8.0)

- Geordnete, bearbeitbare Trainingseinheiten in der Übung hinterlegen und bei neuen Trainings übernehmen.
- Vorlagen pro Übungstyp speichern; vorhandene Krafttrainingsvorgaben und Trainings erhalten.
- Xcode-Build, Swift-Tests, Update über 0.7.0, Typwechsel und Geräteprüfung ausstehend.

### t28 – Weitere Übungsarten neben Krafttraining (0.7.0)

- Übungstypen Krafttraining, Ergometer, Schwimmen, Joggen und Andere anbieten.
- Ergometer, Schwimmen, Joggen und Andere als frei formulierte Trainingseinheiten erfassen, bearbeiten, anzeigen und löschen.
- Typ in jedem Trainingseintrag speichern. Bestehende Einträge ohne Typ gelten als Krafttraining. Typwechsel erhalten bisherige Trainings und Krafttrainingsvorgaben.
- Startbereich in Deine Übungen umbenannt. Karten, Tagesübersicht und Verlauf berücksichtigen den gespeicherten Typ.
- Xcode-Build, Swift-Tests, Update-Test über 0.6.9 und Sichtprüfung mit gemischten Typen ausstehend.

### t22 – Darstellung der Arbeitsgewicht-Bewertung verbessern (0.6.9)

- Vier direkt antippbare Auswahlflächen mit Symbol und kurzer Beschriftung anzeigen: -- Sehr schwer, - Schwer, o OK und + Leicht.
- Auswahl blau hervorheben, ausgeschriebene Bewertung darüber anzeigen und Entfernen über X ermöglichen.
- Bei großen Bedienungshilfen-Schriften die Auswahl in zwei Spalten anzeigen.
- Xcode-Build, Sichtprüfung auf iPhone 15 mit vier Satzgruppen und Tastatur sowie VoiceOver-Prüfung ausstehend.

### t25 – Abgeschnittene Überschrift der Trainingserfassung korrigieren (0.6.6)

- Training erfassen bzw. Training bearbeiten unterhalb der oberen Buttonleiste anzeigen.
- Den Übungsnamen direkt darunter als eigene große Überschrift anzeigen.
- Xcode-Build und Sichtprüfung auf dem Gerät ausstehend.

### t20 – Logo und App-Icon mit Langhantel (0.6.6)

- Gewünschtes Logo in 0.6.7 korrigiert: schräge weiße Langhantel auf blauem Verlauf.
- Als deckendes RGB-PNG mit 1024 × 1024 Pixeln in AppIcon eingebaut.
- Xcode-Build und Darstellung auf dem Home-Bildschirm ausstehend.

### t21 – Übung bei der Trainingserfassung eindeutig anzeigen (0.6.5)

- Übungsname als große, eigenständige Überschrift oberhalb des Formulars anzeigen. Die Überschrift bleibt beim Scrollen und bei geöffneter Tastatur sichtbar.
- Datum separat mit „Datum“ beschriften. Lange Übungsnamen dürfen über mehrere Zeilen laufen. Gilt für neue und bestehende Trainings.
- Xcode-Build und Sichtprüfung auf iPhone 15 mit vier Satzgruppen, offener Tastatur und langen Namen ausstehend.

### t23 – Blaue Akzentfarbe (0.6.3)

- Bedienelemente, Fortschrittsanzeigen und Arbeitsgewicht-Markierungen auf Blau umstellen und AccentColor für helle/dunkle Darstellung hinterlegen.
- Xcode-Build und Sichtprüfung ausstehend.

### t18 – Startseitenaktionen und direkte Trainingserfassung (0.6.0)

- Zahnrad und Fragezeichen rechts oben anzeigen.
- Stift neben Deine Ziele mit Übung anlegen und Übungen sortieren anbieten.
- Eigenes Plus pro Zielkarte öffnet sofort ein neues Training für diese Übung.
- Erstes kg-Feld nach dem Aufbau der Maske automatisch aktivieren, numerische Tastatur mit Fertig-Taste zeigen. Fokus pro Gruppe und Feld eindeutig unterscheiden.
- Xcode-Build, iPhone-15-Sichtprüfung mit vier Zielkarten und Tastaturtest auf dem Gerät ausstehend.

### t17 – Einzelnes Training über sichtbaren Button löschen (0.5.3)

- Tageszeile öffnet direkt das zugehörige Training. Im bestehenden Training „Dieses Training löschen“ anbieten und bestätigen lassen.
- Die Löschung verwendet deleteKeepingExercise und schließt den Editor erst nach erfolgreichem Speichern. Bei Fehlern zurückrollen und Meldung zeigen.
- Den letzten Eintrag einer Übung löschen und den Erhalt von Übung, Ziel, Standardsätzen und Reihenfolge auf dem Gerät prüfen. Abbrechen ebenfalls prüfen.
- Xcode-Build und Geräteprüfung ausstehend. Vorhandene Regressionstests für das Löschen einzelner und letzter Trainings bleiben relevant.

### t16 – ForEach-Compilerfehler bei SetGroup korrigieren (0.5.2)

- Gemeldeter Fehler in ContentView: ForEach über Satzgruppen verlangt Identifiable-Konformität.
- Satzgruppen und weitere gespeicherte Modelle über ihre vorhandene UUID explizit identifizieren.
- Swift-Syntax geprüft. Xcode-Build und Sichtprüfung ausstehend.

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
