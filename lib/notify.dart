import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'assets/colors.dart' as colors;

class Notify {
  void notifyError(
    BuildContext context,
    String message,
  ) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: colors.red.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void notifySuccess(
    BuildContext context,
    String message,
  ) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: colors.green.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}

final notify = Notify();