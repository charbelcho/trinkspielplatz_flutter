import 'package:flutter/material.dart';

class AnleitungenButton extends StatelessWidget {
  final Map<String, String> spieleAnleitungen = {
    'Ich hab noch nie':
        """Ein Spieler liest die angezeigte Frage vor. Alle Spieler, die die Frage mit "ja, habe ich schon mal" beantworten können, trinken einen Schluck.""",
    'Wer würde eher?':
        """Ein Spieler liest die angezeigte Frage vor. Die Spieler überlegen auf wen der Mitspieler die Frage am ehesten zutrifft. Sie zeigen auf den jeweiligen Spieler und dieser trinkt die Anzahl an Schlucken von seinem Drink. Jeder kann auf einen beliebigen Spieler zeigen.""",
    'Wahrheit oder Pflicht?':
        """Der Spieler an der Reihe entscheidet sich zwischen Wahrheit oder Pflicht und tippt auf das Feld. Beantwortet die Person die Frage oder macht die Aufgabe, darf ein Schluck vergeben werden. Wird es nicht gemacht tippt man auf den Bier-Button und trinkt die angezeigte Anzahl an Schlucken.""",
    'Höher oder Tiefer?':
        """Der Spieler an der Reihe entscheidet, ob die nächste Karte höher, gleich oder tiefer ist, als die angezeigte Karte. Ist der Versuch falsch muss der Spieler einen Schluck trinken. Er oder sie rät so oft, bis 3 Versuche in Folge richtig sind. Dann ist der nächste Spieler dran. Wird bei einem Versuch 'Gleich' ausgewählt und dieser ist richtig, trinken alle anderen Spieler ihr Getränk auf ex.""",
    'BANG!':
        """Der Spieler, der verliert trinkt die angezeigte Anzahl an Schlucken. Der Spieler, der zu früh schießt, trinkt die angezeigt Anzahl an Schlucken.""",
    'Captain Shithead!':
        """Der Reihe um zieht jeder Spieler eine Karte und erfüllt die Aufgabe. Der Spieler der Captain Shithead ist, darf sich Regeln überlegen solange bis jemand anderes Captain Shithead ist.""",
    'Pferderennen':
        """Die Spieler tragen sich beim Start ein und wetten ihre Schlucke auf eine Farbe. Die gewettete Schluckanzahl muss von dem Spieler selbst getrunken werden. Dann werden die Karten gezogen. Wenn ein Spieler eine Strafe bekommt, wird es in einer Meldung angezeigt.""",
    'King\'s Cup':
        """Der Reihe um zieht jeder Spieler eine Karte und erfüllt die Aufgabe.""",
    'Wer bin ich?':
        """Du kannst eine Gruppe erstellen oder einer Gruppe beitreten. Um einer Gruppe beitreten, gib die Raum-ID einer Gruppe ein und bestätige. Wenn du der Ersteller einer Gruppe bist, kannst du auswählen, ob zufällig Personen für die Spieler zugeteilt werden oder die Spieler sich untereinander Personen zuteilen können. Danach kann der erste Spieler anfangen Ja-Nein-Fragen zu tellen, um seine zugeteilte Person zu erreaten. Wird eine Frage mit Ja beantwortet, kann der Spieler eine weitere Frage stellen. Wird eine Frage mit Nein beantwortet, trinkt der Spieler 2 Schlucke und der nächste Spieler ist an der Reihe.""",
    'Busfahrer':
        """Du kannst eine Gruppe erstellen oder einer Gruppe beitreten. Um einer Gruppe beitreten, gib die Raum-ID einer Gruppe ein und bestätige. Wenn du der Ersteller einer Gruppe bist, kannst du die Karten austeilen. Danach kannst du als Ersteller die Karten einzeln umdrehen. Ist eine aufgedrehte Karte in den Karten eines Spielers enthalten, dreht sich die Karte des Spielers automatisch um und er kann die Anzahl an Schlucken auf dem Kartenrücken verteilen. Sind alle Karten aufgedeckt, kann der Busfahren-Button gedrückt werden. Der Spieler mit den meisten offenen Karten ist Busfahrer. Auf dem Handy des Erstellers muss der Busfahrer dann "Busfahren". Immer wenn der Busfahrer einen Fehler macht muss er trinken. Wenn der Busfahrer 5 Mal richtig lag, ist das Spiel vorbei.""",
    'Mäxchen':
        """Der erste Spieler fängt an zu würfeln. Er sagt den Wert des Wurfes an und darf dabei auch lügen. Danach gibt er das Handy an den nächsten Spieler. Dieser wählt ob er dem Vorspieler glaubt oder nicht. Glaubt er ihm, würfelt er ohne den Wert des Wurfes vom Vorspieler zu kennen. Egal was er würfelt, sein angesagter Wert muss höher sein als der zuvor angesagte, er kann auch lügen. Wenn er ihm nicht glaubt, deckt er mit "Stimmt nicht" die Würfel auf. Stimmt der angesagte Wert nicht, muss der Vorspieler den Bier-Button tippen und die Anzahl an Schlucken trinken, stimmt der angesagte Wert aber doch, muss der Spieler selbst den Bier-Button tippen und die Anzahl an Schlucken trinken. Die Runde ist fertig wenn ein Spieler glaubt dass sein Vorspieler gelogen hat oder keine Wertsteigerung mehr möglich ist. Der Gewinner der Runde beginnt die nächste.""",
    '100':
        """Füge die Spieler hinzu. Der erste Spieler fängt an zu würfeln. Er kann so lange Würfeln wie er möchte, die Punkte werden zusammen gezählt. Er kann jederzeit seinen Punktestand speichern. Dann ist der nächste Spieler dran. Würfelt der Spieler eine 6 fällt er auf seinen zuletzt gespeicherten Punkestand zurück. Ein Spieler hat gewonnen sobald er 100 oder mehr Punkte gesammelt hat. Bei einer 6 muss der Spieler die angezeigte Anzahl an Schlucken trinken. Bei einer 1 trinken die anderen Spieler die angezeigte Anzahl an Schlucken."""
  };

  AnleitungenButton({super.key});

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Anleitungen:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[0],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[0]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[1],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[1]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[2],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[2]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[3],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[3]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[4],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[4]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[5],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[5]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[6],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[6]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[7],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[7]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[8],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[8]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[9],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[9]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[10],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[10]]!
                    ]),
                buildExpansionTile(
                    title: spieleAnleitungen.keys.toList()[11],
                    children: [
                      spieleAnleitungen[spieleAnleitungen.keys.toList()[11]]!
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }

  ExpansionTile buildExpansionTile(
      {required String title, required List<String> children}) {
    return ExpansionTile(
      title: Text(title),
      children: children
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(item),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline), // Icon to be displayed
      onPressed: () {
        _showBottomSheet(context);
      },
    );
  }
}
