import 'package:flutter/material.dart';

Widget CustomCheckBox({
  @required bool value,
  String text,
  Widget child,
  @required Function onChanged,
}) {
  return Row(
    children: [
      Checkbox(
        value: value,
        onChanged: onChanged,
      ),
      child != null ? child : Text(text),
    ],
  );
}
