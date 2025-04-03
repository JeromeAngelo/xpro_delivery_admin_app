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

  const SideNavigation({
    super.key,
    required this.items,
    required this.onNavigate,
    required this.currentRoute,
  });

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  // Initialize with all items expanded
  late Set<String> _expandedItems;

  @override
  void initState() {
    super.initState();
    // Initialize all parent items as expanded
    _expandedItems = _getAllParentItemTitles();
  }

  // Get all parent item titles to initialize them as expanded
  Set<String> _getAllParentItemTitles() {
    final Set<String> parentTitles = {};
    
    for (var item in widget.items) {
      if (item.children != null && item.children!.isNotEmpty) {
        parentTitles.add(item.title);
      }
    }
    
    return parentTitles;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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

  return Column(
    children: [
      ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        trailing: hasChildren
            ? Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              )
            : null,
        selected: isSelected,
        onTap: () {
          if (hasChildren) {
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
      ),
      if (hasChildren && isExpanded)
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
                  color: isChildSelected ? Theme.of(context).primaryColor : null,
                ),
                title: Text(
                  child.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isChildSelected ? FontWeight.bold : FontWeight.normal,
                    color: isChildSelected ? Theme.of(context).primaryColor : null,
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
