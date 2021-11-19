import 'package:flutter/material.dart';
import 'package:hawks/widgets/ShiftRightFixer.dart';

Widget CustomTextField({
  String labelText,
  bool obscureText = false,
  Color color = Colors.grey,
  TextInputType keyboard,
  TextEditingController controller,
}) {
  return ShiftRightFixer(
    child: TextField(
      cursorColor: color,
      style: TextStyle(fontSize: 14, color: color),
      obscureText: obscureText,
      keyboardType: keyboard,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.bold,
          height: 0,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
          ),
        ),
      ),
    ),
  );
}
