import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class TLoaders {
  static hideSnackBar(BuildContext context) =>
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

  static void customToast(
      {required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppHelperFunctions.isDarkMode(context)
                ? AppColors.darkerGrey.withOpacity(0.9)
                : AppColors.grey.withOpacity(0.9),
          ),
          child: Center(
              child:
                  Text(message, style: Theme.of(context).textTheme.labelLarge)),
        ),
      ),
    );
  }

  static void successSnackBar({
    required BuildContext context,
    required String title,
    String message = '',
    int duration = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title\n$message',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  static void warningSnackBar({
    required BuildContext context,
    required String title,
    String message = '',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppColors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title\n$message',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  static void errorSnackBar({
    required BuildContext context,
    required String title,
    String message = '',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.xmark_circle, color: AppColors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title\n$message',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}
