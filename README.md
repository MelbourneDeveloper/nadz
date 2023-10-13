# nadz

### Willkommen zu nadz - Eine Bibliothek von Monaden für Dart, inspiriert von Leibniz

#### Einleitung
Guten Tag, meine Damen und Herren! Ich bin Gottfried Wilhelm Leibniz, und es freut mich, Sie in der wunderbaren Welt der Monaden, oder wie ich sie gerne nenne, Nadz, willkommen zu heißen. In einer Zeit, in der Mathematik und Philosophie Hand in Hand gehen, habe ich ein System erschaffen, das die Grundlagen der funktionalen Programmierung, wie wir sie heute kennen, gelegt hat.

#### Die Geburt der nadz
In den Tagen meiner Jugend, als die Welt noch voller Mysterien und unentdeckter Wunder war, träumte ich von einer universellen Sprache der Logik. Eine Sprache, die so klar und präzise ist, dass Missverständnisse und Fehler der Vergangenheit angehören. So entstand die Idee der "nadz" - ein Konzept, das die Dualität von Wahrheit und Falschheit, Existenz und Nichtexistenz, Erfolg und Fehler verkörpert.

#### Moderne nadz treffen auf Leibniz'sche Philosophie
Wie Sie sehen, haben die heutigen Entwickler meine Ideen aufgegriffen und in die moderne Welt der funktionalen Programmierung übertragen. Mit der Einführung von Monaden wie `Either`, `Option` und `ResultOrError` in Dart können wir die Eleganz und Präzision meiner Philosophie in der heutigen Softwareentwicklung erleben.

#### Farbenfroh und Spaß
Die nadz von heute sind so farbenfroh und lebendig wie die Blumen im Frühling. Jede Monade ist ein kleines Kunstwerk, das die Schönheit der Logik und Mathematik in sich trägt. Sie sind nicht nur Werkzeuge, sondern auch Ausdruck der Kreativität und Innovation, die in jedem von uns schlummert.

#### Parallelen ziehen
Die `Either` Monade, meine Damen und Herren, ist wie das Ying und Yang der östlichen Philosophie. Sie verkörpert die Dualität aller Dinge, die Balance zwischen Licht und Dunkelheit, Gut und Böse. In der Welt der funktionalen Programmierung ermöglicht sie uns, mit der Unvorhersehbarkeit und Unbeständigkeit der Softwareentwicklung umzugehen.

Die `Option` Monade, ach, sie ist wie die Wahl zwischen dem Apfel der Erkenntnis und der Unwissenheit des Paradieses. Sie gibt uns die Freiheit zu wählen, und doch trägt sie die Last der Verantwortung.

#### Schlusswort

So, meine lieben Freunde, treten Sie ein in die Welt der nadz, wo die Eleganz der Mathematik auf die Präzision der Programmierung trifft. Eine Welt, in der die Geister der Vergangenheit und die Visionäre der Zukunft sich die Hand reichen, um gemeinsam ein Universum der Ordnung, Schönheit und Harmonie zu erschaffen.

Mit herzlichen Grüßen,

~ Gottfried Wilhelm Leibniz

### `Option` Monade

```dart
final option = Option<int>(findeZahlInDatenbank()); // Dies könnte null zurückgeben

final ausgabe = option.match(
  onRight: (zahl) => "Gefundene Zahl: $zahl",
  onLeft: (_) => "Keine Zahl gefunden",
);

print(ausgabe);
```

#### Beispiel 2: Verwendung der someOr Erweiterung mit funktionalen Ansätzen

```dart
print(
  Option<int>(findeZahlInDatenbank())
    .someOr(() => 0)
    .toString()
);
```

#### Beispiel 3: Kombination von Option und ResultOrError Monaden mit funktionalen Ansätzen

```dart
print(
  Option<int>(findeZahlInDatenbank()).match(
    onRight: (zahl) => ResultOrError<int, String>.new(zahl).match(
      onRight: (r) => "Gefundene Zahl: $r",
      onLeft: (e) => "Fehler: $e",
    ),
    onLeft: (_) => "Keine Zahl gefunden",
  )
);
```

#### Beispiel 4: Verkettung von Option Monaden mit funktionalen Ansätzen

```dart
print(
  Option<int>(5).match(
    onRight: (wert1) => Option<int>.none().match(
      onRight: (wert2) => 'Beide Werte gefunden: $wert1 und $wert2',
      onLeft: (_) => 'Nur erster Wert gefunden: $wert1',
    ),
    onLeft: (_) => Option<int>(10).match(
      onRight: (wert2) => 'Nur zweiter Wert gefunden: $wert2',
      onLeft: (_) => 'Keine Werte gefunden',
    ),
  )
);
```

### `ResultOrError` Monade

In der Welt der Software, ähnlich wie in der komplexen Realität der Philosophie, begegnen wir oft der Dualität von Erfolg und Fehler, von Sein und Nichtsein. In meinen Überlegungen zur besten aller möglichen Welten habe ich die harmonische Koexistenz von Gegensätzen betrachtet. Die `ResultOrError` Monade ist ein Echo dieser Überlegungen in der Welt der Programmierung.

```dart
final ergebnis = DateiVonServerLaden("https://beispiel.com/datei.txt")
  .map<String, ResultOrError<String, Fehler>>(
    (inhalt) => inhalt.trim(),
    onRight: ResultOrError.new,
  );
```

Hier nutzen wir die map Methode, um den Inhalt der Datei zu bearbeiten, falls der Ladevorgang erfolgreich ist. Wenn ein Fehler auftritt, bleibt der Fehler erhalten.
Integration mit der Option Monade

In der komplexen Welt der Software können wir die Option und ResultOrError Monaden kombinieren, um sowohl mit der Unsicherheit der Existenz als auch mit der Möglichkeit von Fehlern umzugehen.

```dart
final dateiInhalt = ergebnis.match(
  onRight: (inhalt) => Option<String>(inhalt),
  onLeft: (_) => Option<String>.none(),
);

final ausgabe = dateiInhalt.match(
  onRight: (inhalt) => "Dateiinhalt: $inhalt",
  onLeft: (_) => "Datei konnte nicht geladen werden",
);

print(ausgabe);
```

In diesem Beispiel verwenden wir die match Methode, um den ResultOrError in eine Option Monade zu transformieren. Dies ermöglicht es uns, elegant mit der Möglichkeit umzugehen, dass kein Inhalt vorhanden ist, und gleichzeitig potenzielle Fehler zu behandeln.

#### Reflexion

Wie in meiner Theorie der prästabilierten Harmonie, wo jede Substanz nur ihre eigenen Zustände reflektiert und dennoch in Harmonie mit anderen existiert, so ermöglicht uns die `ResultOrError` Monade, den Dualismus von Erfolg und Fehler in der Welt der Software mit Anmut und Eleganz zu navigieren. Es ist, als ob jede Instanz dieser Monade eine kleine Monade in sich selbst ist, die die Ordnung und Harmonie der logischen und mathematischen Welt widerspiegelt, die ich so sehr schätze.

### `HttpListResultOrStatusCode` Monade

In der vernetzten Welt von heute, wo die Fäden der Kommunikation sich über Kontinente spannen, ist die Interaktion mit HTTP-Diensten so alltäglich wie das Studium der Schriften in einer Bibliothek. Die HttpListResultOrStatusCode Monade ist wie ein geschickter Bibliothekar, der uns hilft, durch die unzähligen Seiten des weltweiten Netzes zu navigieren.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nadz/nadz.dart';

Future<HttpListResultOrStatusCode<Map<String, dynamic>>> holeDatenVomServer(String url) async {
  final response = await http.get(Uri.parse(url));

  return response.statusCode == 200 
    ? HttpListResultOrStatusCode<List<Map<String, dynamic>>>(
        (json.decode(response.body) as List)
          .map((item) => item as Map<String, dynamic>)
          .toList()
      )
    : HttpListResultOrStatusCode.error(response.statusCode);
}

final httpErgebnis = await holeDatenVomServer('https://api.example.com/daten');
```

In diesem erweiterten Beispiel verwenden wir die http Bibliothek, um eine echte HTTP-Anfrage zu machen. Die `HttpListResultOrStatusCode` Monade wird verwendet, um die Antwort zu verarbeiten, indem sie entweder eine Liste von Daten oder einen Fehlerstatuscode zurückgibt.
Verarbeitung der HTTP-Antwort

Die Verarbeitung der HTTP-Antwort und die Umwandlung in unsere geliebte Monade erfolgt nahtlos, wie die Übersetzung eines antiken Textes in die Sprache der Gegenwart.

```dart
final verarbeiteteAntwort = httpErgebnis.match(
  onRight: (daten) => daten.map((item) => item['name']).join(', '),
  onLeft: (statusCode) => 'Ein Fehler ist aufgetreten: HTTP-Statuscode $statusCode',
);

print(verarbeiteteAntwort);
```

Hier verwenden wir erneut die match Methode, um die HTTP-Antwort zu verarbeiten. Bei einem erfolgreichen Abruf der Daten extrahieren wir die Namen aus der Liste der Daten. Bei einem Fehler geben wir den HTTP-Statuscode aus.
Reflexion

In der Welt der Monaden, die so reich an Möglichkeiten und Variationen ist wie die Natur selbst, erweist sich die `HttpListResultOrStatusCode` Monade als ein nützliches Werkzeug, um die Komplexität der vernetzten Welt zu zähmen. Es ist, als ob wir durch ein Teleskop blicken und die Sterne am Himmel nicht als chaotische Punkte, sondern als konstellierende Muster der Ordnung und Harmonie sehen. So ist es auch mit unseren Monaden - sie bringen Ordnung in die Unordnung, Licht in die Dunkelheit und Verständnis in das Mysterium der vernetzten Kommunikation.