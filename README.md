# Trainuvo

Trainuvo dokumentiert Krafttraining, Satzübungen und weitere Aktivitäten. Beim Krafttraining zeigt die App den Fortschritt gegenüber persönlichen Zielgewichten.

**Interner Entwicklungsstand: 0.19.2 – Vorabversion**

## Übungstypen

Beim Anlegen oder Bearbeiten einer Übung stehen genau drei Typen zur Auswahl:

| Typ | Links | Rechts | Vorlagen und Ziel |
|---|---|---|---|
| Krafttraining | Sätze × Wiederholungen | Gewicht mit kg | Standardsätze, Arbeitsgruppe und optionales Zielgewicht mit Prozentfortschritt |
| Satzübung | Sätze × Wiederholungen | Freie Angabe ohne feste Einheit | Standardsätze mit optionaler rechter Angabe, Arbeitsgruppe und optionales Freitextziel |
| Andere | Freie Angabe, z. B. 200 W | Freie Angabe, z. B. 30 min | Mehrere geordnete Einheiten; ein oder beide Felder dürfen vorbelegt sein |

Satzübungen eignen sich etwa für Klimmzüge und Liegestütze. Rechts kannst du beispielsweise „ohne Hilfe“ oder „mit Band“ eintragen. Satzauswahl, Arbeitsgruppe und Bewertung funktionieren wie beim Krafttraining. Ein Freitextziel wird angezeigt, aber nicht numerisch ausgewertet.

Bei Andere lassen sich pro Trainingseinheit zwei freie Angaben speichern. Mindestens ein Feld je Einheit muss ausgefüllt sein. In der Übungsbearbeitung kannst du unter **Vorlagen für Trainingseinheiten** nur links, nur rechts oder beide Felder vorbelegen und Einheiten mit den Pfeilen sortieren. Neue Trainings übernehmen beide Felder als unabhängig bearbeitbare Kopien. Ohne Vorlage startet ein neues Training mit einer leeren Einheit. Normale Tastatur und Fertig-Taste stehen bereit.

Jeder Eintrag speichert seinen Typ. Beim Wechsel des Übungstyps bleiben bestehende Trainings in ihrer ursprünglichen Form bearbeitbar. Vorlagen werden je Typ erhalten. Frühere Typen Ergometer, Schwimmen und Joggen erscheinen als **Andere**, einschließlich ihrer bisherigen Texte und Vorlagen. Es werden dabei keine gespeicherten Trainings gelöscht.

## Funktionen

- Übungen mit optionalem Zielgewicht und geordneten Standardsatzgruppen anlegen, bearbeiten und löschen.
- Zielkarten auf der Startseite in einer selbst festgelegten Reihenfolge anzeigen.
- Trainings direkt über das Plus auf der Zielkarte erfassen. Das erste kg-Feld wird mit numerischer Tastatur und Fertig-Taste geöffnet.
- Trainings pro Übung erfassen, nachtragen, bearbeiten und löschen.
- Mehrere Satzgruppen mit unterschiedlichen Gewichten erfassen. Die Vorauswahl bietet 1 × 3, 1 × 5, 3 × 5, 3 × 3 und 5 × 3. Freitext ist möglich.
- Bei Krafttraining und Satzübungen eine Arbeitsgruppe markieren. Bei allen drei Typen das gesamte Training optional bewerten.
- Kompakte iPhone-Übungskarten mit Name, Prozentwert, Plus und schmalem Fortschrittsbalken. Ziel, erreichter Wert und Datum stehen in der Übungsansicht; das iPad behält zusätzliche Karteninfos.
- Startseite mit Zielfortschritt und nach Datum zusammengefassten Trainingstagen. Jede Trainingszeile zeigt nur die Arbeitsgruppe, zum Beispiel Kniebeuge 3 × 5 @ 60 kg.
- Trainingsverlauf pro Übung. Neue Trainings übernehmen die Standardsätze mit leeren Gewichtsfeldern. Ohne Standardsätze dient das letzte Training als Vorschlag.
- Einstellungen über das Zahnrad mit **Beispieldaten anlegen** und dem bestätigten **Alles löschen**.
- Lokale SwiftData-Speicherung mit privatem iCloud-Abgleich für Übungen, Ziele, Vorlagen, Trainings, Bewertungen und Tageskommentare. Offline weiterarbeiten; Abgleich erfolgt zeitversetzt.

## Voraussetzungen

Die App ist für iPhone und iPad ausgelegt. Das App-Target unterstützt iOS/iPadOS ab 17.6. Zum Entwickeln wird eine passende Xcode-Version auf dem Mac benötigt.

## Nutzung

Unter **Einstellungen → Zielgewichte berechnen** gibst du dein Körpergewicht in kg ein. Der Rechner zeigt Kniebeuge 100 %, Press 40 %, Kreuzheben 130 % und Bankdrücken 75 % automatisch mit bis zu zwei Nachkommastellen. Komma und Punkt sind möglich; „Fertig“ schließt die Tastatur. Übungen und Zielgewichte trägst du selbst ein. Das eingegebene Körpergewicht wird lokal auf diesem Gerät gespeichert und beim nächsten Öffnen wieder vorbelegt; es wird nicht über iCloud synchronisiert. Auf der Seite stehen der Hinweis zur Herkunft der Werte und Florians persönliche Empfehlung mit Link zu [Work it Training Hamburg](https://workittraining.de/).

Seit 0.16.0 trennt die Startseite „Trainings“ durch horizontale Linien von den Übungen. Beim Erfassen steht das Datum unter Satzgruppen/Trainingseinheiten und Bewertung. Unter „Bewertung (sehr schwer ... sehr leicht)“ wählst du direkt eines der fünf farbigen Symbole. Ziel und erreichter Wert stehen in der Übungsansicht; das Datum des letzten Trainings steht direkt beim erreichten Wert bzw. bei Andere separat.

Bei Krafttraining und Satzübungen kannst du in der Trainingserfassung einzelne Sätze direkt in der Zeile abhaken: 1×5 zeigt ein Kästchen, 3×5 drei und 5×5 oder 5×3 fünf. Erneutes Antippen entfernt das Häkchen. Speichern übernimmt den Status, Abbrechen verwirft Änderungen. Neue Trainings starten leer; alte Trainings werden nicht automatisch abgehakt. Bei mehr als fünf Sätzen seitlich durch die Kästchen scrollen. Freitext ohne eindeutige Sätze×Wiederholungen und Andere zeigen keine Checkboxen. Der Abhakstatus ändert keine Gewichte oder Fortschrittsberechnungen.

Die Hilfe unter **?** zeigt externe Version, Buildnummer und interne Version als eine dezente Textzeile in einem eigenen Abschnitt: **Version 1.0.0 (14), v0.19.2**.

Nach „Text kopieren“ bestätigt die App „Text in die Zwischenablage kopiert“.

Über den **Stift neben Übungen → Übung anlegen** eine Übung mit optionalem Zielgewicht anlegen. Auf einer Zielkarte **+** antippen, um sofort ein neues Training zu öffnen. Bei Krafttraining erhält das erste kg-Feld automatisch den Fokus und die numerische Tastatur öffnet sich. Satzübungen fokussieren die rechte freie Angabe mit normaler Tastatur. Bei Andere wird das erste linke Feld fokussiert, bei nur links vorbelegter Vorlage das rechte Feld. **Fertig** schließt die Tastatur. Das Datum ist mit heute vorbelegt. Antippen der Karte öffnet den Übungsverlauf. Zahnrad und Hilfe stehen oben rechts.

Beim Anlegen oder Bearbeiten einer Übung unter **Standardsätze in Trainingsreihenfolge** die gewünschten Gruppen hinterlegen, etwa **1 × 5, 1 × 5, 3 × 5, 1 × 5**. Mit den Pfeilen die Reihenfolge ändern und eine Gruppe als Arbeitsgewicht markieren. Beim neuen Training sind diese Gruppen bereits angelegt, und du ergänzt die kg. Die Gruppen können für das einzelne Training angepasst werden. Änderungen an den Standardsätzen beeinflussen künftige Erfassungen. Bestehende Trainings behalten ihre Satzgruppen und Gewichte.

Die Trainingserfassung zeigt jede Satzgruppe in einer kompakten Zeile mit Arbeitsgewicht-Markierung, Satztext, Satzauswahl und Gewicht in kg. Vier Gruppen sollen auf dem iPhone 15 im Hochformat bei Standardtextgröße gemeinsam sichtbar sein. Unter der Buttonleiste stehen „Training erfassen“ bzw. „Training bearbeiten“ und darunter der Übungsname als eigene Überschrift über dem Formular und bleibt beim Scrollen und bei geöffneter Tastatur sichtbar. Das Datum steht separat darunter. Über den Pfeil stehen Vorauswahlen und Entfernen bereit. Eine Gruppe kann auch durch Wischen nach links entfernt werden. Tippe auf Kreis bzw. Zielscheibe, um die Arbeitsgruppe zu wählen.

Unter den Sätzen bzw. Trainingseinheiten lässt sich bei jedem Typ das gesamte Training optional bewerten. Fünf direkt antippbare Flächen zeigen nur das Symbol. Die Überschrift erklärt die Reihenfolge von sehr schwer bis sehr leicht. Schwere Bewertungen erscheinen rot, neutrale grau und leichte grün. Die ausgewählte Fläche erhält einen kräftigen Rahmen in ihrer Farbe und einen dezenten Hintergrund, VoiceOver nennt weiterhin die volle Bedeutung. Die Symbole bleiben zusätzlich zur Farbe erhalten. Über das X lässt sie sich entfernen. Im Verlauf und auf der Startseite steht das Symbol links vor den Sätzen der Arbeitsgruppe bzw. vor der ersten freien Einheit. Ein neues Training beginnt ohne ausgewählte Bewertung. Die Bewertung kann im Verlauf nachgetragen, geändert oder entfernt werden.

| Bewertung | Symbol | Farbe |
|---|---|---|
| Sehr schwer | `--` | Dunkelrot |
| Schwer | `-` | Rot |
| Neutral | `o` | Grau |
| Leicht | `+` | Grün |
| Sehr leicht | `++` | Dunkelgrün |

Für ein Training beispielsweise drei Satzgruppen erfassen:

| Sätze × Wiederholungen | Gewicht | Arbeitsgewicht |
|---|---|---|
| 1 × 5 | 50 kg | |
| 1 × 5 | 70 kg | |
| 3 × 5 | 100 kg | Ja |

Der Zielfortschritt entspricht dem Arbeitsgewicht des zeitlich letzten Trainings geteilt durch das aktuelle Zielgewicht. 60 kg bei einem Ziel von 100 kg ergeben 60 %. Bei identischem Datum einschließlich Uhrzeit entscheidet das Anlegedatum. Ein älterer nachgetragener Eintrag ersetzt den aktuellen Fortschritt daher nur, wenn er zeitlich der letzte ist.

Auf der Startseite neben **Übungen** den **Stift → Übungen sortieren** wählen, die Übungen an den Griffen verschieben und **Speichern** wählen. Die Reihenfolge bleibt nach einem Neustart erhalten. Neue Übungen erscheinen am Ende. Vor der ersten manuellen Sortierung stehen vorhandene Übungen alphabetisch.

Die Startseite zeigt Trainingstage mit dem neuesten Datum zuerst. Jede Tagesüberschrift beginnt mit dem ausgeschriebenen Wochentag und zeigt das Datum kurz, beispielsweise Mittwoch, 18.11.2026. Innerhalb eines Tages folgen die Einträge deiner Übungsreihenfolge. Pro Trainingseintrag erscheint eine Zeile mit dem Arbeitsgewicht und optionaler Bewertung. Mehrere Einträge derselben Übung am gleichen Tag bleiben als einzelne Zeilen sichtbar. Antippen öffnet genau den gewählten Trainingseintrag zum Bearbeiten und Löschen. Den vollständigen Übungsverlauf öffnest du über die Zielkarte.

Im Verlauf steht die Arbeitsgewicht-Markierung links neben dem Gewicht. Alle Gewichte sind rechtsbündig untereinander angeordnet. Einen Eintrag zum Bearbeiten antippen. Unten im geöffneten Training **Dieses Training löschen** wählen und bestätigen. Alternativ steht im Übungsverlauf die Wischaktion **Training löschen** bereit. Die Übungsaktionen stehen im Menü **…**. Das Löschen eines Trainings erhält die Übung und deren Standardsätze, auch beim letzten Training. Das separate Löschen einer Übung entfernt nach Bestätigung auch ihre Trainings.

Satztexte dürfen frei formuliert werden, etwa **5/5/4**. Sie werden unverändert dokumentiert. Für den Prozentwert zählt das markierte Gewicht. Gewichte können mit Komma oder Punkt eingegeben werden.

## Einstellungen und Beispieldaten

Über das Zahnrad die Einstellungen öffnen. **Alles löschen** entfernt nach ausdrücklicher Bestätigung sämtliche Übungen, Trainings, Standardsätze und Tageskommentare, nach dem iCloud-Abgleich auch auf den weiteren Geräten desselben Apple-Accounts.

**Beispieldaten anlegen** ergänzt folgende Daten mit je einem Training vom **14.11.2026** und **17.11.2026**. Die letzte Gruppe ist jeweils als Arbeitsgewicht markiert, die Bewertung ist leer.

| Übung | Ziel | Standardsatzgruppen | Trainingsgewichte 17.11. |
|---|---|---|---|
| Press | 40 kg | 1 × 5, 1 × 5 | 40, 52 kg |
| Kniebeuge | 100 kg | 1 × 5, 3 × 5 | 52, 90 kg |
| Bankdrücken | 80 kg | 1 × 5, 3 × 3 | 50, 85 kg |
| Kreuzheben | 130 kg | 1 × 5, 1 × 5, 3 × 5 | 50, 70, 100 kg |

Am **14.11.2026** sind nur die Arbeitsgewichte um jeweils 2 kg reduziert. Die Aufwärmgruppen verwenden die oben angegebenen Gewichte.

| Übung | Arbeitsgewicht 14.11. |
|---|---|
| Press | 50 kg |
| Kniebeuge | 88 kg |
| Bankdrücken | 83 kg |
| Kreuzheben | 98 kg |

Gleichnamige Übungen werden wiederverwendet. Vorhandene Ziele und vorhandene Standardsätze werden beibehalten. Leere Standardsätze werden ergänzt. Identische Beispieltrainings am angegebenen Datum werden beim erneuten Aufruf übersprungen.

## Dokumentation

- [DeveloperDocu.md](DeveloperDocu.md) – Einrichtung, Architektur, Datenmodell, Tests und Veröffentlichung
- [Todo.md](Todo.md) – Aufgaben und Testbefunde
- [Changelog.md](Changelog.md) – Versionshistorie
- [AGENTS.md](AGENTS.md) – Projektregeln

## Export

Unter **Einstellungen → Trainings exportieren** den Export öffnen. Die Auswahl „Monat“ mit Monat/Jahr oder „Von–Bis“ entspricht Cashuvo. Beide Randtage sind vollständig enthalten. Ohne passende Einträge bzw. bei ungültigem Zeitraum sind Exporte deaktiviert.

„Text kopieren“ überträgt die Vorschau direkt für OneNote. Ein Absatz pro Trainingstag, neueste Tage zuerst, Übungen in der gespeicherten Reihenfolge. Krafttraining und Satzübung zeigen nur die Arbeitsgruppe; Andere zeigt alle Einheiten mit „links / rechts“, mehrere Einheiten mit Semikolon. Bewertungen stehen als Zeichen davor. Zeilenumbrüche innerhalb freier Angaben werden für diesen kompakten Export zu Leerzeichen. Mehrere Einträge derselben Übung bleiben erhalten.

Beispiel: `17.11.2026 | Press o 1×5 @ 52 kg | Kniebeuge + 3×5 @ 90 kg`

Textdatei, JSON und echte Excel-Datei (.xlsx) lassen sich nach Eingabe eines Dateinamens über das Teilen-Menü speichern oder weitergeben. Standardname: `Trainuvo_Export.<Endung>`. JSON enthält alle ausgewählten Trainings mit IDs, Datumswerten, Bewertung und sämtlichen Gruppen sowie aktuellen Übungszielen. Excel zeigt eine Zeile je Gruppe bzw. Einheit mit numerischem kg-Wert, freien Angaben und Arbeitsmarkierung. Export verändert keine gespeicherten Daten und ist noch keine Wiederherstellungs-/Importfunktion.

Die vier Aktionen **Text kopieren**, **Textdatei**, **Excel** und **JSON** stehen unmittelbar untereinander unter **Export**, gefolgt von der Vorschau. Alle Formate zeigen die neuesten Trainingstage zuerst; innerhalb eines Tages gilt die Übungsreihenfolge der Startseite.

Die Exportaktionen stehen ohne zusätzlichen Erklärungstext direkt über der Vorschau.

## Tageskommentare

Neben dem Datum eines Trainingstags öffnet das Notizsymbol einen gemeinsamen Kommentar für alle Übungen dieses Tages. Speichern übernimmt die Eingabe, Abbrechen verwirft sie. Der Text erscheint unter den Übungen. Kommentar löschen entfernt nur die Notiz nach Bestätigung; auch leeres Speichern entfernt sie.

Kommentare bleiben beim Löschen von Trainings oder Übungen erhalten. Ein Tag mit Kommentar bleibt ohne Trainings sichtbar und bearbeitbar. Ändert sich das Datum eines Trainings, bleibt die Notiz am ursprünglichen Tag. Alles löschen entfernt auch die Tagesnotizen.

Text kopieren und TXT ergänzen am Ende der Tageszeile „| Notiz: …“. JSON enthält Tagesnotizen separat (schemaVersion 2), Excel eine Spalte Tageskommentar. Tage mit ausschließlich einer Notiz sind ebenfalls exportierbar. Alle Formate verwenden denselben Zeitraum.

Der nach Tagen gruppierte Verlauf auf der Startseite trägt die Überschrift „Trainings“.

## Dateiname beim Export

Vor dem Teilen von Textdatei, Excel und JSON erscheint die Dateinamen-Eingabe analog Cashuvo. Standard ist Trainuvo_Export.txt, Trainuvo_Export.xlsx bzw. Trainuvo_Export.json. Der Name ist frei änderbar; die feste Dateiendung steht rechts daneben und wird automatisch ergänzt. Eine bereits eingegebene passende Endung wird nicht doppelt angehängt. Abbrechen verwirft den Dialog. Leere Namen, Pfadtrenner, Doppelpunkte und Steuerzeichen sind nicht erlaubt. Text kopieren benötigt keinen Dateinamen.

Nächster Upload vorbereitet: extern **1.0.0 (14)**, intern **0.19.2**. Zuletzt abgeschlossene Uploadrunde laut Florian: **1.0.0 (13)**, intern **0.17.0**, Tag `v0.17.0-build13`. Externe und interne Versionen werden dreiteilig geführt. Vorheriger Upload: **1.0 (12)**, Tag `v0.17.0-build12`. Die zweistellige Versionierung wurde auf Florians Wunsch zurückgenommen; bestehende Builds und Tags bleiben erhalten. Export-Compliance: App Uses Non-Exempt Encryption = NO. Archivierung und Upload erfolgen auf dem Mac.


## iCloud ab 0.13.0

Der Abgleich verwendet die private CloudKit-Datenbank des angemeldeten Apple-Accounts. Jeder Tester behält seine eigenen Daten; eine gemeinsame Familien-Datenbank ist nicht vorgesehen. Auf allen eigenen Geräten müssen derselbe Apple-Account und iCloud für Trainuvo aktiviert sein. Am Ende der Einstellungen steht ein kurzer Hinweis zur iCloud-Synchronisierung; eine Accountstatusanzeige wird nicht angeboten.

Vor dem ersten Update vorhandene Daten als JSON exportieren und die bisherige App installiert lassen. Der Export ist eine zusätzliche Sicherung zum Nachschlagen, noch kein Import. Der Update-Pfad behält den bisherigen Store bei und migriert auf ein versioniertes, CloudKit-kompatibles Modell. Bei einem Öffnungsfehler wird der Store nicht zurückgesetzt. Bereits unabhängig auf mehreren Geräten angelegte Übungen werden zusammengeführt, jedoch nicht anhand gleicher Namen zu einem Objekt verschmolzen; dadurch können gleichnamige Übungen erscheinen.

Die Apple-Einrichtung, der Migrationstest, der Zwei-Geräte-Test und die Freigabe des CloudKit-Schemas für TestFlight sind in [DeveloperDocu.md](DeveloperDocu.md) beschrieben. Diese Prüfungen sind vor der Verteilung noch auf dem Mac durchzuführen.


## Diagnose mit Build 5 (0.13.1)

Build 4 startet laut Florian auf dem iPad mit erhaltenen Bestandsdaten, auf dem iPhone (iOS 27.2.1) scheitert das Öffnen mit Core-Data-Code 134504: „Cannot use staged migration with an unknown model version“. Build 3 war nach seiner Erinnerung zuvor installiert. Automatisierte Tests und Development-Schema-Einrichtung sind erfolgreich; das Schema wurde nach Production übertragen. Der iPhone-Fehler und der Production-Sync-Test bleiben offen (t38).

0.13.1 / 1.0.0 (5) ergänzt am Öffnungsfehler **Diagnose kopieren** und **Diagnose teilen**. Der Bericht enthält Versionen, Fehlercodes und gespeicherte/referenzierte Modellhashes, keine Trainingsinhalte oder Accountkennungen. Er liest Metadaten schreibgeschützt. Dies ist ein Diagnosebuild, noch keine bestätigte Reparatur. Auf dem betroffenen iPhone über Build 4 installieren, App nicht vorher löschen. Bei weiterem Fehler Diagnose kopieren und zur Analyse bereitstellen. Für Build 5 vor Upload die Verfügbarkeit in App Store Connect prüfen.


## Korrektur des Update-Pfads in 0.13.2

Die Diagnose vom iPhone zeigt einen älteren Store mit fünf Modellen ohne TrainingDayNote. Alle fünf Entitätshashes entsprechen den eingefrorenen alten Modellen; die fehlende Schema-Variante war die Ursache des Öffnungsfehlers 134504. Installierte Buildnummern allein bestimmen nicht den tatsächlich gespeicherten Modellstand.

Der Migrationsplan erkennt ab 0.13.2 auch diesen Ausgangsstand und ergänzt zuerst Tageskommentare, bevor er auf das vorhandene CloudKit-kompatible V2 aktualisiert. Bestehende Sechs-Modell- und V2-Stores werden weiter unterstützt. Die App verwendet den bisherigen Store; kein Reset und kein Ersatzstore. Das aktuelle CloudKit-Schema bleibt identisch, daher kein erneutes Deployment erforderlich.

Vorbereitet: intern **0.13.2**, extern **1.0.0 (6)**. Xcode-Build/Tests und Update auf dem betroffenen iPhone sind noch zu prüfen. Erst nach erfolgreichem Test verteilen; Build 6 vor Upload auf Verfügbarkeit prüfen. Die App auf dem iPhone nicht deinstallieren.


## Übungen auf der Startseite ausblenden

Öffne die Zielkarte einer Übung und schalte **Einblenden auf Startseite** direkt über **Training erfassen** aus. Die Übungsansicht bleibt geöffnet. Die Übung wird nicht gelöscht: Ziel, Standardsätze, Sortierung und Trainings bleiben erhalten. Die bisherigen Trainings sind weiter in der Tagesübersicht und in allen Exporten enthalten.

Zum Wiederherstellen im **Stift-Menü neben Übungen → Ausgeblendete Übungen anzeigen** aktivieren. Die Karte öffnen und **Einblenden auf Startseite** wieder einschalten. Auch wenn alle Karten ausgeblendet sind, bleibt das Stift-Menü erreichbar. Die Sichtbarkeit pro Übung wird gespeichert und über iCloud synchronisiert; die Anzeige ausgeblendeter Karten ist eine vorübergehende Ansicht auf dem aktuellen Gerät.

Intern 0.14.0 / extern 1.0.0 (8) vorbereitet. Vor TestFlight das um das optionale Sichtbarkeitsfeld erweiterte CloudKit-Schema in Development initialisieren, prüfen und nach Production übertragen. Details in DeveloperDocu.md.


Bei **… → Übung löschen** bietet die Abfrage jetzt drei Möglichkeiten: **Nur auf Startseite ausblenden**, **Übung und alle Trainings löschen** oder **Abbrechen**. Ausblenden erhält alle Daten, auch bei bereits ausgeblendeten Übungen. Intern 0.14.3 / extern 1.0.0 (8) vorbereitet; Buildnummer vor Upload auf Verfügbarkeit prüfen. Vor der ersten Verteilung der Ausblendfunktion weiterhin das V3-CloudKit-Feld nach Production deployen, wie oben beschrieben.

Wenn du ausgeblendete Übungen über das Stift-Menü anzeigst, tragen nur diese Karten unter ihrem Namen die Kennzeichnung **Ausgeblendet** mit einem durchgestrichenen Auge. Regulär sichtbare Karten behalten ihre Darstellung. Beim dauerhaften Einblenden verschwindet die Kennzeichnung.


## CSV-Import und -Export ab 0.19.0

**Gesamtexport:** Einstellungen → Trainings exportieren → Zeitraum wählen → CSV (Krafttraining). **Einzelexport:** Kraftübung → … → Trainings exportieren → Zeitraum → CSV (Krafttraining). Standardname Trainuvo_Export.csv, vor dem Teilen änderbar. Andere Exportformate bleiben verfügbar. CSV enthält ausschließlich Krafttraining, auch bei ausgeblendeten Übungen; neueste Tage zuerst, Übungsreihenfolge wie auf der Startseite. Alle Satzgruppen einschließlich 0 kg werden ausgegeben.

**Gesamtimport:** Einstellungen → Trainings aus CSV importieren. **Einzelimport:** Kraftübung → … → Trainings importieren. Gemeinsames Format, eine Zeile pro Satzgruppe:

```csv
Training-ID;Übung;Datum;Satzgruppe;Sätze;Gewicht;Arbeitsgruppe;Bewertung
training-001;CSV-Test Kniebeuge;18.11.2026;1;1x5;0;nein;o
training-001;CSV-Test Kniebeuge;18.11.2026;2;1x5;52;nein;o
training-001;CSV-Test Kniebeuge;18.11.2026;3;3x5;90;ja;o
training-002;CSV-Test Press;18.11.2026;1;1x5;40;nein;+
training-002;CSV-Test Press;18.11.2026;2;1x5;52;ja;+
```

Zusammengehörige Gruppen haben dieselbe Training-ID, denselben Übungsnamen, Tag und Bewertung; Satzgruppen lückenlos ab 1, genau eine Arbeitsgruppe (ja/nein). Zeilen dürfen vertauscht sein; die Nummer bestimmt die Reihenfolge. Export verwendet die UUID des Trainings. Manuelle IDs wie training-001 sind ebenfalls zulässig. Datum TT.MM.JJJJ, Gewicht 0–100000 ohne kg, Dezimalkomma/-punkt; Satzvorgabe frei oder NxM mit x/X/×. Bewertung leer oder --, -, o, +, ++. OneNote-Werte vorher übersetzen: ok → o, ok+ → +, + → ++. UTF-8 (BOM optional) oder UTF-16 mit BOM, Semikolon; zitierte Felder mit verdoppelten Anführungszeichen und eingebetteten Zeilenumbrüchen erlaubt. Export als UTF-8 mit BOM für Excel. Maximal 2 MB/10.000 Satzgruppen.

Die Vorschau zeigt komplette Trainings. Eindeutige bestehende Kraftübungen werden nach Namen vorbelegt; bei mehreren gleichnamigen Übungen selbst auswählen. **Neue Kraftübung anlegen** muss ausdrücklich gewählt werden; neue Übungen erhalten weder Ziel noch Vorlage. Das alte Vier-Spalten-Format Datum;Sätze;Gewicht;Bewertung bleibt importierbar: jede Zeile ist eine Arbeitsgruppe, bei Gesamtimport Übung selbst zuordnen. Beim Einzelimport wird der Name in der Datei geprüft; abweichenden Namen ausdrücklich bestätigen. Mehrübungsdateien bitte über Einstellungen importieren.

Duplikate werden anhand des vollständigen Trainings mit allen Gruppen, Reihenfolge, Arbeitsgruppe, Tag und Bewertung geprüft. Gleiche exportierte UUID plus gleiche Werte → überspringen. Gleiche UUID mit abweichenden Werten → Konflikt, niemals überschreiben. Unterschiedliche UUIDs können echte zusätzliche Trainings darstellen; am gleichen Tag sind sie zunächst abgewählt. Ohne UUID werden identische Inhalte ebenfalls übersprungen. Abweichende oder weitere Trainings nur ausdrücklich zusätzlich auswählen. Bei einer bestätigten ID-Kollision erhält das zusätzliche Training eine neue UUID. Vor dem atomaren Speichern wird mit dem aktuellen Datenbestand erneut geprüft. Dateifehler sperren den gesamten Import. Abbrechen / Cancel speichert nichts.

CSV ist ein Trainingsaustauschformat: Ziele, Vorlagen, Tagesnotizen, Satzhäkchen und Uhrzeiten sind nicht enthalten; keine vollständige Wiederherstellung des JSON-Exports. Datum bleibt erhalten, Uhrzeit wird beim Import lokal auf 12 Uhr gesetzt. Bestehende Daten werden nicht überschrieben. Kein neues Datenmodell/CloudKit-Schema.

[Examples/Trainuvo_Krafttraining.csv](Examples/Trainuvo_Krafttraining.csv) enthält ausschließlich fiktive Daten für zwei Testübungen mit Aufwärmgruppen. Die ältere [Trainuvo_Import_Beispiel.csv](Examples/Trainuvo_Import_Beispiel.csv) demonstriert weiter das einfache Format. Diagramme und die Konvertierung persönlicher OneNote-Daten sind nicht Bestandteil dieser Runde.
