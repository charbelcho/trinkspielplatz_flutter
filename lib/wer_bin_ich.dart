import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trinkspielplatz/ad_screen.dart';
import 'package:trinkspielplatz/anleitungen.dart';
import 'package:trinkspielplatz/connection_error_widget.dart';
import 'package:trinkspielplatz/logger.dart';
import 'package:trinkspielplatz/model/room_class.dart';
import 'package:trinkspielplatz/model/spieler_class.dart';
import 'package:trinkspielplatz/notify.dart';
import 'package:trinkspielplatz/web_page_wrapper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:trinkspielplatz/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;
import 'model/data_class.dart';

class WerBinIch extends StatefulWidget {
  const WerBinIch({super.key});

  @override
  State<WerBinIch> createState() => _WerBinIchState();
}

class _WerBinIchState extends State<WerBinIch> with RouteAware {
  bool loading = true;
  String name = '';
  String nameEingabe = '';
  String raumIdEingabe = '';
  RoomWerBinIch roomWerBinIch = RoomWerBinIch(roomId: '', spieler: []);
  int namenSpeichernFuerIndex = 0;
  String namenSpeichernFuer = '';

  bool connectionFailed = false;
  late io.Socket socket;

  void connectToServer() {
    if (Platform.isIOS) {
      // iOS-Verbindung zu Socket-Server.
      socket =
          io.io("wss://socket-ios-backend.herokuapp.com", <String, dynamic>{
        "transports": ["websocket"],
        "forceNew": true
      });
      /* socket = io.io("ws://localhost:8000", <String, dynamic>{
        "transports": ["websocket"],
        "forceNew": true
      }); */
    } else if (Platform.isAndroid) {
      // Android-Verbindung zu Socket-Servers.
      socket =
          io.io("wss://socket-ios-backend.herokuapp.com", <String, dynamic>{
        "transports": ["websocket"],
        "forceNew": true
      });
    } else {
      socket =
          io.io("wss://socket-ios-backend.herokuapp.com", <String, dynamic>{
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
      logger.i('Verbunden');
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
      logger.i('Getrennt');
    });

    // Hör auf Ereignisse vom Server und reagiere entsprechend.
    socket.on('loading', (data) {
      setState(() {
        loading = true;
      });
    });

    socket.on('werbinIchUsername', (data) {
      setState(() {
        name = data;
        loading = false;
      });
    });

    socket.on('room', (data) {
      RoomWerBinIch dataRoomWerBinIch =
          RoomWerBinIch(roomId: data['roomId'], spieler: []);

      var spielerListe = data['spieler'];

      for (var spieler in spielerListe) {
        String id = spieler['id'];
        String name = spieler['name'];
        int werBinIchId = spieler['werbinich']['id'];
        String werBinIchText = spieler['werbinich']['text'];
        String werBinIchInfo = spieler['werbinich']['info'];

        WerBinIchData werbinich = WerBinIchData(
            id: werBinIchId, text: werBinIchText, info: werBinIchInfo);
        SpielerWerBinIch spielerWerBinIch =
            SpielerWerBinIch(id: id, name: name, werbinich: werbinich);
        dataRoomWerBinIch.spieler.add(spielerWerBinIch);
      }
      setState(() {
        roomWerBinIch = dataRoomWerBinIch;
        loading = false;
      });
    });

    socket.on('keinRaumGefunden',
        (data) => notify.notifyError(context, 'Kein Raum gefunden'));

    socket.on(
        'roomFull', (data) => notify.notifyError(context, 'Raum bereits voll'));

    socket.on('nameBesetzt',
        (data) => notify.notifyError(context, 'Name bereits vergeben'));

    socket.on('speicherNamenFuer', (data) {
      setState(() {
        namenSpeichernFuerIndex = data;
        loading = false;
      });
      _showDialogNamenSpeichern(context);
    });
  }

  @override
  void dispose() {
    // Schließe die Socket-Verbindung, wenn die App geschlossen oder die Seite gewechselt wird.
    socket.disconnect();
    socket.dispose();
    socket.destroy();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      connectToServer();
    });
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
                  loading = false;

                  name = '';
                  nameEingabe = '';
                  raumIdEingabe = '';
                  roomWerBinIch = RoomWerBinIch(roomId: '', spieler: []);
                  namenSpeichernFuerIndex = 0;
                  namenSpeichernFuer = '';

                  connectionFailed = false;
                });
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
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
                    socket.emit("usernameWerbinIch", nameEingabe);
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
                  socket.emit(
                      "joinRoom", {'roomId': raumIdEingabe, 'name': name});
                  // Handle action on button press
                  Navigator.pop(context);
                }
              },
              child: const Text('Beitreten'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogNamenSpeichern(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Name für ${roomWerBinIch.spieler[namenSpeichernFuerIndex].name}'),
          content: TextField(
            //controller: textEditingController,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                namenSpeichernFuer = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Namen eingeben...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (namenSpeichernFuer.isNotEmpty) {
                  socket.emit("namenSpeichern", {
                    'roomId': roomWerBinIch.roomId,
                    'name': roomWerBinIch.spieler[namenSpeichernFuerIndex].name,
                    'werbinich': namenSpeichernFuer
                  });
                  setState(() {
                    namenSpeichernFuer = '';
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Senden'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogWebView(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
          content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.99,
              child: SafariWrapper(url: url)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Schließen'),
            ),
          ],
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

  void _raumVerlassen() {
    if (roomWerBinIch.spieler.isNotEmpty) {
      List<SpielerWerBinIch> einSpielerList = roomWerBinIch.spieler
          .where((einSpieler) => einSpieler.name == name)
          .toList();

      socket.emit('leave', {
        'roomId': roomWerBinIch.roomId,
        'spielerId': einSpielerList.first.id
      });
      setState(() {
        roomWerBinIch = RoomWerBinIch(roomId: '', spieler: []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            backgroundColor: colors.bluegray,
            appBar: AppBar(
                title: const Text("Wer bin ich?"),
                leading: IconButton(
                  icon: const Icon(Icons
                      .arrow_back_ios_new_rounded), // Replace with your custom icon
                  onPressed: () {
                    // Define the behavior when the custom back button is pressed
                    _showDialogSpielVerlassen(context);
                    /* Navigator.of(context).pop(); */
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
                //width: MediaQuery.of(context).size.width * 0.95,
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.28),
                              color: colors.teal,
                              onPressed: () {
                                if (roomWerBinIch.roomId.isEmpty) {
                                  socket.emit("createRoom", name);
                                }
                              },
                              enabled: name.isNotEmpty &&
                                  roomWerBinIch.roomId.isEmpty,
                              child: const Text(strings.rErstellen)),
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.28),
                              color: colors.teal,
                              onPressed: () {
                                if (roomWerBinIch.roomId.isEmpty) {
                                  _showDialogRaumBeitreten(context);
                                }
                              },
                              enabled: name.isNotEmpty &&
                                  roomWerBinIch.roomId.isEmpty,
                              child: const Text(strings.rBeitreten)),
                          AnimatedButton(
                              width: (MediaQuery.of(context).size.width * 0.28),
                              color: colors.red,
                              onPressed: () {
                                _showDialogRaumVerlassen(context);
                              },
                              enabled: name.isNotEmpty &&
                                  roomWerBinIch.roomId.isNotEmpty,
                              child: const Text(
                                strings.rVerlassen,
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //height: 400,
                        width: MediaQuery.of(context).size.width * 0.95,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name),
                                      const SizedBox(height: 5.0),
                                      Text(roomWerBinIch.roomId),
                                      const SizedBox(height: 5.0),
                                      Text(roomWerBinIch.spieler.isNotEmpty
                                          ? roomWerBinIch.spieler.first.name
                                          : '')
                                    ]),
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Opacity(
                                      opacity: roomWerBinIch.roomId.isEmpty
                                          ? 1.0
                                          : 0.0,
                                      child: TextButton(
                                          child: const Text("Name\nbearb."),
                                          onPressed: () {
                                            if (roomWerBinIch.roomId.isEmpty) {
                                              _showDialogName(context);
                                            }
                                          }),
                                    )
                                  ]),
                            ]),
                            const Divider(
                              thickness: 1.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var einSpieler in roomWerBinIch.spieler)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${einSpieler.name} : ${einSpieler.name == name && einSpieler.werbinich.text.isNotEmpty ? "**********" : einSpieler.werbinich.text}',
                                            textAlign: TextAlign.left,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          if (einSpieler.name != name &&
                                              einSpieler
                                                  .werbinich.info.isNotEmpty)
                                            IconButton(
                                                onPressed: () {
                                                  _showDialogWebView(
                                                      context,
                                                      einSpieler
                                                          .werbinich.info);
                                                },
                                                icon: const Icon(Icons
                                                    .info_outline_rounded)),
                                        ],
                                      ),
                                      const SizedBox(height: 5.0),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        )),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Opacity(
                        opacity: roomWerBinIch.spieler.isNotEmpty
                            ? roomWerBinIch.spieler.first.name == name
                                ? 1.0
                                : 0.0
                            : 0.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedButton(
                                enabled: roomWerBinIch.spieler.length > 1,
                                width:
                                    (MediaQuery.of(context).size.width * 0.43),
                                color: colors.teal,
                                onPressed: () {
                                  if (roomWerBinIch.spieler.length > 1) {
                                    socket.emit('zufaellig',
                                        {'roomId': roomWerBinIch.roomId});
                                  }
                                },
                                child: const Text(strings.zufaellig)),
                            AnimatedButton(
                                enabled: roomWerBinIch.spieler.length > 1,
                                width:
                                    (MediaQuery.of(context).size.width * 0.43),
                                color: colors.teal,
                                onPressed: () {
                                  if (roomWerBinIch.spieler.length > 1) {
                                    socket.emit('zuweisen', {
                                      {'roomId': roomWerBinIch.roomId}
                                    });
                                  }
                                },
                                child: const Text(strings.zuweisen))
                          ],
                        ),
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
                Colors.black.withOpacity(0.3), // Semi-transparent overlay color
            child: const Center(
              child: CircularProgressIndicator(), // Loading indicator
            ),
          ),
        if (connectionFailed)
          ConnectionErrorWidget(onFloatingButtonPressed: () {
            setState(() {
              loading = true;
              connectionFailed = false;
            });
            Future.delayed(const Duration(seconds: 3), () {
              connectToServer();
            });
          }, onBackButtonPressed: () {
            setState(() {
              loading = false;
              name = '';
              nameEingabe = '';
              raumIdEingabe = '';
              roomWerBinIch = RoomWerBinIch(roomId: '', spieler: []);
              namenSpeichernFuerIndex = 0;
              namenSpeichernFuer = '';
              connectionFailed = false;
            });
            Navigator.of(context).pop();
          })
      ],
    );
  }
}
