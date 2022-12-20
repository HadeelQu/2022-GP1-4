import 'package:flutter/material.dart';

class backButton extends StatefulWidget {
  Function? onPressed;
  backButton({this.onPressed = null});
  @override
  _backButtonState createState() => _backButtonState();
}

class _backButtonState extends State<backButton> {
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
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    'عودة',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      size: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
