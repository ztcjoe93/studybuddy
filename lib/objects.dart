class Deck {
  String name, tag;
  List<FlashCard> cards = [];

  Deck(this.name, this.tag, this.cards);
  Deck.fromJson(Map<String, dynamic> json){
    name = json['name'];
    tag = json['tag'];
    json['cards'].forEach((e) => cards.add(FlashCard.fromJson(e)));
  }

  @override
  String toString() => "Deck($name, $tag, $cards)";
  Map<String, dynamic> toJson() => {
    "name": name,
    "tag": tag,
    "cards": cards.map((e) => e.toJson()).toList(),
  };
}


class FlashCard {
  String front, back;

  FlashCard(this.front, this.back);
  FlashCard.fromJson(Map<String, dynamic> json){
    front = json['front'];
    back = json['back'];
  }

  @override
  String toString() => "FlashCard($front, $back)";
  Map<String, dynamic> toJson() => {"front": front, "back": back};
}
