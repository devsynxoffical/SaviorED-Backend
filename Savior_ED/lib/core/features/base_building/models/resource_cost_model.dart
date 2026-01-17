class ResourceCost {
  final int coins;
  final int wood;
  final int stone;

  const ResourceCost({this.coins = 0, this.wood = 0, this.stone = 0});

  bool get isFree => coins == 0 && wood == 0 && stone == 0;
}
