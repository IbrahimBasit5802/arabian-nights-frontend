import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget tiny; //if size is too small
  final Widget phone;
  final Widget tablet;
  final Widget largeTablet;
  final Widget computer;


  const ResponsiveLayout({
    required this.tiny,
    required this.phone,
    required this.tablet,
    required this.largeTablet,
    required this.computer,
});

  static final int tinyHeightLimit = 100;
  static final int tinyLimit = 270;
  static final int phoneLimit = 550;
  static final int tabletLimit = 800;
  static final int largeTabletlimit = 1100;

  static bool isTinyHeightLimit(BuildContext context)=>
      MediaQuery.of(context).size.height < tinyHeightLimit;

  static bool isTiny(BuildContext context)=>
      MediaQuery.of(context).size.width < tinyLimit;

  static bool isPhone(BuildContext context)=>
      MediaQuery.of(context).size.width < phoneLimit &&
      MediaQuery.of(context).size.width >= tinyLimit;

  static bool isTablet(BuildContext context)=>
      MediaQuery.of(context).size.width < tabletLimit &&
          MediaQuery.of(context).size.width >= phoneLimit;

  static bool isLargeTablet(BuildContext context)=>
      MediaQuery.of(context).size.width < largeTabletlimit &&
          MediaQuery.of(context).size.width >= tabletLimit;

  static bool isComputer(BuildContext context)=>
      MediaQuery.of(context).size.width >= largeTabletlimit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
        if(constraints.maxHeight <tinyLimit || constraints.maxHeight<tinyHeightLimit){
          return tiny;
        }
        if(constraints.maxWidth <phoneLimit){
          return phone;
        }
        if(constraints.maxWidth <tabletLimit){
          return tablet;
        }
        if(constraints.maxWidth <largeTabletlimit){
          return largeTablet;
        }
        else{
          return computer;
        }
      },
    );
  }
}
