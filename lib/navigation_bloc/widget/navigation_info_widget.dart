import 'package:flutter/material.dart';
import 'package:mapbox_navigation/models/route.dart';
import 'package:mapbox_navigation/navigation_bloc/controller/mapbox_navigation_controller.dart';


class NavigationInfoWidget extends StatelessWidget {
  const NavigationInfoWidget({
    super.key,
    required this.navigationState,
    required this.navigationInfo,
    required this.onStopNavigation,
    required this.onReRoute,
  });
  final NavigationState navigationState;
  final NavigationInfo navigationInfo;
  final VoidCallback onStopNavigation;
  final VoidCallback onReRoute;

  Color _getStateColor() {
    switch (navigationState) {
      case NavigationState.navigating:
        return const Color(0xFF1A73E8);
      case NavigationState.offRoute:
        return Colors.orange;
      case NavigationState.recalculating:
        return Colors.orange;
      case NavigationState.arrived:
        return Colors.green;
      default:
        return const Color(0xFF1A73E8);
    }
  }

  IconData _getTurnIcon(TurnType turnType) {
    switch (turnType) {
      case TurnType.straight:
        return Icons.arrow_upward;
      case TurnType.slightLeft:
        return Icons.turn_slight_left;
      case TurnType.left:
        return Icons.turn_left;
      case TurnType.sharpLeft:
        return Icons.turn_sharp_left;
      case TurnType.slightRight:
        return Icons.turn_slight_right;
      case TurnType.right:
        return Icons.turn_right;
      case TurnType.sharpRight:
        return Icons.turn_sharp_right;
      case TurnType.uTurn:
        return Icons.u_turn_left;
      case TurnType.roundabout:
        return Icons.roundabout_left;
      case TurnType.finish:
        return Icons.flag;
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  Widget _buildNavStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var info = navigationInfo;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getStateColor().withOpacity(0.95),
            _getStateColor().withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Compass Enable",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    /* Switch.adaptive(
                      value: _isCompassEnabled,
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.black54,
                      inactiveTrackColor: Colors.grey,
                      onChanged: (value) {
                        _isCompassEnabled = value;
    
                        setState(() {});
                      },
                    ), */
                  ],
                ),
                if (info.nextDirection != null) ...[
                  SizedBox(height: 10),
                  Text(
                    info.nextDirection!.getDescription(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getTurnIcon(info.nextDirection!.turnType),
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDistance(info.distanceToNextTurn),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavStat(
                      label: 'Remaining',
                      value: info.remainingDistanceFormatted,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildNavStat(
                      label: 'ETA',
                      value: info.remainingTimeFormatted,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildNavStat(
                      label: 'Speed',
                      value:
                          '${(info.currentLocation.speed * 3.6).toStringAsFixed(0)} km/h',
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.black.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                // Row(
                //   children: [
                //     Icon(
                //       info.isOnRoute ? Icons.check_circle : Icons.warning,
                //       color: Colors.white,
                //       size: 18,
                //     ),
                //     const SizedBox(width: 8),
                //     Text(
                //       info.isOnRoute ? 'On Route' : 'Off Route',
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     if (_isSimulating)
                //       _buildModeBadge('SIM', Colors.deepPurple),
                //     if (_showRawGpsPanel) _buildModeBadge('RAW', Colors.teal),
                //   ],
                // ),
                Row(
                  children: [
                    // if (!_showRawGpsPanel && !_isSimulating)
                    //   TextButton(
                    //     onPressed: _toggleRawGpsPanel,
                    //     child: const Text(
                    //       'RAW GPS',
                    //       style: TextStyle(color: Colors.white70),
                    //     ),
                    //   ),
                    TextButton.icon(
                      onPressed: onReRoute,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Re Route",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),

                    SizedBox(width: 20),
                    TextButton.icon(
                      onPressed: onStopNavigation,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'End',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
