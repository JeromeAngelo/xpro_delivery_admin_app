import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/app/features/notfication/domain/entity/notification_entity.dart';
import '../../../../core/common/app/features/notfication/presentation/bloc/notification_bloc.dart';
import '../../../../core/common/app/features/notfication/presentation/bloc/notification_event.dart';
import '../../../../core/common/app/features/notfication/presentation/bloc/notification_state.dart';

class DashboardNotificationsMenu {
  static Future<void> show({
    required BuildContext context,
    required NotificationState state,
    required List<NotificationEntity> notifications,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero, ancestor: overlay);

    final relativeRect = RelativeRect.fromLTRB(
      position.dx,
      position.dy + box.size.height,
      overlay.size.width - position.dx - box.size.width,
      overlay.size.height - position.dy,
    );

    List<PopupMenuEntry<int>> items;

    if (state is NotificationLoading) {
      items = const [
        PopupMenuItem<int>(
          enabled: false,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading notifications...'),
            ],
          ),
        ),
      ];
    } else if (state is NotificationError) {
      items = [
        PopupMenuItem<int>(
          enabled: false,
          child: Text('Error: ${state.message}'),
        ),
      ];
    } else if (notifications.isEmpty) {
      items = const [
        PopupMenuItem<int>(
          enabled: false,
          child: Text('No notifications'),
        ),
      ];
    } else {
      final showList = notifications.take(30).toList();

      items = [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 380,
              maxWidth: 460,
              maxHeight: 420,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(showList.length, (index) {
                    final notif = showList[index];

                    final tripName =
                        notif.trip?.name ??
                        (notif.trip?.id != null ? notif.trip!.id : 'unknown');

                    final statusText =
                        notif.status?.title ??
                        (notif.trip?.tripNumberId != null
                            ? notif.trip!.tripNumberId
                            : 'unknown');

                    final message =
                        "The Trip $tripName set status of $statusText in the ${notif.delivery?.customer?.name ?? 'delivery'}";

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);

                        final id = notif.id;
                        if (id != null && id.isNotEmpty) {
                          context.read<NotificationBloc>().add(
                            MarkAsReadEvent(id),
                          );
                        }

                        context.go('/delivery-monitoring');
                      },
                      child: Column(
                        children: [
                          ListTile(
                            dense: true,
                            leading: Icon(
                              (notif.isRead ?? false)
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: (notif.isRead ?? false)
                                  ? Colors.grey
                                  : Colors.red,
                              size: 22,
                            ),
                            title: Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: (notif.isRead ?? false)
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: (notif.body != null &&
                                    notif.body!.trim().isNotEmpty)
                                ? Text(
                                    notif.body!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    await showMenu<int>(
      context: context,
      position: relativeRect,
      items: items,
    );
  }
}