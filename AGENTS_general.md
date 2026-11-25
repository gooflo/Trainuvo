# Allgemeine Projektregeln

## Zusammenarbeit

- Bei Ideen, Einschätzungen und Plänen zuerst einen konkreten Vorschlag machen und auf mein Okay warten. Einen ausdrücklich erteilten Änderungsauftrag direkt umsetzen. Zusätzliche Vorhaben wie Skripte oder einen Wechsel des Arbeitsablaufs vorher abstimmen.
- Vor Änderungen den aktuellen Stand und die vorhandene Projektdokumentation prüfen. Den Auftrag mit einer möglichst kleinen, vollständigen Änderung umsetzen.
- Bestehende Daten, Konfigurationen und Arbeitsabläufe erhalten. Änderungen an Datenmodellen oder Dateiformaten auch mit Bestandsdaten und älteren Formaten prüfen.
- Für Tests synthetische oder anonymisierte Daten verwenden. Zugangsdaten, echte Bankexporte und private Buchungsdaten aus dem Repository heraushalten.
- Den betroffenen Ablauf gezielt prüfen. Bei der Übergabe festhalten, was getestet wurde und was noch offen ist.

## Projektgrenzen im Chat

- Jeder Projektchat ist einem bestimmten Projekt zugeordnet. Vor Änderungen prüfen, ob das betroffene Projekt zum aktuellen Chat gehört. Die bloße Erwähnung eines anderen Projekts oder ein Änderungsauftrag dafür hebt diese Grenze nicht automatisch auf.
- Soll ein anderes Projekt geändert werden, vor jeder Bearbeitung ausdrücklich darauf hinweisen: „Das betrifft <anderes Projekt> statt <Projekt dieses Chats> und verstößt gegen unsere Regel zur Projekttrennung. Möchtest du für diesen konkreten Auftrag eine Ausnahme erlauben?“ Erst nach ausdrücklicher Zustimmung Änderungen vornehmen, committen oder pushen. Ohne Zustimmung den Wechsel in den zuständigen Projektchat vorschlagen.
- Eine ausdrücklich erteilte Ausnahme gilt nur für die genannten Projekte und den konkreten Auftrag. Eine ausdrücklich genehmigte gemeinsame Regeländerung darf in allen benannten Repositories umgesetzt werden; daraus entsteht keine dauerhafte Freigabe für weitere projektfremde Änderungen.

## Versionierung

- Verwende `MAJOR.MINOR.PATCH`, bei separater Buildnummer `MAJOR.MINOR.PATCH (BUILD)`.
- Erhöhe bei jeder abgeschlossenen Änderung die Projektversion. Inkompatible Änderungen erhöhen Major, neue Funktionen mindestens Minor. Fehlerkorrekturen und kosmetische Änderungen erhöhen Patch.
- Wenn eine Änderung im Test noch nicht wie gewünscht funktioniert, frage vor der Nachbesserung, ob wir dieselbe Version beibehalten oder erhöhen sollen. Nachbesserungen bis zur Abnahme können nach Absprache dieselbe Version behalten.
- Erhöhe die Buildnummer für einen neuen Upload, wenn der bisherige Build bereits erfolgreich hochgeladen wurde. Die Buildnummer ist unabhängig von der Projektversion.
- Nach einer App-Store-Veröffentlichung muss für den nächsten Upload (auch TestFlight) die externe App-Store-Version erhöht werden, da der bisherige Release-Train geschlossen ist. Die bereits für den nächsten Upload vorgesehene Buildnummer beibehalten, sofern sie noch nicht erfolgreich hochgeladen wurde; nicht allein wegen der Erhöhung der externen Version erneut erhöhen oder zurücksetzen. Vor dem Upload die Verfügbarkeit prüfen. Beispiel: ein abgelehnter Upload `1.0.1 (20)` nach Veröffentlichung von `1.0.1` wird mit `1.0.2 (20)` wiederholt. Interne Version nach Absprache unverändert lassen.
- Halte die Versionsangaben in den vorgesehenen Projektdateien und im Changelog konsistent. Git-Release-Tags heißen `vMAJOR.MINOR.PATCH`.

- Bei jeder abgeschlossenen Änderung in der Übergabe alle Versionsstände des betroffenen Projekts ausdrücklich ausgeben: (1) aktuelle interne Entwicklungsversion, (2) aktuelle externe TestFlight-Zuordnung einschließlich Buildnummer (geplant oder tatsächlich hochgeladen/verfügbar; falls abweichend den letzten bestätigten TestFlight-Stand zusätzlich nennen), (3) zuletzt öffentlich veröffentlichte App-Store-Version einschließlich Buildnummer und zugehöriger interner Version, sofern bekannt. Vor der ersten öffentlichen Veröffentlichung ausdrücklich „noch nicht veröffentlicht“ nennen; unbestätigte öffentliche Verfügbarkeit kennzeichnen. Die vollständige Übersicht auch bei reinen Dokumentations-, Regel- und Website-Änderungen ohne Versionswechsel ausgeben. Vor einem Upload die freie Buildnummer prüfen.

- In der App-Hilfe müssen die interne Projektversion und die Buildnummer sichtbar sein. Beide Werte aus den Metadaten des installierten App-Bundles lesen (projektspezifischer Schlüssel für die interne Version und `CFBundleVersion`); keine unabhängig gepflegten oder hart codierten Versionswerte anzeigen. Bei Änderungen an Versionierung oder Hilfe die Anzeige gegen die Build-Konfiguration prüfen.

- Die zuletzt öffentlich veröffentlichte App-Store-Version getrennt vom Entwicklungs- und TestFlight-Stand in `AppStoreRelease.md` dokumentieren: externe Version, Buildnummer, interne Version, Git-Tag bzw. Commit, Veröffentlichungsdatum und bestätigten Status. Vor der ersten öffentlichen Veröffentlichung ausdrücklich „noch keine öffentliche Version“ festhalten. Bei unbestätigter Verfügbarkeit den Stand als solchen kennzeichnen.
- Für jede App-Store-Veröffentlichung die vollständigen Texte für „Neu in dieser Version“ auf Deutsch und Englisch erstellen. Maßgeblich ist die Differenz zur letzten öffentlich veröffentlichten Version (Git-Tag/Commit und Changelog), nicht zum letzten TestFlight-Build. Alle relevanten nutzersichtbaren Änderungen seitdem zusammenfassen, nach Fehlerbehebungen und neuen Funktionen gliedern und interne Zwischenstände weglassen. Den öffentlichen Referenzstand erst nach bestätigter Veröffentlichung aktualisieren.

## Arbeit mit Git-Repositories

- Prüfe vor Änderungen den vereinbarten Branch und den aktuellen Stand des Remotes. Prüfe bei Zugriff auf eine lokale Arbeitskopie auch deren Status und erhalte vorhandene Änderungen.
- Arbeite auf dem vereinbarten Branch. Weitere Branches und Pull Requests vorher abstimmen.
- Prüfe die Änderung vor dem Commit. Fasse zusammengehörige Änderungen in einem Commit mit aussagekräftiger Nachricht zusammen.
- Nenne bei der Übergabe Branch, Commit und die Schritte zum Pullen und Testen in meiner Entwicklungsumgebung.
- Erinnere mich vor einem Release daran, den vorgesehenen Commit zu taggen und das Tag zu pushen. Prüfe auf Wunsch, ob das Remote-Tag auf den richtigen Commit zeigt.
- Nimm veröffentlichte Änderungen auf einem gemeinsamen Branch per Revert-Commit zurück. Force-Pushes und Änderungen an gepushten Tags vorher abstimmen. Veröffentlichungen nur auf ausdrücklichen Auftrag ausführen.

## Dokumentation und Übergabe

- Aktualisiere README und Changelog, wenn sich Bedienung, Einrichtung oder Verhalten ändern.
- Verwende den vereinbarten Übergabeweg. Bei manuellem Dateiaustausch vollständige Dateien mit den vorgesehenen Standardnamen oder ein vollständiges Update-ZIP liefern.
- Pflege die Regeldateien im selben Arbeitsgang, wenn wir eine dauerhafte Regel neu vereinbaren oder ändern. Allgemeine Regeln gehören in `AGENTS_general.md`, projektspezifische Regeln in `AGENTS.md`.
- Weise bei Änderungen am allgemeinen Teil darauf hin, dass andere Projekte die aktualisierte Datei übernehmen können. Einzelne Aufgaben und Testergebnisse gehören in den Changelog oder die Aufgabenliste.

## iCloud / CloudKit bei iOS-Apps

- Bei jeder neuen iCloud-Anbindung die vollständige Einrichtung bis zur vorgesehenen Verteilung begleiten. Nach einem erfolgreichen Teilschritt den nächsten erforderlichen Schritt ausdrücklich nennen; nicht erst auf Nachfrage auf die Production-Freigabe hinweisen.
- Verbindliche Reihenfolge für eine erste Verteilung über TestFlight:
  1. iCloud-/CloudKit-Container, Signierung und Hintergrundbenachrichtigungen prüfen.
  2. Build, automatisierte Tests und Erhalt vorhandener Daten beim Update prüfen.
  3. Auf dem Testgerät/Simulator bei iCloud anmelden, Development-Schema initialisieren und den nur dafür benötigten Startparameter anschließend entfernen.
  4. Nach erfolgreicher Initialisierung ausdrücklich zur CloudKit Console führen: richtigen Container wählen, Development-Schema prüfen und über „Deploy Schema Changes…“ nach Production übertragen. Dieser Schritt findet in der CloudKit Console statt, nicht in App Store Connect. Er überträgt die Datenstruktur, keine Development-Nutzerdaten.
  5. Den vorgesehenen Commit taggen/pushen und den Release-Build für TestFlight hochladen; Version und freie Buildnummer sowie vorhandene Release-Regeln beachten.
  6. Nach Verfügbarkeit denselben TestFlight-Build auf zwei Geräten desselben Apple-Accounts installieren und den Production-Abgleich einschließlich Änderungen, Offline-Nachholen und Löschungen prüfen.
- Zusätzliche Zwei-Geräte-Tests in Development sind vor der Übertragung sinnvoll, ersetzen aber weder die Production-Freigabe noch den Production-Test. Xcode-Debug und TestFlight nicht als ein gemeinsames Sync-Testpaar behandeln.
- „CloudKit aktiviert“, „Development schema initialized“ und erfolgreiche Unit-Tests bedeuten jeweils noch keine vollständige Production-/Sync-Abnahme. Den tatsächlichen Stand und noch offene Schritte eindeutig benennen.
- Bei späteren Modelländerungen vor jedem betroffenen Release auch erforderliche CloudKit-Schemaänderungen für Production prüfen. Diese allgemeinen Regeln bei neuen iOS-App-Repositories übernehmen.
