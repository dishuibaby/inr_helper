import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({required this.title, required this.value, this.icon, super.key});

  final String title;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon == null ? null : Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
