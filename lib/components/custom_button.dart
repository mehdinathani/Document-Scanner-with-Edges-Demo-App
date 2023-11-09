import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final IconData buttonicon;
  final String buttonText;
  const CustomButton(
      {super.key,
      this.onPressed,
      required this.buttonicon,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(buttonicon),
            const SizedBox(
              width: 10,
            ),
            Text(
              buttonText,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
