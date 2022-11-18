import 'package:flutter/material.dart';

class ChipData {
  final String? label;
  final Color? backgrondColor;
  bool? isSelected;
  final String breeds;

  ChipData(
      {required this.label,
      required this.backgrondColor,
      required this.isSelected,
      required this.breeds});
}
