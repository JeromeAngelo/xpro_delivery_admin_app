import 'package:flutter/material.dart';

class DropdownItem<T> {
  final T value;
  final String label;
  final Widget? icon;
  final String uniqueId;
  final Widget? trailingIcon;
  final List<String>? searchTerms; // Additional search terms

  DropdownItem({
    required this.value,
    required this.label,
    this.trailingIcon,
    this.icon,
    required this.uniqueId,
    this.searchTerms, // Optional additional search terms
  });
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool required;
  final String? helperText;
  final bool enabled;
  final String? hintText;
  final double labelWidth;
  final List<T> selectedItems;
  final Function(List<T>)? onSelectedItemsChanged;
  final bool enableSearch; // Enable search functionality

  const AppDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.required = false,
    this.helperText,
    this.enabled = true,
    this.hintText,
    this.labelWidth = 200,
    this.selectedItems = const [],
    this.onSelectedItemsChanged,
    this.enableSearch = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with required indicator
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  children:
                      required
                          ? [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                          : null,
                ),
              ),
            ),
          ),

          // Dropdown field and selected items
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use a custom dropdown implementation that uses uniqueId for comparison
                _SearchableDropdownField<T>(
                  value: value,
                  items: items,
                  onChanged: onChanged,
                  hintText: hintText,
                  enabled: enabled,
                  validator: validator,
                  required: required,
                  selectedItems: selectedItems,
                  enableSearch: enableSearch,
                ),

                // Display selected items below the dropdown
                if (selectedItems.isNotEmpty && onSelectedItemsChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          selectedItems.map((item) {
                            // Find the corresponding dropdown item to get the label
                            final dropdownItem = items.firstWhere(
                              (dropItem) => dropItem.value == item,
                              orElse:
                                  () => DropdownItem<T>(
                                    value: item,
                                    label: 'Item',
                                    uniqueId: 'unknown',
                                  ),
                            );

                            return Chip(
                              label: Text(dropdownItem.label),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                final updatedList = List<T>.from(selectedItems);
                                updatedList.remove(item);
                                onSelectedItemsChanged!(updatedList);
                              },
                              avatar:
                                  dropdownItem.icon != null
                                      ? CircleAvatar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1),
                                        child: dropdownItem.icon,
                                      )
                                      : null,
                            );
                          }).toList(),
                    ),
                  ),

                if (helperText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    helperText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Searchable dropdown implementation
class _SearchableDropdownField<T> extends StatefulWidget {
  final T? value;
  final List<DropdownItem<T>> items;
  final void Function(T?) onChanged;
  final String? hintText;
  final bool enabled;
  final String? Function(T?)? validator;
  final bool required;
  final List<T> selectedItems;
  final bool enableSearch;

  const _SearchableDropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.enabled = true,
    this.validator,
    this.required = false,
    this.selectedItems = const [],
    this.enableSearch = true,
  });

  @override
  State<_SearchableDropdownField<T>> createState() =>
      _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T>
    extends State<_SearchableDropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _closeDropdown();
      }
    });
  }

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _searchController.clear();
    _searchQuery = '';

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    minWidth: size.width,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.enableSearch) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                                // Rebuild the overlay
                                _closeDropdown();
                                _openDropdown();
                              });
                            },
                            autofocus: true,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                      Flexible(child: _buildDropdownItems()),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() {
      _isOpen = false;
    });
  }

  Widget _buildDropdownItems() {
    // Filter items based on search query
    final filteredItems =
        widget.items.where((item) {
          if (_searchQuery.isEmpty) return true;

          // Search in label
          if (item.label.toLowerCase().contains(_searchQuery)) return true;

          // Search in additional search terms if available
          if (item.searchTerms != null) {
            for (final term in item.searchTerms!) {
              if (term.toLowerCase().contains(_searchQuery)) return true;
            }
          }

          return false;
        }).toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No items found'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final bool isSelected = widget.selectedItems.any(
          (selectedItem) => selectedItem == item.value,
        );

        return ListTile(
          dense: true,
          leading: item.icon,
          title: Text(
            item.label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing:
              isSelected
                  ? Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  )
                  : null,
          onTap: () {
            widget.onChanged(item.value);
            _closeDropdown();
          },
        );
      },
    );
  }

  // Find the uniqueId of the current value
  String? _getCurrentValueId() {
    if (widget.value != null) {
      for (var item in widget.items) {
        if (item.value == widget.value) {
          return item.uniqueId;
        }
      }
    }
    return null;
  }

  // Find the label of the current value
  String? _getCurrentValueLabel() {
    if (widget.value != null) {
      for (var item in widget.items) {
        if (item.value == widget.value) {
          return item.label;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentValueId = _getCurrentValueId();
    final currentValueLabel = _getCurrentValueLabel();

    return FormField<String>(
      initialValue: currentValueId,
      validator: (valueId) {
        if (widget.validator != null) {
          // Find the actual value from the uniqueId
          T? actualValue;
          if (valueId != null) {
            for (var item in widget.items) {
              if (item.uniqueId == valueId) {
                actualValue = item.value;
                break;
              }
            }
          }
          return widget.validator!(actualValue);
        }
        if (widget.required && valueId == null) {
          return 'This field is required';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            onTap: widget.enabled ? _toggleDropdown : null,
            child: InputDecorator(
              decoration: InputDecoration(
                errorText: state.errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ),
              isEmpty: currentValueId == null,
              child: Row(
                children: [
                  if (widget.value != null && currentValueLabel != null) ...[
                    // Show the selected item with its icon if available
                    for (var item in widget.items)
                      if (item.value == widget.value && item.icon != null) ...[
                        item.icon!,
                        const SizedBox(width: 8),
                      ],
                    Expanded(
                      child: Text(
                        currentValueLabel,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    // Show hint text
                    Expanded(
                      child: Text(
                        widget.hintText ?? 'Select an item',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
