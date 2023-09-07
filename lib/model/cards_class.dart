class Cards {
  final int id;
  final String card;
  final int value;
  final String colour;
  final String zeichen;

  Cards(
      {required this.id,
      required this.card,
      required this.value,
      required this.colour,
      required this.zeichen});

  // A factory constructor to convert JSON data into a Car object
  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
        id: json['id'],
        card: json['card'],
        value: json['value'],
        colour: json['colour'],
        zeichen: json['zeichen']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card': card,
      'value': value,
      'colour': colour,
      'zeichen': zeichen
    };
  }
}
