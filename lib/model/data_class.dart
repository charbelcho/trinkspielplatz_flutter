class NochNieData {
  final int id;
  final String text;

  NochNieData({
    required this.id,
    required this.text
  });

  // A factory constructor to convert JSON data into a Car object
  factory NochNieData.fromJson(Map<String, dynamic> json) {
    return NochNieData(
      id: json['id'],
      text: json['text'],
    );
  }
}

class EherData {
  final int id;
  final String text;

  EherData({
    required this.id,
    required this.text
  });

  // A factory constructor to convert JSON data into a Car object
  factory EherData.fromJson(Map<String, dynamic> json) {
    return EherData(
      id: json['id'],
      text: json['text'],
    );
  }
}

class WahrheitData {
  final int id;
  final String text;

  WahrheitData({
    required this.id,
    required this.text
  });

  // A factory constructor to convert JSON data into a Car object
  factory WahrheitData.fromJson(Map<String, dynamic> json) {
    return WahrheitData(
      id: json['id'],
      text: json['text'],
    );
  }
}

class PflichtData {
  final int id;
  final String text;

  PflichtData({
    required this.id,
    required this.text
  });

  // A factory constructor to convert JSON data into a Car object
  factory PflichtData.fromJson(Map<String, dynamic> json) {
    return PflichtData(
      id: json['id'],
      text: json['text'],
    );
  }
}

class WerBinIchData {
  final int id;
  final String text;
  final String info;

  WerBinIchData({
    required this.id,
    required this.text,
    required this.info
  });

  // A factory constructor to convert JSON data into a Car object
  factory WerBinIchData.fromJson(Map<String, dynamic> json) {
    return WerBinIchData(
      id: json['id'],
      text: json['text'],
      info: json['info']
    );
  }
}


