# Trainuvo

Lies vor der Arbeit an diesem Repository auch [AGENTS_general.md](AGENTS_general.md).

## Entwicklung und Git

- Trainuvo ist eine native iOS- und iPadOS-App zur Dokumentation von Krafttraining und Trainingszielen. Verwende SwiftUI und SwiftData.
- Unterstützte Übungstypen sind Krafttraining, Satzübung und Andere. Krafttraining verwendet kg, Satzübung dieselben Satzgruppen mit einer freien rechten Angabe ohne feste Einheit und Andere zwei freie Felder je Trainingseinheit. Frühere Typwerte ergometer, swimming und jogging werden ohne Datenverlust als Andere gelesen. Jeder Trainingseintrag speichert seinen Typ, sodass spätere Änderungen der Übung frühere Einträge erhalten.
- Verwende Blau als primäre Akzentfarbe für Bedienelemente, Arbeitsgewicht-Markierungen und Fortschrittsanzeigen.
- Das ausgewählte Logo zeigt eine schräge weiße Langhantel auf blauem Verlauf. Das App-Icon liegt im Assetkatalog unter AppIcon.
- Halte die lokale Arbeitskopie auf dem Mac außerhalb von iCloud Drive. Arbeite direkt auf `main` im privaten GitHub-Repository. Der Assistent committet vereinbarte Änderungen, Florian pullt und testet in Xcode und setzt und pusht anschließend das Release-Tag.
- Beschreibe Bedienungsschritte zuerst für Xcode. Gib bei der Übergabe einen konkreten Simulator- oder Gerätetest an und vermerke, wenn kein Xcode-Build oder Gerätetest möglich war.

## Versionierung und Veröffentlichung

- Versionsanzeige in der Hilfe analog Cashuvo als eine dezente Textzeile in einem eigenen Abschnitt oberhalb der übrigen Hilfe: Version <extern> (<Build>), v<intern>. Alle Werte aus Bundle.main lesen.

- Pflege die interne SemVer-Version in README und Changelog. `0.x.x` bezeichnet Vorstufen, `1.0.0` die erste nutzbare Version.
- Externe App-Store-/TestFlight-Versionen wieder dreiteilig als Major.Minor.Patch führen (z. B. 1.0.0); interne SemVer bleibt ebenfalls dreiteilig, mit eigenständiger Buildnummer. Die Rückkehr zum dreiteiligen Format für Build 13 behält intern 0.17.0. Führe die externe App-Store-Version und die Buildnummer separat. Stimme Änderungen der externen Version ab und ordne jeden hochgeladenen Build einem Commit oder Tag zu.
- TestFlight und die öffentliche App-Store-Veröffentlichung separat abstimmen.

## Bedienung und Sicherheitsabfragen

- Bei Sicherheitsabfragen vor Export, Import, Löschen oder anderen folgenreichen Aktionen stets eine sichtbare, zweisprachige Abbrechen-/Cancel-Schaltfläche zusätzlich zur eigentlichen Aktion anbieten, auch auf dem iPad. Nicht allein auf Tippen außerhalb eines Popovers als Abbruch verlassen.

## Trainingsdaten

- Erhalte vorhandene Trainingseinheiten, Übungen, Sätze und Ziele bei Updates. Prüfe Änderungen am SwiftData-Modell mit Daten aus einer älteren App-Version, sobald eine solche Version verteilt wurde.
- Verwende in Tests Beispieldaten und prüfe bei Änderungen an der Trainingserfassung auch den Verlauf und die davon betroffenen Ziele.

- Das Löschen eines Trainings erhält die zugehörige Übung und ihre Standardsätze, auch beim letzten Training. Eine Übung wird über ihre separate Löschaktion oder das bestätigte „Alles löschen“ entfernt. Löschänderungen mit einem Test für den letzten Trainingseintrag absichern.

- Neue Trainings über das Plus auf der Zielkarte direkt öffnen. Bei Krafttraining das erste kg-Feld mit numerischer Tastatur, bei Satzübungen die erste rechte Angabe mit normaler Tastatur fokussieren. Andere fokussiert links, bei nur links vorbelegter Vorlage rechts. Die Tastaturen bieten „Fertig“. Die automatische Fokussierung soll vorhandene Benutzereingaben nicht überschreiben.

- Die optionale Bewertung gilt für den gesamten Trainingseintrag und ist bei allen drei Übungstypen verfügbar. Bewertungen verwenden -- Sehr schwer (Dunkelrot), - Schwer (Rot), o Neutral (Grau), + Leicht (Grün) und ++ Sehr leicht (Dunkelgrün). Die Farben gelten in Auswahl und Zusammenfassungen mit Varianten für Hell/Dunkel. Die ausgewählte Bewertung hat einen kräftigen Rahmen in ihrer Farbe; die Symbole und VoiceOver-Bedeutungen bleiben erhalten. Im Verlauf und in der Tagesübersicht stehen sie links vor den Sätzen bzw. der ersten freien Trainingseinheit.
- Vorlagen für Satzgruppen bzw. freie Trainingseinheiten gelten pro Übung und Übungstyp. Typwechsel erhalten die Vorlagen anderer Typen; Vorlagenänderungen verändern keine bestehenden Trainings.

## Aufgaben und Testbefunde

- Führe Aufgaben und Testbefunde in [Todo.md](Todo.md). Vergib fortlaufende Kennungen wie `t01` und behalte sie bei.
- Führe neue und zurückgestellte Einträge unter **Open**. Verschiebe umgesetzte Einträge mit der internen Trainuvo-Version nach **Done** und vermerke ausstehende Prüfungen beim Eintrag.
- Jede Todo-Übersicht als kompakte Tabelle mit ID, Priorität, Beschreibung und Status (Validierung/Freigabe ausstehend, in Bearbeitung, noch zu bearbeiten oder zurückgestellt) ausgeben. Bei offenen Validierungen den konkret ausstehenden Test bzw. die Freigabe nennen; bei teilweise umgesetzten Todos auch noch nötige Arbeiten nennen. Nach Priorität sortieren.

## Dokumentation

- Pflege `README.md` als kompakten Einstieg mit Zweck, aktuellem Funktionsumfang, Voraussetzungen, Nutzung, interner Version und Entwicklungsstand sowie Links zur weiteren Dokumentation.
- Führe Änderungen pro interner Version in `Changelog.md`.
- Führe die gesamte technische Dokumentation gemeinsam in `DeveloperDocu.md`. Sie umfasst Entwicklungsumgebung und Einrichtung, Architektur und Datenmodell, Geschäftsregeln und technische Abläufe, Build und Tests sowie Veröffentlichung.
- Pflege `DeveloperDocu.md` bei Änderungen an diesen Themen im selben Commit mit. Lege README, Changelog und DeveloperDocu mit der ersten App-Version an.

- Exporte verwenden Monat/Jahr oder Von–Bis analog Cashuvo. OneNote-Text enthält einen Absatz je Trainingstag, absteigende Tage, Übungsreihenfolge und Bewertung vor den Angaben; nur Arbeitsgruppen bei Satztypen, alle freien Einheiten bei Andere. JSON und Excel enthalten alle Gruppen. Standardname für TXT/XLSX/JSON: Trainuvo_Export.<Endung>. Vor dem System-Teilen den Dateinamen wie in Cashuvo editierbar anbieten, mit fester Endung und Validierung.

- Kommentare gelten pro Trainingstag und werden unabhängig von Übungen/Trainings gespeichert. Ihre Löschung erhält Trainings; Trainings-/Übungslöschung erhält Tagesnotizen. Tage mit Notizen bleiben ohne Trainings sichtbar und exportierbar. Alles löschen entfernt auch Tagesnotizen.

## TestFlight und Ankündigungen

- Interne SemVer-Version, externe App-Version und Buildnummer getrennt führen. Während der Testphase die externe Version möglichst stabil halten; Änderungen vorher abstimmen. Die nächste Buildnummer muss in App Store Connect noch frei sein. Der Repositorywert allein beweist nicht, welche Builds schon hochgeladen wurden; Angaben von Florian zu belegten Builds berücksichtigen.
- Versionsstand: intern 0.19.1 / extern 1.0.0 (14) für nächsten Upload vorbereitet (gemeinsamer CSV-Import/-Export). Noch kein Upload von Build 14 bestätigt; deshalb Buildnummer unverändert. Letzter bestätigter Upload 1.0.0 (13), intern 0.17.0, Tag v0.17.0-build13 / Commit 26780ada897bc29c3cd0f452ca02fe573281e7d0. Testgruppen-Verfügbarkeit nicht separat bestätigt; keine öffentliche App-Store-Veröffentlichung bestätigt. Build 14 vor Upload auf Verfügbarkeit prüfen.
- Wenn Florian „publishen“, „publizieren“, „veröffentlichen“ oder Ähnliches sagt, die kurze TestFlight-Checkliste und den vollständigen WhatsApp-Entwurf für den vorgesehenen Build in derselben Antwort ausgeben:
  1. Tag setzen und pushen.
  2. Archivieren und hochladen; externe Version und Build im Organizer prüfen. Automatische Buildnummernverwaltung für eine eindeutige Zuordnung abwählen, sofern angeboten.
  3. In App Store Connect unter der vorgesehenen externen Version beim bereiten Build die Testgruppe hinzufügen. Build-Uploads kann währenddessen noch Verarbeitung läuft zeigen.
  4. Zur Prüfung übermitteln, wenn die Schaltfläche angezeigt wird.
  5. Erst nach Verfügbarkeit für die Testgruppe in WhatsApp ankündigen.
- Vor Upload an Tag und Push mit Include tags erinnern. Bereits veröffentlichte Tags nicht verschieben. Öffentliche App-Store-Veröffentlichung separat abstimmen.
- WhatsApp-Entwurf analog Cashuvo: Überschrift exakt `✳️✳️✳️ NEUE VERSION ✳️✳️✳️`. Darunter externe Version samt Build, beispielsweise `Trainuvo 1.0.0 (13) ist jetzt in TestFlight verfügbar:`.
- Kurze Stichpunkte ausschließlich zu sichtbaren Änderungen gegenüber dem zuletzt verteilten Build. Verbindliche Reihenfolge für WhatsApp-Ankündigungen (TestFlight und App Store) und Versionshinweise: zuerst `Neue Funktionen`, danach `Fehlerbehebungen und kleine optische Änderungen`. Abschnitte ohne Einträge weglassen. Künftig immer mit dem exakten Satz „Viel Spaß beim Testen!“ abschließen. Die bisherige Schlussaufforderung zu Update, Rückmeldungen und Screenshots entfällt.
- Verfügbarkeit nur behaupten, wenn der Build für die Testgruppe bereitsteht oder der Entwurf ausdrücklich für diesen Zeitpunkt gedacht ist. Keine Nachrichten ohne gesonderten Auftrag versenden.

## SwiftData und CloudKit

- TrainuvoSchemaV1 entspricht dem ausgelieferten Modell aus v0.12.0 und 0.12.1 und bleibt unverändert. V2 aus 0.13.0–0.13.3 ist in TrainuvoSchemaV2.swift ebenfalls eingefroren. V3 aus 0.14.x ist in TrainuvoSchemaV3.swift ebenfalls eingefroren. Aktuelles Modell ist V4; spätere Modelländerungen als neues VersionedSchema mit Migrationsplan und Bestandsdaten-Test umsetzen.
- TrainuvoSchemaBeforeDayNotes sichert zusätzlich den historischen Fünf-Modell-Stand ohne TrainingDayNote. Bei Modelländerungen auch Installationen mit älteren Modellmengen testen; nicht nur den unmittelbar letzten App-Stand rekonstruieren. Migrationsfolge BeforeDayNotes → V1 → V2 → V3 → V4 erhalten.
- Bestehenden default.store und gespeicherte IDs erhalten. Bei Container-/Migrationsfehlern Fehlermeldung anzeigen; kein automatisches Löschen oder Ersatz durch einen leeren Store.
- Private CloudKit-Datenbank iCloud.com.vogtapps.Trainuvo verwenden. Kein gemeinsamer Familien-Datensatz. Beziehungen optional halten, Attribute optional oder mit Default; keine Unique-Constraints.
- Development-Schema nur im Debug-Modus und in einem isolierten temporären Store initialisieren. Vor TestFlight das geprüfte Schema nach Production deployen.
- Sync-Abnahme umfasst Update einer Bestandsinstallation und zwei Geräte desselben Accounts: Anlegen/Ändern, Offline-Nachholen, Bewertungen, Sortierung, Tageskommentare und Löschen eines letzten Trainings bei Erhalt von Übung/Vorlagen. Accountstatus nicht als abgeschlossenen Sync darstellen.


- t26 verwendet Exercise.hiddenFromHome (optional; nil = sichtbar), um Startkarten zu verbergen. Keine Übung oder Trainings dafür löschen. Verlauf, Tagesübersicht und Exporte behalten alle Trainings. Ausgeblendete Karten über das Stift-Menü wieder zugänglich machen; Flag synchronisiert, Ansichtsschalter lokal. V3/CloudKit-Schema vor TestFlight nach Production deployen.

- Die Löschabfrage einer Übung bietet immer auch Nur auf Startseite ausblenden mit Datenerhalt. Dieser Pfad setzt das Flag ausdrücklich auf true; nicht umschalten. Das dauerhafte Entfernen von Übung und Trainings bleibt eine separate destruktive Auswahl.

- Sichtbarkeit pro Übung über den Schalter Einblenden auf Startseite direkt über Training erfassen anbieten. Beim Umschalten bleibt die Detailansicht geöffnet. Das Stift-Menü kann ausgeblendete Karten zur Wiederherstellung anzeigen.

- Bei Anzeige ausgeblendeter Startkarten diese mit eye.slash und Ausgeblendet kennzeichnen; regulär sichtbare Karten behalten ihre Darstellung. Die Kennzeichnung folgt dem gespeicherten Flag und entfällt nach dauerhaftem Einblenden.

- t40: Satz-Checkboxen für Krafttraining/Satzübung, eine je Satz bei eindeutigem NxM (x/×), maximal 100 Sätze. SetGroup.completedSetsRawValue speichert optionale, kommaseparierte Satznummern ab 1, nil = keine Häkchen. Neue Trainings übernehmen keine Häkchen aus Vorlagen/letztem Training. Speichern/Abbrechen wie andere Trainingsfelder; Satzreduktion verwirft überzählige Häkchen. Vor TestFlight V4-Feld in Development initialisieren, prüfen und nach Production deployen.

- Seit 0.16.0 iPhone-Karten kompakt mit Namen/Prozent/Plus/Balken, ohne Detailzeile; iPad behält Detailinfos. Ziel/erreichter Wert/letztes Datum müssen in der Übungsansicht verfügbar bleiben. Bewertung zeigt nur fünf farbige Symbole unter Bewertung (sehr schwer ... sehr leicht), VoiceOver behält die Bedeutung. Trainingsdatum unter Satzgruppen/Einheiten und Bewertung.

- Zielgewichtsrechner in Einstellungen separat halten: Körpergewicht lokal per AppStorage/UserDefaults für erneutes Öffnen und App-Neustart speichern, keine iCloud-Synchronisierung, Faktoren Kniebeuge 100 %, Press 40 %, Kreuzheben 130 %, Bankdrücken 75 %. Ergebnisse anzeigen, keine Übungen/Ziele automatisch anlegen oder ändern. Abgestimmte Herkunftsangabe und persönliche Empfehlung durch Florian mit Link https://workittraining.de/ erhalten.

- Gemeinsames CSV-Format für Import/Export einzelner und mehrerer Kraftübungen: Training-ID;Übung;Datum;Satzgruppe;Sätze;Gewicht;Arbeitsgruppe;Bewertung. Alle Satzgruppen einschließlich 0 kg erhalten; eine Zeile je Gruppe, gleiche Trainings-ID, Reihenfolge ab 1 und genau eine Arbeitsgruppe. Legacy-Vierspaltenformat weiter importieren. Gesamtexport und Gesamtimport gemeinsam unter Einstellungen → Import und Export anbieten; kein Export-Button auf der Startseite. Gesamtimport mit Zuordnung zu bestehenden Kraftübungen; neue Übungen nur nach expliziter Auswahl anlegen. Einzelimport zeigt Namensabweichung und verlangt Bestätigung; Mehrübungsdateien dort sperren. Vor Save vollständige Gruppen/Tag/Bewertung plus UUID prüfen, Abweichungen nur ausdrücklich zusätzlich anlegen, niemals überschreiben. Exportierte UUIDs für neue Trainings erhalten, bei bestätigter ID-Kollision neue UUID verwenden. Isolierter Kontext ohne Autosave/atomarer Save, Abbrechen / Cancel sichtbar. UTF-8/UTF-16 mit BOM, Semikolon, Quotes/mehrzeilige Felder; 2 MB/10.000 Gruppen. Export im vorhandenen Zeitraum-/Dateinamenfluss, neueste Tage zuerst. CSV umfasst keine Ziele, Vorlagen, Tagesnotizen, Satzhäkchen oder Uhrzeiten; kein vollständiges Backup. V4 unverändert.
