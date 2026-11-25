# Allgemeine Projektregeln

## Zusammenarbeit

- Bei Ideen, Einschätzungen und Plänen zuerst einen konkreten Vorschlag machen und auf mein Okay warten. Einen ausdrücklich erteilten Änderungsauftrag direkt umsetzen. Zusätzliche Vorhaben wie Skripte oder einen Wechsel des Arbeitsablaufs vorher abstimmen.
- Vor Änderungen den aktuellen Stand und die vorhandene Projektdokumentation prüfen. Den Auftrag mit einer möglichst kleinen, vollständigen Änderung umsetzen.
- Bestehende Daten, Konfigurationen und Arbeitsabläufe erhalten. Änderungen an Datenmodellen oder Dateiformaten auch mit Bestandsdaten und älteren Formaten prüfen.
- Für Tests synthetische oder anonymisierte Daten verwenden. Zugangsdaten, echte Bankexporte und private Buchungsdaten aus dem Repository heraushalten.
- Den betroffenen Ablauf gezielt prüfen. Bei der Übergabe festhalten, was getestet wurde und was noch offen ist.

## Versionierung

- Verwende `MAJOR.MINOR.PATCH`, bei separater Buildnummer `MAJOR.MINOR.PATCH (BUILD)`.
- Erhöhe bei jeder abgeschlossenen Änderung die Projektversion. Inkompatible Änderungen erhöhen Major, neue Funktionen mindestens Minor. Fehlerkorrekturen und kosmetische Änderungen erhöhen Patch.
- Wenn eine Änderung im Test noch nicht wie gewünscht funktioniert, frage vor der Nachbesserung, ob wir dieselbe Version beibehalten oder erhöhen sollen. Nachbesserungen bis zur Abnahme können nach Absprache dieselbe Version behalten.
- Erhöhe die Buildnummer für einen neuen Upload, wenn der bisherige Build bereits erfolgreich hochgeladen wurde. Die Buildnummer ist unabhängig von der Projektversion.
- Halte die Versionsangaben in den vorgesehenen Projektdateien und im Changelog konsistent. Git-Release-Tags heißen `vMAJOR.MINOR.PATCH`.

- Nenne bei jeder abgeschlossenen Änderung in der Übergabe ausdrücklich die interne Projektversion und bei Apps mit separater externer Version auch die vorgesehene externe Version samt Buildnummer (z. B. intern `v1.7.2` → extern `1.0.1 (20)`). Kennzeichne die Buildnummer als geplant, solange der Upload nicht bestätigt ist; prüfe vor dem Upload, ob sie noch frei ist. Bei reinen Dokumentations- oder Website-Änderungen ohne Versionswechsel nenne den unveränderten Stand.

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
