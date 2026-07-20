import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
  String get label => name;

  @override
  List<Object?> get props => [id, name, iconCodePoint, colorValue];
}
