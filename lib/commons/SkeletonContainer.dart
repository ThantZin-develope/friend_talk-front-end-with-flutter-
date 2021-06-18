import 'dart:core';

import 'package:flutter/material.dart';

import 'package:skeleton_loader/skeleton_loader.dart';

class SkeletonContainer extends StatelessWidget {
  double height;

  double width;
  double radius;

  SkeletonContainer({Key key, this.width, this.height, this.radius = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        child: SkeletonLoader(
          builder: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(this.radius),
            ),
          ),
        ));
  }
}
