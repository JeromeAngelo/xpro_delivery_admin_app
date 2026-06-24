import 'package:flutter/material.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/vehicle/vehicle_tags/domain/entity/vehicle_tag_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/vehicle_tags_enums.dart';

class VehicleTagsCard extends StatelessWidget {
  final List<VehicleTagEntity> tags;

  const VehicleTagsCard({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vehicle Tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${tags.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of tags
            if (tags.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tags associated with this vehicle',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        tags.map((t) => _buildTagRow(context, t)).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagRow(BuildContext context, VehicleTagEntity tag) {
    final types = tag.types ?? [];
    final meta =
        types.isNotEmpty
            ? _metaForType(types.first)
            : _metaForType(VehicleTagType.other);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: (meta['color'] as Color).withOpacity(0.1),
                  child: Icon(
                    meta['icon'] as IconData,
                    color: meta['color'] as Color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.label ?? 'Unnamed tag',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (tag.description != null &&
                          tag.description!.isNotEmpty)
                        Text(
                          tag.description!,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                if (tag.stickerNumber != null && tag.stickerNumber!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sticker #',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tag.stickerNumber!,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      ..._buildTypeChips(types),

                      _buildSpecChip(
                        icon: Icons.event,
                        label:
                            'Expires: ${_formatDate(tag.expiration ?? DateTime.now())}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.grey.shade700),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
      backgroundColor: Colors.grey.shade100,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  List<Widget> _buildTypeChips(List<VehicleTagType> types) {
    if (types.isEmpty) return [Chip(label: Text('No type'))];
    return types.map((t) {
      final meta = _metaForType(t);
      return Chip(
        label: Text(
          meta['label'] as String,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: meta['color'] as Color,
        avatar: Icon(meta['icon'] as IconData, size: 16, color: Colors.white),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }).toList();
  }

  Map<String, Object> _metaForType(VehicleTagType type) {
    switch (type) {
      case VehicleTagType.sticker:
        return {
          'label': 'Sticker',
          'color': Colors.indigo,
          'icon': Icons.sticky_note_2,
        };
      case VehicleTagType.restriction:
        return {
          'label': 'Restriction',
          'color': Colors.redAccent,
          'icon': Icons.block,
        };
      case VehicleTagType.permit:
        return {
          'label': 'Permit',
          'color': Colors.green,
          'icon': Icons.verified_user,
        };
      case VehicleTagType.other:
        return {
          'label': 'Other',
          'color': Colors.grey,
          'icon': Icons.label_outline,
        };
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
