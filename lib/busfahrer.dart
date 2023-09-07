import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_flutter_project/deck_utils.dart';
import 'package:my_flutter_project/flip_card.dart';
import 'package:my_flutter_project/model/cards_class.dart';
import 'package:my_flutter_project/model/room_class.dart';
import 'package:my_flutter_project/model/spieler_class.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;

class Busfahrer extends StatefulWidget {
  const Busfahrer({Key? key}) : super(key: key);

  @override
  _BusfahrerState createState() => _BusfahrerState();
}

class _BusfahrerState extends State<Busfahrer> with TickerProviderStateMixin {
  late List<AnimationController> animationControllers;
  late List<AnimationController> animationReverseControllers;

  int n = 0;
  List<Cards> deck = [];
  bool loading = false;

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
  //List<bool> myCardsFlipArray = [false, false, false];
  List<int> trinkzahlArray = [0, 0, 0];
  List<int> meineKarten = [0, 0, 0];
  String busfahrer = '';
  bool isBusfahrerDialogOpen = false;
  bool? correct;
  int correctInRow = 0;

  // Todo:
  int phase = 1;

  bool connected = false;
  late io.Socket socket;

  void connectToServer() {
    // iOS-Verbindung zu Socket-Server.
    socket = io.io("ws://localhost:8001", <String, dynamic>{
      "transports": ["websocket"],
    });

    // Android-Verbindung zu Socket-Servers.
    /*socket = io.io("ws://10.0.2.2:8000", <String, dynamic>{
      "transports": ["websocket"],
    });*/

    socket.onConnect((_) {
      setState(() {
        connected = true;
      });
      _showDialogName(context);
      print('Verbunden');
    });

    socket.onDisconnect((_) {
      print('Getrennt');
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
      });
    });

    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));

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
        (data) => {_notifyError(context, 'Kein Raum gefunden')});

    socket.on('roomFullBusfahrer',
        (data) => {_notifyError(context, 'Raum bereits voll')});

    socket.on('nameBesetztBusfahrer',
        (data) => {_notifyError(context, 'Name bereits vergeben')});

    socket.on('spielLaeuft',
        (data) => {_notifyError(context, 'Spiel findet bereits statt')});

    socket.on(
        'closeModal',
        (data) => {
              Navigator.pop(context),
              _notifySuccess(context, 'Raum beigetreten')
            });

    socket.on(
        'busfahrerBestimmen',
        (data) => {
              busfahrer = data,
              /* _resetGameInfo(),
          for (var controller in animationControllers) {
            controller.reverse()
          },
          for (var controllerReverse in animationReverseControllers) {
            controllerReverse.forward()
          }, */
              setState(() {
                isBusfahrerDialogOpen = true;
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
    connectToServer();

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
    setState(() {
      connected = false;
    });
    for (var controller in animationControllers) {
      controller.dispose();
    }
    for (var controllerReverse in animationReverseControllers) {
      controllerReverse.dispose();
    }
    super.dispose();
  }

  void _showDialogName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Check for input and prevent dismissal if no input is given
            if (nameEingabe.isEmpty) {
              return false;
            }
            socket.emit("usernameBusfahrer", nameEingabe);
            setState(() {
              nameEingabe = '';
            });
            Navigator.pop(context);
            return true;
          },
          child: AlertDialog(
            //title: Text('Raum beitreten'),
            content: TextField(
              //controller: textEditingController,
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
          //title: Text('Raum beitreten'),
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

  void _notifyError(
    BuildContext context,
    String message,
  ) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: colors.red.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _notifySuccess(
    BuildContext context,
    String message,
  ) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: colors.green.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _karteDrehen(int index, int row) {
    //Todo: Überprüfen ob Ersteller!
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

  void _resetGameInfo() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Busfahrer"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black),
        body: Center(
          child: Stack(
            children: [
              Container(
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
                              if (roomBusfahrer.roomId.isEmpty) {
                                socket.emit("createRoomBusfahrer", name);
                              }
                            },
                            child: const Text(strings.rErstellen)),
                        AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.28),
                            color: colors.teal,
                            onPressed: () {
                              if (roomBusfahrer.roomId.isEmpty) {
                                _showDialogRaumBeitreten(context);
                              }
                            },
                            child: const Text(strings.rBeitreten)),
                        AnimatedButton(
                            width: (MediaQuery.of(context).size.width * 0.28),
                            color: colors.red,
                            onPressed: () {
                              if (roomBusfahrer.roomId.isNotEmpty &&
                                  roomBusfahrer.spieler.isNotEmpty) {
                                List<SpielerBusfahrer> einSpielerList =
                                    roomBusfahrer.spieler
                                        .where((einSpieler) =>
                                            einSpieler.name == name)
                                        .toList();

                                socket.emit('leaveBusfahrer', {
                                  'roomId': roomBusfahrer.roomId,
                                  'spielerId': einSpielerList.first.id
                                });
                                setState(() {
                                  roomBusfahrer = RoomBusfahrer(
                                      roomId: '',
                                      deck: [],
                                      spieler: [],
                                      phase: 1);
                                });
                                _resetGameInfo();
                              }
                            },
                            child: const Text(
                              strings.rVerlassen,
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                    Container(
                      height: 480,
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
                                    opacity: roomBusfahrer.roomId.isEmpty &&
                                            name.isNotEmpty
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
                                  children: [
                                    const Text("Meine\nKarten:"),
                                    const SizedBox(height: 10.0),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                            height: 60,
                                            width: 40,
                                            child: FlipCardReverse(
                                                animationReverseController:
                                                    animationReverseControllers[
                                                        0],
                                                frontChild: Image.asset(
                                                    'images/cards/${deck.isNotEmpty ? deck[meineKarten[0]].card : 'herz2'}.png'))),
                                        Text(
                                          '${trinkzahlArray[0] > 0 ? trinkzahlArray[0] : ''}',
                                          style: const TextStyle(fontSize: 25),
                                        )
                                      ],
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                            height: 60,
                                            width: 40,
                                            child: FlipCardReverse(
                                                animationReverseController:
                                                    animationReverseControllers[
                                                        1],
                                                frontChild: Image.asset(
                                                    'images/cards/${deck.isNotEmpty ? deck[meineKarten[1]].card : 'herz2'}.png'))),
                                        Text(
                                          '${trinkzahlArray[1] > 0 ? trinkzahlArray[1] : ''}',
                                          style: const TextStyle(fontSize: 25),
                                        )
                                      ],
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                            height: 60,
                                            width: 40,
                                            child: FlipCardReverse(
                                                animationReverseController:
                                                    animationReverseControllers[
                                                        2],
                                                frontChild: Image.asset(
                                                    'images/cards/${deck.isNotEmpty ? deck[meineKarten[2]].card : 'herz2'}.png'))),
                                        Text(
                                          '${trinkzahlArray[2] > 0 ? trinkzahlArray[2] : ''}',
                                          style: const TextStyle(fontSize: 25),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(children: [
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[14],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[14].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 14,
                                            row: 5,
                                          )),
                                    ]),
                                    Row(children: [
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[12],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[12].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 12,
                                            row: 4,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[13],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[13].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 13,
                                            row: 4,
                                          ))
                                    ]),
                                    Row(children: [
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[9],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[9].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 9,
                                            row: 3,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[10],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[10].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 10,
                                            row: 3,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[11],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[11].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 11,
                                            row: 3,
                                          ))
                                    ]),
                                    Row(children: [
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[5],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[5].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 5,
                                            row: 2,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[6],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[6].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 6,
                                            row: 2,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[7],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[7].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 7,
                                            row: 2,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[8],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[8].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 8,
                                            row: 2,
                                          ))
                                    ]),
                                    Row(children: [
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[0],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[0].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 0,
                                            row: 1,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[1],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[1].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 1,
                                            row: 1,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[2],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[2].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 2,
                                            row: 1,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[3],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[3].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 3,
                                            row: 1,
                                          )),
                                      SizedBox(
                                          height: 60,
                                          width: 40,
                                          child: FlipCard(
                                            animationController:
                                                animationControllers[4],
                                            frontChild: Image.asset(
                                                'images/cards/${deck.isNotEmpty ? deck[4].card : 'herz2'}.png'),
                                            onButtonPressed: _karteDrehen,
                                            index: 4,
                                            row: 1,
                                          ))
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                              visible:
                                  roomBusfahrer.phase == 3 && correctInRow < 5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Text("Busfahrer: $busfahrer", style: const TextStyle(fontSize: 20)),
                                        const SizedBox(height: 16.0),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Image.asset(deck.isNotEmpty
                                              ? 'images/cards/${deck[n].card}.png'
                                              : 'images/cards/back2.png'),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.89,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Opacity(
                                                        opacity: correct != null
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
                                                                          BorderRadius.circular(
                                                                              25.0))),
                                                          child: Text(correct ==
                                                                  true
                                                              ? correct == false
                                                                  ? ''
                                                                  : 'Richtig'
                                                              : 'Falsch', style: const TextStyle(fontSize: 20)),
                                                        )),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                        "Richtig in Folge: $correctInRow", style: const TextStyle(fontSize: 20)),
                                                  ],
                                                )
                                              ]),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ))
                        ],
                      )),
                    ),
                    const SizedBox(height: 8.0),
                    Visibility(
                      visible: (_ersteller() && roomBusfahrer.phase != 3) ||
                          (_ersteller() &&
                              roomBusfahrer.phase == 3 &&
                              correctInRow == 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.95),
                              color: (roomBusfahrer.phase == 2 && !flipArray[14]) ? colors.teal.withOpacity(0.5) : colors.teal,
                              onPressed: () {
                                if (roomBusfahrer.phase == 1) {
                                  List<Cards> deck = createDeck();
                                  deck.shuffle();
                                  socket.emit('austeilen', {
                                    'roomId': roomBusfahrer.roomId,
                                    'deck': jsonEncode(deck)
                                  });
                                } else if (roomBusfahrer.phase == 2 && flipArray[14]) {
                                  socket.emit("busfahren",
                                      {'roomId': roomBusfahrer.roomId});
                                } else if (roomBusfahrer.phase == 3) {
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
                    Visibility(
                      visible: _ersteller() &&
                          roomBusfahrer.phase == 3 &&
                          correctInRow < 5,
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
                    )
                  ],
                ),
              ),
              if (loading)
                Container(
                  color: Colors.black
                      .withOpacity(0.1), // Semi-transparent overlay color
                  child: const Center(
                    child:
                        CircularProgressIndicator(), // Loading indicator
                  ),
                ),
            ],
          ),
        ));
  }
}
