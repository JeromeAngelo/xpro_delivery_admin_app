import 'dart:async';

import 'package:flutter/material.dart';

class VehicleSearchingLoader extends StatefulWidget {
  const VehicleSearchingLoader({super.key});

  @override
  State<VehicleSearchingLoader> createState() =>
      _VehicleSearchingLoaderState();
}

class _VehicleSearchingLoaderState extends State<VehicleSearchingLoader>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _truckController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _truckAnimation;

  final List<String> _messages = [
    "Connecting to GPS...",
    "Searching latest vehicle location...",
    "Receiving satellite coordinates...",
    "Loading delivery route...",
    "Preparing trip map...",
  ];

  int _messageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: .5,
      end: 1.4,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _truckAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: _truckController,
        curve: Curves.easeInOut,
      ),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!mounted) return;

        setState(() {
          _messageIndex =
              (_messageIndex + 1) % _messages.length;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _truckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [

                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, __) {
                    return Container(
                      width: 120 * _pulseAnimation.value,
                      height: 120 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(
                          .12 * (1 - _pulseController.value),
                        ),
                      ),
                    );
                  },
                ),

                AnimatedBuilder(
                  animation: _truckAnimation,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(_truckAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.local_shipping_rounded,
                    size: 70,
                    color: color,
                  ),
                ),

                Positioned(
                  top: 18,
                  child: Icon(
                    Icons.gps_fixed,
                    size: 28,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _messages[_messageIndex],
              key: ValueKey(_messageIndex),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: const LinearProgressIndicator(
                minHeight: 8,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "Please wait while the latest trip coordinates are loaded.",
            style: Theme.of(context)
                .textTheme
                .bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}