import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/app/features/notfication/domain/entity/notification_entity.dart';
import '../../../../core/common/app/features/notfication/presentation/bloc/notification_bloc.dart';
import '../../../../core/common/app/features/notfication/presentation/bloc/notification_event.dart';
import '../../../../core/common/app/features/notfication/presentation/bloc/notification_state.dart';
import 'dashboard_notification_menu.dart';

class DashboardNotificationsButton extends StatelessWidget {
  const DashboardNotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        debugPrint('🔔 NotificationBloc state => ${state.runtimeType}');
      },
      builder: (context, state) {
        if (state is NotificationInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<NotificationBloc>().add(
              LoadAllNotificationsEvent(),
            );
          });
        }

        int unreadCount = 0;
        List<NotificationEntity> notifications = [];

        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
          notifications = state.notifications;
        }

        return Builder(
          builder: (buttonContext) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: Icon(
                  Icons.notifications_outlined,
                  color: scheme.surface,
                ),
                onPressed: () => DashboardNotificationsMenu.show(
                  context: buttonContext,
                  state: state,
                  notifications: notifications,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}