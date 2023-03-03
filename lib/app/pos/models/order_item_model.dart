class MenuOrderItemModel {
  final int quantity;
  final num rate;
  final String itemName;
  final bool ready;

  const MenuOrderItemModel({
    required this.itemName,
    required this.quantity,
    required this.rate,
    this.ready = false,
  });
}
