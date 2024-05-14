import 'package:flutter/cupertino.dart';

/// Class that resembles single order or "meal" construction.
class Order{
  String name;
  String drink;

  Order(this.name, this.drink);

  String toText(){
    return "$name - $drink";
  }

  Map<String, String> toJson(){
    return{"name":name, "drink": drink};
  }
}

/// Full order consists of delivery state and order class items.
class OrderData{
  List<Order> items;
  int state;

  OrderData(this.items, this.state);

  Map<String, dynamic> toJson(){
    return {"items": items};
  }
}

/// Widget used to render full order data.
class OrderWidget extends StatelessWidget{
  final OrderData orderData;

  const OrderWidget(this.orderData, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> orderItems = [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(orderData.items[0].toText()),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(orderData.items[1].toText()),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(orderData.items[2].toText()),
      )
    ];

    return(
    Column(children: [
      const Text("Order summary", style: TextStyle(fontSize: 20),),
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: orderItems,),
      )
    ],)
    );
  }
}