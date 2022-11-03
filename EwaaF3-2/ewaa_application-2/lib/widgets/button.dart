import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({
    required this.color,
    required this.title,
    required this.onPeressed,
    required this.minwidth,
    required this.circular,
  });
  final Color color;
  final String title;
  final VoidCallback onPeressed;
  final double minwidth;
  final double circular;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 0,
        color: color,
        borderRadius: BorderRadius.circular(circular),
        child: MaterialButton(
          onPressed: onPeressed,
          minWidth: minwidth,
          height: 42,
          child: Text(
            title,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}

class MyButton2 extends StatelessWidget {
  MyButton2(
      {required this.color, required this.title, required this.onPeressed});
  final Color color;
  final String title;
  final VoidCallback onPeressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        onPressed: onPeressed,
        minWidth: 60,
        height: 10,
        child: Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'ElMessiri',
              fontSize: 13,
              fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
