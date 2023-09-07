import 'package:my_flutter_project/model/cards_class.dart';
import 'package:my_flutter_project/model/spieler_class.dart';

class RoomWerBinIch {
  String roomId;
  List<SpielerWerBinIch> spieler;

  RoomWerBinIch({
    required this.roomId,
    required this.spieler
  });

  factory RoomWerBinIch.fromJson(Map<String, dynamic> json) {
    return RoomWerBinIch(
      roomId: json['roomId'],
      spieler: json['spieler']
    );
  }
}

class RoomBusfahrer {
  String roomId;
  List<Cards> deck;
  List<SpielerBusfahrer> spieler;
  int phase;

  RoomBusfahrer({
    required this.roomId,
    required this.deck,
    required this.spieler,
    required this.phase
  });

  factory RoomBusfahrer.fromJson(Map<String, dynamic> json) {
    return RoomBusfahrer(
      roomId: json['roomId'],
      deck: json['deck'],
      spieler: json['spieler'],
      phase: json['phase']
    );
  }
}
