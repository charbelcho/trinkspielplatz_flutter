import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/deck_utils.dart';
import 'package:trinkspielplatz/flip_card.dart';
import 'package:trinkspielplatz/logger.dart';
import 'package:trinkspielplatz/model/cards_class.dart';
import 'package:trinkspielplatz/model/room_class.dart';
import 'package:trinkspielplatz/model/spieler_class.dart';
import 'package:trinkspielplatz/notify.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Busfahrer extends StatefulWidget {
  const Busfahrer({Key? key})
      : super(key: key);

  @override
  State<Busfahrer> createState() => _BusfahrerState();
}

class _BusfahrerState extends State<Busfahrer>
    with TickerProviderStateMixin, RouteAware {
  late List<AnimationController> animationControllers;
  late List<AnimationController> animationReverseControllers;

  bool loading = true;
  int n = 0;
  List<Cards> deck = [];

  String name = '';
  String nameEingabe = '';
  String raumIdEingabe = '';
  RoomBusfahrer roomBusfahrer =
      RoomBusfahrer(roomId: '', deck: [], spieler: [], phase: 1);

  List<bool> flipArray = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  List<int> trinkzahlArray = [0, 0, 0];
  List<int> meineKarten = [0, 0, 0];
  String busfahrer = '';
  bool isBusfahrerDialogOpen = false;
  bool? correct;
  int correctInRow = 0;

  // Todo:
  int phase = 1;

  bool connectionFailed = false;
  late io.Socket socket;

  void connectToServer() {
    if (Platform.isIOS) {
      // iOS-Verbindung zu Socket-Server.
      // socket = io.io("ws://localhost:8001"
      // "wss://socket-ios-backend-busfahrer.herokuapp.com"
      socket = io.io(
          "wss://socket-ios-backend-busfahrer.herokuapp.com", <String, dynamic>{
        "transports": ["websocket"],
        "forceNew": true
      });
    } else if (Platform.isAndroid) {
      // Android-Verbindung zu Socket-Servers.
      socket = io.io(
          "wss://socket-ios-backend-busfahrer.herokuapp.com", <String, dynamic>{
        "transports": ["websocket"],
        "forceNew": true
      });
    } else {
      socket = io.io(
          "wss://socket-ios-backend-busfahrer.herokuapp.com", <String, dynamic>{
        "transports": ["websocket"],
        "forceNew": true
      });
    }

    socket.onConnect((_) {
      setState(() {
        loading = false;
        connectionFailed = false;
      });
      _showDialogName(context);
      logger.e('Verbunden');
    });

    socket.onConnectError((_) {
      setState(() {
        loading = false;
        connectionFailed = true;
      });
    });

    socket.onError((_) {
      setState(() {
        loading = false;
        connectionFailed = true;
      });
    });

    socket.onDisconnect((_) {
      logger.e('Getrennt');
    });

    // Hör auf Ereignisse vom Server und reagiere entsprechend.
    socket.on('loading', (data) {
      setState(() {
        loading = true;
      });
    });

    socket.on('busfahrerUsername', (data) {
      setState(() {
        name = data;
        loading = false;
      });
    });

    socket.onConnectError((err) => logger.e(err));
    socket.onError((err) => logger.e(err));

    socket.on('roomBusfahrer', (data) {
      if (deck.isEmpty) {
        for (var card in data['deck']) {
          Cards cards = Cards.fromJson(card); // Create a Cards object from JSON
          deck.add(cards); // Add the Cards object to the list
        }
      }

      RoomBusfahrer dataRoomBusfahrer = RoomBusfahrer(
          roomId: data['roomId'],
          deck: deck,
          spieler: [],
          phase: data['phase']);
      var spielerListe = data['spieler'];

      for (var spieler in spielerListe) {
        String id = spieler['id'];
        String name = spieler['name'];
        var busfahrerEigeneKartenListe = List<int>.from(spieler['karten']);
        var busfahrerFlipArray = List<bool>.from(spieler['flipArray']);

        SpielerBusfahrer spielerBusfahrer = SpielerBusfahrer(
            id: id,
            name: name,
            eigeneKarten: busfahrerEigeneKartenListe,
            flipArray: busfahrerFlipArray);
        dataRoomBusfahrer.spieler.add(spielerBusfahrer);
      }
      setState(() {
        roomBusfahrer = dataRoomBusfahrer;
        loading = false;
      });
    });

    socket.on('roomBusfahrerAfterLeave', (data) {
      List<SpielerBusfahrer> spielerListe = [];

      for (var spieler in data) {
        String id = spieler['id'];
        String name = spieler['name'];
        var busfahrerEigeneKartenListe = List<int>.from(spieler['karten']);
        var busfahrerFlipArray = List<bool>.from(spieler['flipArray']);

        SpielerBusfahrer spielerBusfahrer = SpielerBusfahrer(
            id: id,
            name: name,
            eigeneKarten: busfahrerEigeneKartenListe,
            flipArray: busfahrerFlipArray);
        spielerListe.add(spielerBusfahrer);
      }
      setState(() {
        roomBusfahrer.spieler = spielerListe;
      });
    });

    socket.on('meineKarten', (data) {
      setState(() {
        meineKarten = List<int>.from(data);
      });
    });

    socket.on('keinRaumGefundenBusfahrer',
        (data) => {notify.notifyError(context, 'Kein Raum gefunden')});

    socket.on('roomFullBusfahrer',
        (data) => {notify.notifyError(context, 'Raum bereits voll')});

    socket.on('nameBesetztBusfahrer',
        (data) => {notify.notifyError(context, 'Name bereits vergeben')});

    socket.on('spielLaeuft',
        (data) => {notify.notifyError(context, 'Spiel findet bereits statt')});

    socket.on(
        'closeModal',
        (data) => {
              Navigator.pop(context),
              notify.notifySuccess(context, 'Raum beigetreten')
            });

    socket.on(
        'busfahrerBestimmen',
        (data) => {
              busfahrer = data,
              setState(() {
                isBusfahrerDialogOpen = true;
                loading = false;
              }),
              _showDialogBusfahrer(context),
              Future.delayed(const Duration(seconds: 15), () {
                if (isBusfahrerDialogOpen && !_ersteller()) {
                  roomBusfahrer.phase = 1;
                  _resetGameInfo();
                  Navigator.pop(context);

                  setState(() {
                    isBusfahrerDialogOpen = false;
                  });
                }
              })
            });

    socket.on(
        'gedrehteKarte', (data) => {_flipCard(data['index'], data['row'])});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      connectToServer();
    });

    animationControllers = List.generate(
      15,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      ),
    );

    for (var controller in animationControllers) {
      controller.value = 1.0;
    }

    animationReverseControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    // Schließe die Socket-Verbindung, wenn die App geschlossen oder die Seite gewechselt wird.
    socket.disconnect();
    socket.dispose();
    socket.destroy();

    for (var controller in animationControllers) {
      controller.dispose();
    }
    for (var controllerReverse in animationReverseControllers) {
      controllerReverse.dispose();
    }
    super.dispose();
  }

  void _showDialogSpielVerlassen(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Spiel verlassen?'),
          content: const Text(
              'Bist du sicher? Dein Spielstand wird nicht gespeichert'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                socket.disconnect();
                setState(() {
                  name = '';
                  nameEingabe = '';
                  raumIdEingabe = '';
                  roomBusfahrer = RoomBusfahrer(
                      roomId: '', deck: [], spieler: [], phase: 1);
                  connectionFailed = false;
                });
                _resetGameInfo();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (Route<dynamic> route) => false);
              },
              child: const Text(
                'Verlassen',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialogName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Check for input and prevent dismissal if no input is given
            /* if (nameEingabe.isEmpty) {
              return false;
            }
            socket.emit("usernameBusfahrer", nameEingabe); */
            setState(() {
              nameEingabe = '';
            });
            Navigator.pop(context);
            return true;
          },
          child: AlertDialog(
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  nameEingabe = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Name eingeben...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (nameEingabe.isNotEmpty) {
                    socket.emit("usernameBusfahrer", nameEingabe);
                    setState(() {
                      nameEingabe = '';
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialogRaumBeitreten(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() {
                raumIdEingabe = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'RaumID',
              hintText: 'RaumID eingeben...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (raumIdEingabe.isNotEmpty) {
                  socket.emit("joinRoomBusfahrer",
                      {'roomId': raumIdEingabe, 'name': name});
                  // Handle action on button press
                  //Navigator.pop(context);
                }
              },
              child: const Text('Beitreten'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogBusfahrer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            content: Text('$busfahrer ist Busfahrer'),
            actions: [
              TextButton(
                onPressed: () {
                  if (_ersteller()) {
                    setState(() {
                      deck.shuffle();
                      roomBusfahrer.phase = 3;
                      isBusfahrerDialogOpen = false;
                    });
                  } else {
                    setState(() {
                      roomBusfahrer.phase = 1;
                      _resetGameInfo();
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text(_ersteller() ? 'Busfahren' : 'Zum Start'),
              )
            ],
          ),
        );
      },
    );
  }

  void _showDialogRaumVerlassen(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Raum verlassen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                _raumVerlassen();
                Navigator.pop(context);
              },
              child: const Text(
                'Verlassen',
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        );
      },
    );
  }

  void _karteDrehen(int index, int row) {
    if (_ersteller()) {
      if (flipArray[index] == false) {
        if (index == 0) {
          socket.emit('karteDrehen',
              {'roomId': roomBusfahrer.roomId, 'index': index, 'row': row});
        } else if (index > 0 && flipArray[index - 1]) {
          socket.emit('karteDrehen',
              {'roomId': roomBusfahrer.roomId, 'index': index, 'row': row});
        }
      }
    }
  }

  void _flipCard(int i, int row) {
    if (flipArray[i] == false) {
      if ((i == 0) || (i > 0 && flipArray[i - 1])) {
        setState(() {
          flipArray[i] = true;
          animationControllers[i].reverse();
        });
        _checkIfValueInMyCards(roomBusfahrer.deck[i].value, row);
      }
    }
  }

  void _checkIfValueInMyCards(int value, int row) {
    for (int i = 0; i < meineKarten.length; i++) {
      if (roomBusfahrer.deck[meineKarten[i]].value == value) {
        setState(() {
          animationReverseControllers[i].forward();
          //myCardsFlipArray[i] = true;
          if (trinkzahlArray[i] == 0) {
            trinkzahlArray[i] = row;
          }
        });
      }
    }
  }

  bool _ersteller() {
    if (roomBusfahrer.spieler.isNotEmpty) {
      if (roomBusfahrer.spieler.first.name == name) {
        return true;
      }
    }
    return false;
  }

  void _correctFunc() {
    correct = true;
    correctInRow += 1;
  }

  void _notCorrectFunc() {
    correct = false;
    correctInRow = 0;
  }

  void _hoeher() {
    setState(() {
      if (n < deck.length - 1) {
        n++;
        if (deck[n - 1].value < deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      } else {
        int value = deck[n].value;
        n = 0;
        deck.shuffle();
        if (value < deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      }
    });
  }

  void _gleich() {
    setState(() {
      if (n < deck.length - 1) {
        n++;
        if (deck[n - 1].value == deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      } else {
        int value = deck[n].value;
        n = 0;
        deck.shuffle();
        if (value == deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      }
    });
  }

  void _tiefer() {
    setState(() {
      if (n < deck.length - 1) {
        n++;
        if (deck[n - 1].value > deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      } else {
        int value = deck[n].value;
        n = 0;
        deck.shuffle();
        if (value > deck[n].value) {
          _correctFunc();
        } else {
          _notCorrectFunc();
        }
      }
    });
  }

  void _raumVerlassen() {
    if (roomBusfahrer.roomId.isNotEmpty && roomBusfahrer.spieler.isNotEmpty) {
      List<SpielerBusfahrer> einSpielerList = roomBusfahrer.spieler
          .where((einSpieler) => einSpieler.name == name)
          .toList();

      socket.emit('leaveBusfahrer', {
        'roomId': roomBusfahrer.roomId,
        'spielerId': einSpielerList.first.id
      });
      setState(() {
        roomBusfahrer =
            RoomBusfahrer(roomId: '', deck: [], spieler: [], phase: 1);
      });
      _resetGameInfo();
    }
  }

  void _resetGameInfo() {
    setState(() {
      n = 0;
      deck = [];

      flipArray = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ];

      trinkzahlArray = [0, 0, 0];
      meineKarten = [0, 0, 0];

      busfahrer = '';
      correct = null;
      correctInRow = 0;

      isBusfahrerDialogOpen = false;

      animationControllers = List.generate(
        15,
        (index) => AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        ),
      );

      for (var controller in animationControllers) {
        controller.value = 1.0;
      }

      animationReverseControllers = List.generate(
        3,
        (index) => AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  List<Widget> createMeineKarten() {
    List<Widget> widgetList = [
      const Text("Meine\nKarten:"),
      const SizedBox(height: 10.0),
    ];

    for (int i = 0; i < 3; i++) {
      widgetList.add(
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 40,
              child: FlipCardReverse(
                animationReverseController: animationReverseControllers[i],
                frontChild: Image.asset(
                    'images/cards/${deck.isNotEmpty ? deck[meineKarten[i]].card : 'herz2'}.png'),
              ),
            ),
            Text(
              '${trinkzahlArray[i] > 0 ? trinkzahlArray[i] : ''}',
              style: const TextStyle(fontSize: 25),
            )
          ],
        ),
      );
    }

    return widgetList;
  }

  List<Widget> createCardRow(int startIndex, int endIndex, int row) {
    List<Widget> widgetList = [];

    for (int i = startIndex; i <= endIndex; i++) {
      widgetList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: SizedBox(
              height: 60,
              width: 40,
              child: FlipCard(
                animationController: animationControllers[i],
                frontChild: Image.asset(
                    'images/cards/${deck.isNotEmpty ? deck[i].card : 'herz2'}.png'),
                onButtonPressed: _karteDrehen,
                index: i,
                row: row,
              )),
        ),
      );
    }

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double varFontSize;
    /* double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight;
    double cardWidth; */

    // Calculate font size based on screen width
    if (screenWidth < 300) {
      varFontSize = 12.0;
    } else if (screenWidth < 325) {
      varFontSize = 13.0;
    } else if (screenWidth < 350) {
      varFontSize = 14.0;
    } else if (screenWidth < 375) {
      varFontSize = 15.0;
    } else if (screenWidth < 400) {
      varFontSize = 16.0;
      //cardWidth = 40;
    } else {
      varFontSize = 18.0;
    }

    /* if (screenHeight > 800) {
      cardHeight = 60;
    } else if (screenHeight > 750) {
      cardHeight = 58;
    } else if (screenHeight > 700) {
      cardHeight = 56;
    } */

    return Stack(
      children: [
        Scaffold(
            backgroundColor: colors.bluegray,
            appBar: AppBar(
                title: const Text("Busfahrer"),
                leading: IconButton(
                  icon: const Icon(Icons
                      .arrow_back_ios_new_rounded), // Replace with your custom icon
                  onPressed: () {
                    // Define the behavior when the custom back button is pressed
                    _showDialogSpielVerlassen(context);
                  },
                ),
                centerTitle: true,
                backgroundColor: colors.teal,
                foregroundColor: Colors.black,
                actions: [
                  AnleitungenButton()
                  // You can add more icons here if needed
                ]),
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.28),
                            color: colors.teal,
                            onPressed: () {
                              if (name.isNotEmpty &&
                                  roomBusfahrer.roomId.isEmpty) {
                                socket.emit("createRoomBusfahrer", name);
                              }
                            },
                            enabled:
                                name.isNotEmpty && roomBusfahrer.roomId.isEmpty,
                            child: const Text(strings.rErstellen)),
                        AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.28),
                            color: colors.teal,
                            onPressed: () {
                              if (name.isNotEmpty &&
                                  roomBusfahrer.roomId.isEmpty) {
                                _showDialogRaumBeitreten(context);
                              }
                            },
                            enabled:
                                name.isNotEmpty && roomBusfahrer.roomId.isEmpty,
                            child: const Text(strings.rBeitreten)),
                        AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.28),
                            color: colors.red,
                            onPressed: () {
                              _showDialogRaumVerlassen(context);
                            },
                            enabled: name.isNotEmpty &&
                                roomBusfahrer.roomId.isNotEmpty,
                            child: const Text(
                              strings.rVerlassen,
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                    Expanded(
                      child: Container(
                        //height: 480,
                        margin: const EdgeInsets.only(top: 10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: const BorderSide(
                                    width: 10, color: colors.teal))),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Name: "),
                                    SizedBox(height: 5.0),
                                    Text("RaumID: "),
                                    SizedBox(height: 5.0),
                                    Text("Ersteller: ")
                                  ]),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name),
                                      const SizedBox(height: 5.0),
                                      Text(roomBusfahrer.roomId),
                                      const SizedBox(height: 5.0),
                                      Text(roomBusfahrer.spieler.isNotEmpty
                                          ? roomBusfahrer.spieler.first.name
                                          : '')
                                    ]),
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Opacity(
                                      opacity: roomBusfahrer.roomId.isEmpty
                                          ? 1.0
                                          : 0.0,
                                      child: TextButton(
                                          child: const Text("Name\nbearb."),
                                          onPressed: () {
                                            if (roomBusfahrer.roomId.isEmpty) {
                                              _showDialogName(context);
                                            }
                                          }),
                                    )
                                  ]),
                            ]),
                            const Divider(
                              thickness: 1.0,
                            ),
                            Visibility(
                              visible: roomBusfahrer.phase == 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var einSpieler in roomBusfahrer.spieler)
                                    Column(
                                      children: [
                                        Text(
                                          einSpieler.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(height: 5.0),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: roomBusfahrer.phase == 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: createMeineKarten(),
                                  ),
                                  Column(
                                    children: [
                                      Row(children: createCardRow(14, 14, 5)),
                                      Row(children: createCardRow(12, 13, 4)),
                                      Row(children: createCardRow(9, 11, 3)),
                                      Row(children: createCardRow(5, 8, 2)),
                                      Row(children: createCardRow(0, 4, 1)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Visibility(
                                  visible: roomBusfahrer.phase == 3 &&
                                      correctInRow <= 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: roomBusfahrer.phase == 3 &&
                                      correctInRow < 5 ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text("Busfahrer: $busfahrer",
                                                  style: TextStyle(
                                                      fontSize: varFontSize)),
                                              AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  transitionBuilder:
                                                      (child, animation) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                                  child: Container(
                                                    key: ValueKey<int>(
                                                        deck.isNotEmpty
                                                            ? deck[n].id
                                                            : 0),
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.23,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.4), // Shadow color and opacity
                                                          spreadRadius:
                                                              2, // How far the shadow spreads
                                                          blurRadius:
                                                              5, // The blur radius of the shadow
                                                          offset: const Offset(0,
                                                              3), // Offset of the shadow (x, y)
                                                        ),
                                                      ],
                                                    ),
                                                    child: Image.asset(
                                                        'images/cards/${deck.isNotEmpty ? deck[n].card : 'herz2'}.png')
                                                  )),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      AnimatedSwitcher(
                                                        duration: const Duration(
                                                            milliseconds: 400),
                                                        transitionBuilder:
                                                            (child, animation) {
                                                          return FadeTransition(
                                                              opacity: animation,
                                                              child: child);
                                                        },
                                                        child: Opacity(
                                                            key:
                                                                ValueKey(correct),
                                                            opacity:
                                                                correct != null
                                                                    ? 1.0
                                                                    : 0.0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10.0),
                                                              decoration:
                                                                  ShapeDecoration(
                                                                      color: correct ==
                                                                              true
                                                                          ? correct ==
                                                                                  false
                                                                              ? Colors
                                                                                  .transparent
                                                                              : colors
                                                                                  .green
                                                                          : colors
                                                                              .red,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25.0))),
                                                              child: Text(
                                                                  correct == true
                                                                      ? correct ==
                                                                              false
                                                                          ? ''
                                                                          : 'Richtig'
                                                                      : 'Falsch',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          varFontSize)),
                                                            )),
                                                      ),
                                                      AnimatedSwitcher(
                                                        duration: const Duration(
                                                            milliseconds: 400),
                                                        transitionBuilder:
                                                            (child, animation) {
                                                          return FadeTransition(
                                                              opacity: animation,
                                                              child: child);
                                                        },
                                                        child: Text(
                                                            "Richtig in Folge: $correctInRow",
                                                            // This key causes the AnimatedSwitcher to interpret this as a "new"
                                                            // child each time the count changes, so that it will begin its animation
                                                            // when the count changes.
                                                            key: ValueKey<int>(
                                                                correctInRow),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    varFontSize)),
                                                      ),
                                                    ]),
                                              ),
                                            ],
                                          ) : const Text('Spiel beendet!', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w600, color: Colors.black)),
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          ],
                        )),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if(!(_ersteller() &&
                          roomBusfahrer.phase == 3 &&
                          correctInRow < 5))
                    Opacity(
                      opacity: (_ersteller() && roomBusfahrer.phase != 3) ||
                          (_ersteller() &&
                              roomBusfahrer.phase == 3 &&
                              correctInRow == 5) ? 1 : 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.95),
                              color: colors.teal,
                              /* enabled:
                                  (roomBusfahrer.phase == 2 && !flipArray[14]), */
                              onPressed: () {
                                if (roomBusfahrer.phase == 1) {
                                  List<Cards> deck = createDeck();
                                  deck.shuffle();
                                  socket.emit('austeilen', {
                                    'roomId': roomBusfahrer.roomId,
                                    'deck': jsonEncode(deck)
                                  });
                                } else if (roomBusfahrer.phase == 2 &&
                                    flipArray[14]) {
                                  socket.emit("busfahren",
                                      {'roomId': roomBusfahrer.roomId});
                                } else if (roomBusfahrer.phase == 3) {
                                  setState(() {
                                    roomBusfahrer.phase == 1;
                                  });
                                  socket.emit("zumStart",
                                      {'roomId': roomBusfahrer.roomId});
                                  _resetGameInfo();
                                }
                              },
                              child: Text(roomBusfahrer.phase == 1
                                  ? strings.austeilen
                                  : roomBusfahrer.phase == 2
                                      ? strings.busfahren
                                      : strings.zumStart)),
                        ],
                      ),
                    ),
                    if(_ersteller() &&
                          roomBusfahrer.phase == 3 &&
                          correctInRow < 5)
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.28),
                              color: colors.teal,
                              onPressed: () {
                                _hoeher();
                              },
                              child: const Icon(Icons.arrow_upward)),
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.28),
                              color: colors.teal,
                              onPressed: () {
                                _gleich();
                              },
                              child: const Text("=",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                  ))),
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.28),
                              color: colors.teal,
                              onPressed: () {
                                _tiefer();
                              },
                              child: const Icon(Icons.arrow_downward))
                        ],
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AdScreen(),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        if (loading)
          Container(
            color:
                Colors.black.withOpacity(0.3), // Background color with opacity
            child: const Center(
              child:
                  CircularProgressIndicator(), // Replace with your overlay content
            ),
          ),
        if (connectionFailed)
          Container(
            color:
                Colors.black.withOpacity(0.3), // Semi-transparent overlay color
            child: Center(
              child: Stack(
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, decoration: null),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            'Verbindung fehlgeschlagen.\nErneuter Versuch?'),
                        const SizedBox(height: 16.0),
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              loading = true;
                              connectionFailed = false;
                            });
                            Future.delayed(const Duration(seconds: 3), () {
                              connectToServer();
                            });
                          },
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: const Icon(
                            Icons.autorenew,
                            size: 45,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text('Oder zurück zum Start'),
                        const SizedBox(height: 16.0),
                        AnimatedButton(
                            color: colors.teal,
                            onPressed: () {
                              setState(() {
                                name = '';
                                nameEingabe = '';
                                raumIdEingabe = '';
                                roomBusfahrer = RoomBusfahrer(
                                    roomId: '',
                                    deck: [],
                                    spieler: [],
                                    phase: 1);
                                connectionFailed = false;
                              });
                              _resetGameInfo();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Zurück',
                                style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
