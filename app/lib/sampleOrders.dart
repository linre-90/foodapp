class Order{
  String name;
  String drink;

  Order(this.name, this.drink);

  String toText(){
    return "$name - $drink";
  }
}

class OrderData{
  List<Order> items;
  int state;

  OrderData(this.items, this.state);
}