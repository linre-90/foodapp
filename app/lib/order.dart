import 'package:app/sampleOrders.dart';
import 'package:flutter/cupertino.dart';

class OrderWidget extends StatelessWidget{
  final OrderData orderData;

  const OrderWidget(this.orderData, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> orderItems = [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(orderData.items[0].toText(), textAlign: TextAlign.start),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(orderData.items[1].toText(), textAlign: TextAlign.start),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(orderData.items[2].toText(), textAlign: TextAlign.start),
      )
    ];

    return(
    Column(children: [
      const Text("Order summary: ", style: TextStyle(fontSize: 20),),
      Padding(
        padding: const EdgeInsets.fromLTRB(40, 5, 5, 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: orderItems,),
      )
    ],)


    );
  }
  
}