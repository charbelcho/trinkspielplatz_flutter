import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_project/model/room_class.dart';
import 'package:my_flutter_project/model/spieler_class.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:my_flutter_project/three_d_button.dart';
import 'assets/colors.dart' as colors;
import 'assets/strings.dart' as strings;
import 'model/data_class.dart';

class WerBinIch extends StatefulWidget {
  const WerBinIch({Key? key}) : super(key: key);

  @override
  _WerBinIchState createState() => _WerBinIchState();
}

class _WerBinIchState extends State<WerBinIch> {
  String name = '';
  String nameEingabe = '';
  String raumIdEingabe = '';
  RoomWerBinIch roomWerBinIch = RoomWerBinIch(roomId: '', spieler: []);
  int namenSpeichernFuerIndex = 0;
  String namenSpeichernFuer = '';

  bool connected = false;
  late io.Socket socket;

  void connectToServer() {
    // iOS-Verbindung zu Socket-Server.
    socket = io.io("ws://localhost:8000", <String, dynamic>{
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
    socket.on('werbinIchUsername', (data) {
      setState(() {
        name = data;
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
      });
    });

    socket.on('keinRaumGefunden', (data) => _notifyError(context, 'Kein Raum gefunden'));

    socket.on('roomFull', (data) => _notifyError(context, 'Raum bereits voll'));

    socket.on('nameBesetzt', (data) => _notifyError(context, 'Name bereits vergeben'));

    socket.on('speicherNamenFuer', (data) {
      setState(() {
        namenSpeichernFuerIndex = data;
      });
      _showDialogNamenSpeichern(context);
    });
  }

  @override
  void dispose() {
    // Schließe die Socket-Verbindung, wenn die App geschlossen oder die Seite gewechselt wird.
    socket.disconnect();
    setState(() {
      connected = false;
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    connectToServer();
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
            socket.emit("usernameWerbinIch", nameEingabe);
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
              child: const Text('Beitreten'),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.bluegray,
        appBar: AppBar(
            title: const Text("Wer bin ich?"),
            centerTitle: true,
            backgroundColor: colors.teal,
            foregroundColor: Colors.black),
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
                          if (roomWerBinIch.roomId.isEmpty) {
                            socket.emit("createRoom", name);
                          }
                        },
                        child: const Text(strings.rErstellen)),
                    AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.28),
                        color: colors.teal,
                        onPressed: () {
                          if (roomWerBinIch.roomId.isEmpty) {
                            _showDialogRaumBeitreten(context);
                          }
                        },
                        child: const Text(strings.rBeitreten)),
                    AnimatedButton(
                        width: (MediaQuery.of(context).size.width * 0.28),
                        color: colors.red,
                        onPressed: () {
                          if (roomWerBinIch.spieler.isNotEmpty) {
                            List<SpielerWerBinIch> einSpielerList =
                                roomWerBinIch.spieler
                                    .where(
                                        (einSpieler) => einSpieler.name == name)
                                    .toList();

                            socket.emit('leave', {
                              'roomId': roomWerBinIch.roomId,
                              'spielerId': einSpielerList.first.id
                            });
                            setState(() {
                              roomWerBinIch =
                                  RoomWerBinIch(roomId: '', spieler: []);
                            });
                          }
                        },
                        child: const Text(
                          strings.rVerlassen,
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
                Container(
                  height: 400,
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side:
                              const BorderSide(width: 10, color: colors.teal))),
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
                                opacity: roomWerBinIch.roomId.isEmpty &&
                                        name.isNotEmpty
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
                                Text(
                                  '${einSpieler.name} : ${einSpieler.name == name && einSpieler.werbinich.text.isNotEmpty ? "**********" : einSpieler.werbinich.text}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 5.0),
                              ],
                            ),
                        ],
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 8.0),
                Opacity(
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
                          width: (MediaQuery.of(context).size.width * 0.43),
                          color: colors.teal,
                          onPressed: () {
                            if (roomWerBinIch.spieler.length > 1) {
                              socket.emit('zufaellig',
                                  {'roomId': roomWerBinIch.roomId});
                            }
                          },
                          child: const Text(strings.zufaellig)),
                      AnimatedButton(
                          width: (MediaQuery.of(context).size.width * 0.43),
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
                )
              ],
            ),
          ),
        ));
  }
}
