import 'package:trinkspielplatz/model/data_class.dart';

class Spieler {
  String id;
  String name;


  Spieler({
    required this.id,
    required this.name
  });

  // A factory constructor to convert JSON data into a Car object
  factory Spieler.fromJson(Map<String, dynamic> json) {
    return Spieler(
      id: json['id'],
      name: json['name']
    );
  }
}

class SpielerPferderennen extends Spieler {
  int schlucke;
  String zeichen;

  SpielerPferderennen({
    required super.id, 
    required super.name,
    required this.schlucke,
    required this.zeichen
  });

  factory SpielerPferderennen.fromJson(Map<String, dynamic> json) {
    return SpielerPferderennen(
      id: json['id'],
      name: json['name'],
      schlucke: json['schlucke'],
      zeichen: json['zeichen'],
    );
  }
}

class Spieler100 extends Spieler {
  int punkte;

  Spieler100({
    required super.id, 
    required super.name,
    required this.punkte
  });

  factory Spieler100.fromJson(Map<String, dynamic> json) {
    return Spieler100(
      id: json['id'],
      name: json['name'],
      punkte: json['punkte'],
    );
  }
}

class SpielerWerBinIch extends Spieler {
  WerBinIchData werbinich;

  SpielerWerBinIch({
    required super.id, 
    required super.name,
    required this.werbinich
  });

  factory SpielerWerBinIch.fromJson(Map<String, dynamic> json) {
    return SpielerWerBinIch(
      id: json['id'],
      name: json['name'],
      werbinich: json['werbinich'],
    );
  }
}

class SpielerBusfahrer extends Spieler {
  List<int> eigeneKarten;
  List<bool> flipArray;

  SpielerBusfahrer({
    required super.id, 
    required super.name,
    required this.eigeneKarten,
    required this.flipArray
  });

  factory SpielerBusfahrer.fromJson(Map<String, dynamic> json) {
    return SpielerBusfahrer(
      id: json['id'],
      name: json['name'],
      eigeneKarten: json['eigeneKarten'],
      flipArray: json['flipArray']
    );
  }
}

