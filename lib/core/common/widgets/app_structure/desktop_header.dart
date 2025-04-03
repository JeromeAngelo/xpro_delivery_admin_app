import 'package:flutter/material.dart';

class DesktopHeader extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEditPressed;
  final VoidCallback? onMoreOptionsPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool showDivider;

  const DesktopHeader({
    super.key,
    required this.label,
    required this.value,
    this.onEditPressed,
    this.onMoreOptionsPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Label and Value
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: fontSize ?? 16.0,
                      color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    children: [
                      TextSpan(
                        text: '$label: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: value),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Right side: Action Icons
              Row(
                children: [
                  if (onMoreOptionsPressed != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'More Options',
                      onPressed: onMoreOptionsPressed,
                    ),
                  if (onEditPressed != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: onEditPressed,
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1),
      ],
    );
  }
}

// A more detailed version with additional features
class DetailedDesktopHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final Widget? leadingIcon;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool showDivider;

  const DetailedDesktopHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.leadingIcon,
    this.actions,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading icon if provided
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 16),
              ],
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$title: ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              if (actions != null && actions!.isNotEmpty)
                Row(
                  children: actions!,
                ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1),
      ],
    );
  }
}
