import 'package:flutter/material.dart';
import '/panel_center/linear_graph.dart';

import '../constants.dart';

class Person {
  String name;
  Color color;

  Person({required this.name, required this.color});
}

class PanelCenterPage extends StatefulWidget {
  @override
  _PanelCenterPageState createState() => _PanelCenterPageState();
}

class _PanelCenterPageState extends State<PanelCenterPage> {
  List<Person> _persons = [
    Person(name: "Thevia Bowen", color: Constants.orangeLight),
    Person(name: "Fariha Odling", color: Constants.orangeLight),
    Person(name: "Viola Willis", color: Constants.orangeLight),
    Person(name: "Emmett Forrest", color: Constants.orangeLight),
    Person(name: "Haley Mellor", color: Constants.orangeLight),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
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
                        "Products Available",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "82% of the Products Avail.",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing: Chip(
                        label: Text(
                          "20,500",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
            ),
            //chart middle
            BarChartSample2(),
            Padding(
              padding: const EdgeInsets.only(
                left: Constants.kPadding / 2,
                right: Constants.kPadding / 2,
                top: Constants.kPadding,
              ),
              child: Card(
                color: Constants.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: List.generate(
                    _persons.length,
                    (index) => ListTile(
                      leading: CircleAvatar(
                        radius: 15,
                        child: Text(
                          _persons[index].name.substring(0, 1),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _persons[index].color,
                      ),
                      title: Text(
                        _persons[index].name,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.message,
                          color: Colors.white,
                        ),
                      ),
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
