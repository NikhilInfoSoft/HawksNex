import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

CustomToast(BuildContext context, String title) {
  Toast.show(title, context);
}
