import 'package:flutter/material.dart';

class FormSectionTitle extends StatelessWidget {
  final String title;
  final bool showDivider;

  const FormSectionTitle({
    super.key,
    required this.title,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 8),
          Divider(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
