import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFEE9E83), width: 2)));

Color backgroundColor = Colors.grey[200]!.withOpacity(1);
Color boxColor = Colors.white;
BorderRadius slidableBorderRadius =
    BorderRadius.horizontal(left: Radius.circular(7), right: Radius.zero);
