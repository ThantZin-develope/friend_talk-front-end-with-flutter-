import 'package:flutter/material.dart';

class SystemColors {
  static const Color errorColor = Colors.red;
  static const Color infoColor = Colors.yellow;
  static const Color successColor = Colors.green;

  static Color getReactionColors(int type) {
    Color color;
    switch (type) {
      case 0:
        {
          color = Colors.blue;
          break;
        }
      case 1:
        { 
          color = Colors.red[400];
          break;
        }
      case 2:
        {
          color = Colors.yellow[400];
          break;
        }
      case 3:
        {
          color = Colors.yellow[400];
          color = Colors.yellow[400];
          break;
        }
      case 4:
        {
          color = Colors.yellow[400];
          break;
        }
      case 5:
        {
          color = Colors.yellow[400];
          break;
        }
      case 6:
        {
          color = Colors.orange;
          break;
        }
      default:
        {
          color = Colors.green;
          break;
        }
    }
    return color;
  }
}
