class ItemModel {
  final int? itemId;
  final String itemTitle;
  final String itemPrice;
  final String itemImage;
  final int? colorValue;

  ItemModel({
    this.itemId,
    required this.itemTitle,
    required this.itemPrice,
    required this.itemImage,
    this.colorValue,
  });

  factory ItemModel.fromMap(Map<String, dynamic> json) => ItemModel(
        itemId: json["itemId"],
        itemTitle: json["itemTitle"],
        itemPrice: json["itemPrice"],
        itemImage: json["itemImage"],
        colorValue: json["colorValue"],
      );

  Map<String, dynamic> toMap() => {
        "itemId": itemId,
        "itemTitle": itemTitle,
        "itemPrice": itemPrice,
        "itemImage": itemImage,
        "colorValue": colorValue,
      };
}
