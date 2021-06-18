import 'dart:math';

import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:my_app/constants/SystemColors.dart';

class SystemIcons {
  static const Icon errorIcon =
      Icon(Icons.error, color: SystemColors.errorColor);
  static const Icon infoIcon = Icon(Icons.info, color: SystemColors.infoColor);
  static const Icon successIcon = Icon(
    Icons.check_circle,
    color: SystemColors.successColor,
  );
}

class SystemReactionImage {
  static Widget reactions(int index, double size) {
    Widget childWidget;
    switch (index) {
      case 0:
        {
          childWidget = Icon(
            
            AntIcons.like,
            color: Colors.blue,
            size: size,
          );

          break;
        }
      case 1:
        {
          childWidget = Image.asset(
            "assets/love.png",
            height: size,
            width: size,
            key: ValueKey(new Random().nextInt(100)),
          );
          break;
        }
      case 2:
        {
          childWidget = Image.asset(
            "assets/blush.png",
            height: size,
            width: size,
            key: ValueKey(new Random().nextInt(100)),
          );
          break;
        }
      case 3:
        {
          childWidget = Image.asset(
            "assets/haha.png",
            height: size,
            width: size,
            key: ValueKey(new Random().nextInt(100)),
          );
          break;
        }
      case 4:
        {
          childWidget = Image.asset(
            "assets/wow.png",
            height: size,
            width: size,
            key: ValueKey(new Random().nextInt(100)),
          );
          break;
        }
      case 5:
        {
          childWidget = Image.asset(
            "assets/sad.png",
            height: size,
            width: size,
            key: ValueKey(new Random().nextInt(100)),
          );
          break;
        }
      case 6:
        {
   
          childWidget = Image.asset(
            "assets/angry.png",
            height: size,
            width: size,
            key: ValueKey(new Random().nextInt(100)),
          );
          break;
        }
      default:
        {
          break;
        }
    }
    Widget parentWidget = ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: childWidget,
    );
    return parentWidget;
  }
}
