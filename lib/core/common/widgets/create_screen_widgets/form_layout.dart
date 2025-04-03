import 'package:flutter/material.dart';

class FormLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool isLoading;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  const FormLayout({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.isLoading = false,
    this.maxWidth = 1200, // Increased from 800 to allow more width
    this.padding = const EdgeInsets.all(24.0),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use LayoutBuilder to get the available width
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: padding,
                child: SizedBox(
                  // Make sure it takes the full width available
                  width: constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: crossAxisAlignment,
                    children: [
                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Form content in a Card for consistent styling with data table
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: children,
                          ),
                        ),
                      ),
                      
                      // Action buttons
                      if (actions != null) ...[
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        ),
                      ],
                      
                      // Bottom padding
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
