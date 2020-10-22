class Deck {
  String name, tag;
  int id;
  List<FlashCard> cards = [];

  Deck(this.id, this.name, this.tag, this.cards);

  @override
  String toString() => "Deck($id, $name, $tag, $cards)";
}


class FlashCard {
  int id;
  String front, back;

  FlashCard(this.id, this.front, this.back);

  @override
  String toString() => "FlashCard($id, $front, $back)";
}


class Result {
  int id;
  String isoTimestamp;
  int deckId;
  List<CardResult> results = [];

  Result(this.id, this.isoTimestamp, this.deckId, this.results);

  @override
  String toString() => "Result($id, $isoTimestamp, $deckId, $results)";
}


class CardResult {
  int id;
  FlashCard card;
  bool score;

  CardResult(this.id, this.card, this.score);

  @override
  String toString() => "CardResult($id, $card, $score)";
}
