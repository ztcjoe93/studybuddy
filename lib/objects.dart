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


class Result {
  String isoTimestamp;
  String deckName;
  String deckTag;
  List<CardResult> results = [];

  Result(this.isoTimestamp, this.deckName, this.deckTag, this.results);
  Result.fromJson(Map<String, dynamic> json){
    isoTimestamp = json['date'];
    deckName = json['name'];
    deckTag = json['tag'];
    json['results'].forEach((e) => results.add(CardResult.fromJson(e)));
  }

  @override
  String toString() => "Result($isoTimestamp, $deckName, $deckTag, $results)";
  Map<String, dynamic> toJson() => {
    "date": isoTimestamp,
    "name": deckName,
    "tag": deckTag,
    "results": results.map((e) => e.toJson()).toList(),
  };
}


class CardResult {
  FlashCard card;
  bool score;

  CardResult(this.card, this.score);
  CardResult.fromJson(Map<String, dynamic> json){
    card = FlashCard.fromJson(json['card']);
    score = json['score'];
  }

  @override
  String toString() => "CardResult($card, $score)";
  Map<String, dynamic> toJson() => {"card": card.toJson(), "score": score};
}
