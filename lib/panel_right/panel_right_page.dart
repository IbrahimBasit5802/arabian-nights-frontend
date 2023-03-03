import 'package:flutter/material.dart';
import '/panel_right/wiggle_graph.dart';
import '../constants.dart';


class Product {
  String name;
  bool enable;

  Product({this.enable = true, required this.name});
}

class PanelRightPage extends StatefulWidget {
  @override
  _PanelRightPageState createState() => _PanelRightPageState();
}

class _PanelRightPageState extends State<PanelRightPage> {

  List<Product> _products = [
    Product(name: "LED Submersible Lights", enable: true),
    Product(name: "Portable Projector", enable: true),
    Product(name: "Bluetooth Speaker", enable: true),
    Product(name: "Smart Watch", enable: true),
    Product(name: "Vegetable Chopper", enable: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(
              left: Constants.kPadding / 2,
              right: Constants.kPadding / 2,
              top: Constants.kPadding / 2,
            ),
              child: Card(
                color: Constants.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Container(
                  width: double.infinity,
                  child: ListTile(
                    title: Text(
                      "Net Revenue",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "7% of Sales Avg",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        r"$46,450",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //chart
            LineChartSample1(),
            Padding(padding: const EdgeInsets.only(
              left: Constants.kPadding / 2,
              right: Constants.kPadding / 2,
              top: Constants.kPadding / 2,
            ),
              child: Card(color: Constants.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: List.generate(_products.length, (index) =>
                      SwitchListTile.adaptive(
                        title: Text(
                          _products[index].name,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        value: _products[index].enable,
                        onChanged: (newValue){
                          setState(() {
                            _products[index].enable = newValue;
                          });
                        },
                      ),
                  ),
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
