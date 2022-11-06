import 'package:flutter/material.dart';

import '../style.dart';

class FileldsAdd extends StatefulWidget {
  final title;

  final TextInputType keyBoardType;
  final TextEditingController control;
  final validator;
  final maxlines;
  final maxLength;

  FileldsAdd(this.title, this.control, this.keyBoardType, this.validator,
      this.maxlines, this.maxLength);

  @override
  State<FileldsAdd> createState() => _FileldsAddState(this.title, this.control,
      this.keyBoardType, this.validator, this.maxlines, this.maxLength);
}

class _FileldsAddState extends State<FileldsAdd> {
  late final title;

  late final control;
  late final TextInputType keyBoardType;
  late final validator;
  late final maxlines;
  late final maxLength;

  _FileldsAddState(this.title, this.control, this.keyBoardType, this.validator,
      this.maxlines, this.maxLength);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxlines,
      maxLength: maxLength,
      controller: control,
      validator: validator,
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        labelText: title,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'ElMessiri',
          color: Style.purpole,
        ),
        fillColor: Style.addBox,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Style.purpole,
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
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class FileldsAdd2 extends StatefulWidget {
  final title;

  final TextInputType keyBoardType;
  final TextEditingController control;
  final validator;
  final maxlines;
  final maxLength;

  FileldsAdd2(this.title, this.control, this.keyBoardType, this.validator,
      this.maxlines, this.maxLength);

  @override
  State<FileldsAdd2> createState() => _FileldsAdd2State(
      this.title,
      this.control,
      this.keyBoardType,
      this.validator,
      this.maxlines,
      this.maxLength);
}

class _FileldsAdd2State extends State<FileldsAdd2> {
  late final title;

  late final control;
  late final TextInputType keyBoardType;
  late final validator;
  late final maxlines;
  late final maxLength;

  _FileldsAdd2State(this.title, this.control, this.keyBoardType, this.validator,
      this.maxlines, this.maxLength);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxlines,
      maxLength: maxLength,
      controller: control,
      validator: validator,
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        labelText: title,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'ElMessiri',
          color: Style.purpole,
        ),
        fillColor: Style.addBox,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Style.purpole,
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
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
