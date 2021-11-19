import 'package:flutter/material.dart';

Widget CustomButton({
  Widget child,
  Color color = Colors.blue,
  Function onPressed,
  bool buttonClicked = false,
}) {
  return Container(
    width: double.infinity,
    height: 40,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
      ),
      onPressed: buttonClicked ? () {} : onPressed,
      child: buttonClicked
          ? Container(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  color == Colors.white ? Colors.blue : Colors.white,
                ),
              ),
            )
          : child,
    ),
  );
}
