import 'dart:convert';
import 'package:app/order.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';
import "notifications.dart";

// Constants
const SERVER_URL = "http://192.168.2.39:8080/api/order";
const SOCKET_URL = "http://192.168.2.39:8080";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Best burger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  // Holds track off the order state. -1 means order is not yet submitted to server.
  int _orderState = -1;

  // Order id returned from server
  int _orderId = -1;

  // Can application move on from order tracking phase.
  bool _orderReady = false;

  // Timestamp when order was made.
  late DateTime _orderTime;

  // Socket is initialized after order is sent successfully.
  late IO.Socket _socket;

  // Order progress text
  final List<String> _orderStateText = [
    "Your order is waiting available cook.",
    "We have started cooking your order.",
    "Your order is ready to be picked up!",
    "Bon appetit, enjoy!"
  ];

  // Order progress description widgets
  final List<Widget> _orderStateHelp = [
    const Text("Your order is waiting available cook.",
        style: TextStyle(fontSize: 16)),
    const Text("We have started cooking your order.",
        style: TextStyle(fontSize: 16)),
    const Text("Your order is ready to be picked up!",
        style: TextStyle(fontSize: 16)),
    const Text("Bon appetit, enjoy!")
  ];

  // Sample order
  final _orderData = OrderData([
    Order("SmallMac", "water"),
    Order("MicroMac", "juice box"),
    Order("HugeMac", "soda")
  ], -1);

  /// Resets app back to start point like in first launch.
  void _reset() {
    setState(() {
      _orderState = -1;
      _orderId = -1;
      _orderReady = false;
    });
  }

  /// Send order to backend server and proceed to order tracking phase.
  Future<void> _sendOrder() async {
    var response = await _postOrder();
    if (response.statusCode == 200) {
      setState(() {
        // Update states
        _orderState = 0;
        _orderId = int.parse(response.body);
        _orderTime = DateTime.now();
        NotificationService().makeNotification(_orderStateText[_orderState]);

        // Make socket connection
        _socket = IO.io(
            SOCKET_URL, OptionBuilder().setTransports(["websocket"]).build());

        // Connect/disconnect events
        _socket.onConnect((data) => print("Connected"));
        _socket.onDisconnect((data) => print("disconnected"));

        // Order status changed event
        _socket.on("onOrderStatusChanged", (data) {
          var dataId = int.parse(data["id"]);
          if (dataId != _orderId) { // emitted order matches order number app received on submit?
            return;
          }
          var dataState = data["state"];
          setState(() {
            _orderState = dataState;
            NotificationService()
                .makeNotification(_orderStateText[_orderState]);
          });
          if (dataState == 3) {
            _socket.disconnect();
            setState(() {
              _orderReady = true;
            });
          }
        });
      });
    } else {
      throw Exception(
          'Failed connect to server. Error: ${response.statusCode}-${response.body}');
    }
  }

  /// Make the actual post request to backend server.
  Future<http.Response> _postOrder() async {
    var headers = <String, String>{
      "Content-Type": "application/json; charset=UTF-8"
    };
    return http.post(Uri.parse(SERVER_URL),
        headers: headers, body: jsonEncode(_orderData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                _orderId != -1
                    ? Text("Order id: $_orderId",
                        style: const TextStyle(fontSize: 22))
                    : const Text(""),
                _orderId != -1
                    ? Text("Order placed: $_orderTime",
                        style: const TextStyle(fontSize: 16))
                    : const Text(""),
                _orderId != -1
                    ? const Text("Order status", style: TextStyle(fontSize: 22))
                    : const Text(""),
                _orderState == -1
                    ? OrderWidget(_orderData)
                    : _orderStateHelp[_orderState],
              ],
            ),
          ),
        ),
        floatingActionButton: _orderState == -1
            ? FloatingActionButton(
                onPressed: _sendOrder,
                tooltip: 'Send order',
                child: const Text("Order"),
              )
            : FloatingActionButton(
                onPressed: _orderReady ? _reset : null,
                tooltip: 'Ok',
                child: const Text("Ok"),
              ));
  }
}
