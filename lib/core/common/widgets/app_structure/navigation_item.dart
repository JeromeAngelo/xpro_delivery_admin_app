import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final List<NavigationItem>? children;
  final String? route;

  NavigationItem({
    required this.title,
    required this.icon,
    this.children,
    this.route,
  });
}
class SideNavigation extends StatefulWidget {
  final List<NavigationItem> items;
  final Function(String) onNavigate;
  final String currentRoute;
  final bool isCompact;
  final double width;

  const SideNavigation({
    super.key,
    required this.items,
    required this.onNavigate,
    required this.currentRoute,
    this.isCompact = false,
    this.width = 250,
  });

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  late Set<String> _expandedItems;

  @override
  void initState() {
    super.initState();
    _expandedItems = _getAllParentItemTitles();
  }

  Set<String> _getAllParentItemTitles() {
    final Set<String> parentTitles = {};
    
    for (var item in widget.items) {
      if (item.children != null && item.children!.isNotEmpty) {
        // Only auto-expand the parent of the current route
        if (_isCurrentRouteInChildren(item)) {
          parentTitles.add(item.title);
        }
      }
    }
    
    return parentTitles;
  }

  bool _isCurrentRouteInChildren(NavigationItem item) {
    if (item.route == widget.currentRoute) return true;
    
    if (item.children != null) {
      for (var child in item.children!) {
        if (child.route == widget.currentRoute) return true;
      }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isCompact ? 70 : widget.width,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _buildNavigationItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item) {
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.title);
    final isSelected = item.route == widget.currentRoute;
    final isChildSelected = hasChildren && 
        item.children!.any((child) => child.route == widget.currentRoute);

    return Column(
      children: [
        ListTile(
          dense: widget.isCompact,
          contentPadding: widget.isCompact
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 0)
              : null,
          leading: Icon(
            item.icon,
            color: (isSelected || isChildSelected) 
                ? Theme.of(context).colorScheme.primary 
                : null,
            size: widget.isCompact ? 24 : null,
          ),
          title: widget.isCompact
              ? null
              : Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: (isSelected || isChildSelected) 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    color: (isSelected || isChildSelected)
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
          trailing: widget.isCompact
              ? null
              : hasChildren
                  ? Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    )
                  : null,
          selected: isSelected,
          onTap: () {
            if (hasChildren && !widget.isCompact) {
              setState(() {
                if (isExpanded) {
                  _expandedItems.remove(item.title);
                } else {
                  _expandedItems.add(item.title);
                }
              });
              // Only navigate if it has both children AND a route
              if (item.route != null) {
                widget.onNavigate(item.route!);
              }
            } else if (item.route != null) {
              widget.onNavigate(item.route!);
            }
          },
          // Add tooltip for compact mode
     //     tooltip: widget.isCompact ? item.title : null,
        ),
        if (hasChildren && isExpanded && !widget.isCompact)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: item.children!.map((child) {
                final isChildSelected = child.route == widget.currentRoute;
                
                return ListTile(
                  dense: true,
                  leading: Icon(
                    child.icon,
                    size: 20,
                    color: isChildSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                  title: Text(
                    child.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isChildSelected 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      color: isChildSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                  ),
                  selected: isChildSelected,
                  onTap: () {
                    if (child.route != null) {
                      widget.onNavigate(child.route!);
                    }
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

