import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.title, required this.value, this.subtitle, this.icon, super.key});

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            if (icon != null) ...[
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(value, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
