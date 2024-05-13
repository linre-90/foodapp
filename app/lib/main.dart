import 'package:app/order.dart';
import 'package:app/sampleOrders.dart';
import 'package:flutter/material.dart';
//import 'package:socket_io_client/socket_io_client.dart';
//import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Best burger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Best burger - your money is our money!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _orderState = -1;
   final List<Widget> _orderStateHelp = [
    const Text("Your order is waiting available cook."),
    const Text("We have started cooking your order."),
    const Text("Your order is ready to be picked up!"),
    const Text("Bon appetit, enjoy!")
   ];

  void _sendOrder() {
    setState(() {
      _orderState = 0;
    });
  }

  final _orderData = OrderData([
    Order("SmallMac", "water"),
    Order("MicroMac", "juice box"),
    Order("HugeMac", "soda")
  ], -1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _orderState == -1 ? OrderWidget(_orderData) : _orderStateHelp[_orderState],
      ),
      floatingActionButton: _orderState == -1 ? FloatingActionButton(
        onPressed: _sendOrder,
        tooltip: 'Send order',
        child: const Text("Order"),
      ):null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
