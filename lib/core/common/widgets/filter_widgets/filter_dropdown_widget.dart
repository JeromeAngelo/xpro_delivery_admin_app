import 'package:flutter/material.dart';

class FilterOption<T> {
  final String label;
  final T value;
  final bool isSelected;

  FilterOption({
    required this.label,
    required this.value,
    this.isSelected = false,
  });

  FilterOption<T> copyWith({
    String? label,
    T? value,
    bool? isSelected,
  }) {
    return FilterOption<T>(
      label: label ?? this.label,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class FilterDropdown<T> extends StatefulWidget {
  final String title;
  final List<FilterOption<T>> options;
  final Function(List<T>) onFilterChanged;
  final bool allowMultiple;
  final Widget? icon;
  final Color? activeColor;

  const FilterDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.onFilterChanged,
    this.allowMultiple = true,
    this.icon,
    this.activeColor,
  });

  @override
  State<FilterDropdown<T>> createState() => _FilterDropdownState<T>();
}

class _FilterDropdownState<T> extends State<FilterDropdown<T>> {
  late List<FilterOption<T>> _options;
  final GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.options);
  }

  @override
  void didUpdateWidget(FilterDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _options = List.from(widget.options);
    }
  }

  void _showFilterMenu(BuildContext context) {
    final RenderBox? renderBox =
        _filterKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    // ignore: unused_local_variable
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero)),
      ),
      Offset.zero &
          (Overlay.of(context).context.findRenderObject() as RenderBox).size,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by ${widget.title}'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.allowMultiple)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (int i = 0; i < _options.length; i++) {
                                _options[i] = _options[i].copyWith(isSelected: true);
                              }
                            });
                          },
                          child: const Text('Select All'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (int i = 0; i < _options.length; i++) {
                                _options[i] = _options[i].copyWith(isSelected: false);
                              }
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      return CheckboxListTile(
                        title: Text(option.label),
                        value: option.isSelected,
                        activeColor: widget.activeColor ?? Theme.of(context).colorScheme.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            if (widget.allowMultiple) {
                              _options[index] = option.copyWith(isSelected: value ?? false);
                            } else {
                              // Single selection mode
                              for (int i = 0; i < _options.length; i++) {
                                _options[i] = _options[i].copyWith(
                                  isSelected: i == index ? (value ?? false) : false,
                                );
                              }
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              child: const Text('Apply'),
              onPressed: () {
                // Get selected values
                final selectedValues = _options
                    .where((option) => option.isSelected)
                    .map((option) => option.value)
                    .toList();
                
                // Notify parent
                widget.onFilterChanged(selectedValues);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _options.where((option) => option.isSelected).length;
    final hasSelection = selectedCount > 0;

    return GestureDetector(
      key: _filterKey,
      onTap: () => _showFilterMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasSelection
              ? (widget.activeColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelection
                ? (widget.activeColor ?? Theme.of(context).colorScheme.primary)
                : Colors.grey.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: hasSelection ? FontWeight.bold : FontWeight.normal,
                color: hasSelection
                    ? (widget.activeColor ?? Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
            if (hasSelection) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (widget.activeColor ?? Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  selectedCount.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            widget.icon ??
                Icon(
                  Icons.arrow_drop_down,
                  color: hasSelection
                      ? (widget.activeColor ?? Theme.of(context).colorScheme.primary)
                      : null,
                ),
          ],
        ),
      ),
    );
  }
}
