import 'package:flutter/material.dart';

import '../style.dart';

class TextFields extends StatefulWidget {
  final title;
  final icon;
  final TextInputType keyBoardType;
  final TextEditingController control;

  final validator;
  final suffix;
  var isPassward;

  TextFields(
    this.title,
    this.icon,
    this.keyBoardType,
    this.control,
    this.validator,
    this.suffix,
    this.isPassward,
  );
  @override
  State<TextFields> createState() => _TextFieldsState(
        title,
        icon,
        control,
        keyBoardType,
        validator,
        suffix,
        isPassward,
      );
}

class _TextFieldsState extends State<TextFields> {
  late final title;
  late final icon;
  late final control;
  late final TextInputType keyBoardType;
  late final validator;
  late final suffix;
  late var isPassward;

  //late final save;

  _TextFieldsState(this.title, this.icon, this.control, this.keyBoardType,
      this.validator, this.suffix, this.isPassward);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: control,
      validator: validator,
      keyboardType: keyBoardType,
      obscureText: isPassward,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(
            fontSize: 12, fontFamily: 'ElMessiri', color: Style.brown),
        prefixIcon: Icon(
          icon,
          color: Style.brown,
        ),
        suffixIcon: suffix == null
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    isPassward = !isPassward;
                  });
                },
                icon: Icon(
                  isPassward ? Icons.visibility : Icons.visibility_off,
                  color: Style.brown,
                ),
              ),
        fillColor: Style.textFieldsColor_lightpink,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Style.textFieldsColor_lightpink,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Style.textFieldsColor_lightpink,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: Style.buttonColor_pink,
          ),
        ),
      ),
    );
  }
}
