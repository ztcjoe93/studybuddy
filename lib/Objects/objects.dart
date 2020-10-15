class Deck {
  String name, tag;
  int id;
  List<FlashCard> cards = [];

  Deck(this.id, this.name, this.tag, this.cards);

  @override
  String toString() => "Deck($id, $name, $tag, $cards)";
}


class FlashCard {
  String front, back;
  int id;

  FlashCard(this.id, this.front, this.back);

  @override
  String toString() => "FlashCard($id, $front, $back)";
}


class Result {
  String isoTimestamp;
  String deckName;
  String deckTag;
  List<CardResult> results = [];

  Result(this.isoTimestamp, this.deckName, this.deckTag, this.results);

  @override
  String toString() => "Result($isoTimestamp, $deckName, $deckTag, $results)";
}


class CardResult {
  int id;
  FlashCard card;
  bool score;

  CardResult(this.id, this.card, this.score);

  @override
  String toString() => "CardResult($id, $card, $score)";
}
