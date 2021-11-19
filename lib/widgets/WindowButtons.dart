import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

WindowButtons({
  BuildContext context,
  Color color,
  bool back = false,
}) {
  return Container(
    color: color ?? Colors.white,
    child: Row(
      mainAxisAlignment:
          back ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        Visibility(
          visible: back,
          child: IconButton(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 14,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Row(
          children: [
            // MinimizeWindowButton(),
            // CloseWindowButton(),
          ],
        ),
      ],
    ),
  );
}
