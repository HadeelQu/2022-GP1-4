import 'package:ewaa_application/style.dart';
import 'package:flutter/material.dart';

class MyTextButton extends StatefulWidget {
  Function? onPressed;
  String? text;
  IconData? icon;
  MyTextButton({this.onPressed = null, this.text, this.icon});
  @override
  _MyTextButtonState createState() => _MyTextButtonState();
}

class _MyTextButtonState extends State<MyTextButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () {
            if (widget.onPressed != null) {
              widget.onPressed!.call();
            } else {
              Navigator.pop(context);
            }
          },
          child: Row(
            children: [
              Container(
                height: 50,
                padding: EdgeInsets.all(4.0),
                margin: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  widget.icon!,
                  size: 20,
                  color: Style.purpole,
                ),
              ),
              Text(
                widget.text!,
                style: TextStyle(
                    fontFamily: 'ElMessiri', fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}
