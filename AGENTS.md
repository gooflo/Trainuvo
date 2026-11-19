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

- Pflege die interne SemVer-Version in README und Changelog. `0.x.x` bezeichnet Vorstufen, `1.0.0` die erste nutzbare Version.
- Führe die externe App-Store-Version und die Buildnummer separat. Stimme Änderungen der externen Version ab und ordne jeden hochgeladenen Build einem Commit oder Tag zu.
- TestFlight und die öffentliche App-Store-Veröffentlichung separat abstimmen.

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

## Dokumentation

- Pflege `README.md` als kompakten Einstieg mit Zweck, aktuellem Funktionsumfang, Voraussetzungen, Nutzung, interner Version und Entwicklungsstand sowie Links zur weiteren Dokumentation.
- Führe Änderungen pro interner Version in `Changelog.md`.
- Führe die gesamte technische Dokumentation gemeinsam in `DeveloperDocu.md`. Sie umfasst Entwicklungsumgebung und Einrichtung, Architektur und Datenmodell, Geschäftsregeln und technische Abläufe, Build und Tests sowie Veröffentlichung.
- Pflege `DeveloperDocu.md` bei Änderungen an diesen Themen im selben Commit mit. Lege README, Changelog und DeveloperDocu mit der ersten App-Version an.

- Exporte verwenden Monat/Jahr oder Von–Bis analog Cashuvo. OneNote-Text enthält einen Absatz je Trainingstag, absteigende Tage, Übungsreihenfolge und Bewertung vor den Angaben; nur Arbeitsgruppen bei Satztypen, alle freien Einheiten bei Andere. JSON und Excel enthalten alle Gruppen. Standardname für TXT/XLSX/JSON: Trainuvo_Export.<Endung>. Vor dem System-Teilen den Dateinamen wie in Cashuvo editierbar anbieten, mit fester Endung und Validierung.

- Kommentare gelten pro Trainingstag und werden unabhängig von Übungen/Trainings gespeichert. Ihre Löschung erhält Trainings; Trainings-/Übungslöschung erhält Tagesnotizen. Tage mit Notizen bleiben ohne Trainings sichtbar und exportierbar. Alles löschen entfernt auch Tagesnotizen.

## TestFlight und Ankündigungen

- Interne SemVer-Version, externe App-Version und Buildnummer getrennt führen. Während der Testphase die externe Version möglichst stabil halten; Änderungen vorher abstimmen. Die nächste Buildnummer muss in App Store Connect noch frei sein. Der Repositorywert allein beweist nicht, welche Builds schon hochgeladen wurden; Angaben von Florian zu belegten Builds berücksichtigen.
- Aktuell vereinbart: intern 0.12.1, extern 1.0.0 (3). Build 2 ist laut Florian bereits belegt. Künftige Zuordnungen in DeveloperDocu und Changelog dokumentieren.
- Wenn Florian „publishen“, „publizieren“, „veröffentlichen“ oder Ähnliches sagt, die kurze TestFlight-Checkliste und den vollständigen WhatsApp-Entwurf für den vorgesehenen Build in derselben Antwort ausgeben:
  1. Tag setzen und pushen.
  2. Archivieren und hochladen; externe Version und Build im Organizer prüfen. Automatische Buildnummernverwaltung für eine eindeutige Zuordnung abwählen, sofern angeboten.
  3. In App Store Connect unter der vorgesehenen externen Version beim bereiten Build die Testgruppe hinzufügen. Build-Uploads kann währenddessen noch Verarbeitung läuft zeigen.
  4. Zur Prüfung übermitteln, wenn die Schaltfläche angezeigt wird.
  5. Erst nach Verfügbarkeit für die Testgruppe in WhatsApp ankündigen.
- Vor Upload an Tag und Push mit Include tags erinnern. Bereits veröffentlichte Tags nicht verschieben. Öffentliche App-Store-Veröffentlichung separat abstimmen.
- WhatsApp-Entwurf analog Cashuvo: Überschrift exakt `✳️✳️✳️ NEUE VERSION ✳️✳️✳️`. Darunter externe Version samt Build, beispielsweise `Trainuvo 1.0.0 (3) ist jetzt in TestFlight verfügbar:`.
- Kurze Stichpunkte ausschließlich zu sichtbaren Änderungen gegenüber dem zuletzt verteilten Build. Abschnitte `Fehlerbehebungen und kleine optische Änderungen` sowie `Neue Funktionen`; Neue Funktionen bei Releases ohne neue Funktionen weglassen. Mit dem Hinweis auf das Update in TestFlight abschließen.
- Verfügbarkeit nur behaupten, wenn der Build für die Testgruppe bereitsteht oder der Entwurf ausdrücklich für diesen Zeitpunkt gedacht ist. Keine Nachrichten ohne gesonderten Auftrag versenden.
