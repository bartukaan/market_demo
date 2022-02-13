class Coin {
  String base;
  String quote;
  String type;
  double lastPrice;
  double volume;

  Coin(
      {required this.base,
      required this.quote,
      required this.type,
      required this.lastPrice,
      required this.volume});

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
        base: json["base"],
        quote: json["quote"],
        type: json["type"],
        lastPrice: double.parse(json["lastPrice"].toString()),
        volume: double.parse(json["volume"].toString()),
      );
}
