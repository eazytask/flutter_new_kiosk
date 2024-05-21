import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final child;
  final colorB;
  final double? height;
  final onTap;
  final double? width;
  const Button({
    super.key,
    @required this.child,
    @required this.onTap,
    this.width,
    @required this.colorB,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        // color: Colors.white.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorB,
          ),
          child: child,
        ),
      ),
    );
  }
}
