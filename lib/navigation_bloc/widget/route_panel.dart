import 'package:flutter/material.dart';

class RoutePanel extends StatelessWidget {
  const RoutePanel({
    super.key,
    required this.onCancel,
    required this.onLiveGPSStarted,
  });
  final VoidCallback onLiveGPSStarted;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /* Row(
                      children: [
                        _buildRouteInfoChip(
                          icon: Icons.timeline,
                          label: _currentRoute?.totalDistance != null
                              ? _formatDistance(_currentRoute!.totalDistance)
                              : '-- km',
                        ),
                        const SizedBox(width: 12),
                        _buildRouteInfoChip(
                          icon: Icons.access_time,
                          label: _currentRoute?.estimatedTime != null
                              ? _formatDuration(_currentRoute!.estimatedTime)
                              : '-- min',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), */
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onLiveGPSStarted,
                            icon: const Icon(Icons.navigation, size: 18),
                            label: const Text('Live GPS'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
