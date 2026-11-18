# Trainuvo – Aufgaben und Testbefunde

Neue und zurückgestellte Einträge stehen unter **Open**. Umgesetzte Einträge stehen unter **Done** mit der internen Trainuvo-Version. Ausstehende Prüfungen stehen beim jeweiligen Eintrag.

## Open

### t19 – Export als JSON, Excel und formatierten Text (Prio 2)

- Trainingsdaten als JSON und Excel exportieren.
- Gut lesbaren, „pretty formatted“ Text zum Kopieren und Einfügen in OneNote exportieren.

### t05 – Trainingsdaten per iCloud synchronisieren (Prio 3)

- Übungen, Trainingsdaten und Ziele über iCloud synchronisieren, damit sie auf mehreren Geräten verfügbar sind.

### t24 – Zweisprachigkeit Deutsch und Englisch (Prio 3)

- App-Oberfläche, Hilfe und Fehlermeldungen auf Deutsch und Englisch bereitstellen.

### t26 – Ziele löschen und Trainings erhalten (Prio 3)

- Ziele entfernen können, wobei die zugehörigen Trainings erhalten bleiben.

### t27 – Kommentar für den gesamten Trainingstag (Prio 3)

- Einen gemeinsamen Kommentar für das Training an einem Tag eingeben und anzeigen können.
- Fachlich gilt der Kommentar für den ganzen Tag mit allen Übungen.
- Technische Option von Florian: Den Kommentar bei einem Übungseintrag speichern und dafür beispielsweise die letzte Übung des Tages verwenden. Die konkrete Umsetzung ist noch offen.

## Done

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
