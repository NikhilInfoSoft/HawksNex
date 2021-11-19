import 'package:flutter/material.dart';

Widget CustomDropdown({
  @required int value,
  @required List items,
  Function onChange,
}) {
  return Container(
    width: double.infinity,
    height: 50,
    child: DropdownButtonFormField(
      onChanged: (value) {
        onChange(value);
      },
      itemHeight: 60,
      value: value,
      items: List.generate(items.length, (index) {
        return DropdownMenuItem(
          value: index,
          child: Text(items[index]['name'], style: TextStyle(fontSize: 12)),
        );
      }),
    ),
  );
}
