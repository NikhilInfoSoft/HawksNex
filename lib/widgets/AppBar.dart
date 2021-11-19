import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawks/widgets/WindowButtons.dart';

Widget CustomAppBar({
  @required BuildContext context,
  String title,
  Color color,
}) {
  Color bgColor = color ?? Colors.white;

  return PreferredSize(
    preferredSize: Size.fromHeight(40),
    child: AppBar(
      title: Text(
        title ?? '',
        style: TextStyle(
          color: bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 14,
        ),
      ),
      elevation: 0.0,
      backgroundColor: bgColor,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: FaIcon(
          FontAwesomeIcons.arrowLeft,
          color: bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          size: 14,
        ),
      ),
      actions: [
        // WindowButtons(),
      ],
    ),
  );
}
