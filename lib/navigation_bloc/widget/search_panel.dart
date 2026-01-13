import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_navigation/navigation_bloc/controller/mapbox_navigation_controller.dart';
import 'package:mapbox_navigation/pages/google_search.dart';
import 'package:mapbox_navigation/pages/settings_page.dart';


class SearchPanel extends StatefulWidget {
  SearchPanel({super.key, required this.onSearch, this.from, this.to});
  final Function(MapBoxPosition start, MapBoxPosition end) onSearch;
  MapBoxPosition? from;
  MapBoxPosition? to;
  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel>
    with AutomaticKeepAliveClientMixin {
  MapBoxPosition? _currentPosition;

  bool _isSelectingFrom = true;

  Widget _buildLocationTile({
    required IconData icon,
    required Color iconColor,
    required String hint,
    String? value,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onClear,
    Widget? myLocation,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 15,
                  color: value != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: value != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            myLocation ?? SizedBox(),
            // if (isSelected)
            //   Container(
            //     margin: const EdgeInsets.only(left: 8),
            //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //     decoration: BoxDecoration(
            //       color: Theme.of(context).colorScheme.primary,
            //       borderRadius: BorderRadius.circular(6),
            //     ),
            //     child: Text(
            //       'Tap map',
            //       style: TextStyle(
            //         fontSize: 11,
            //         color: Theme.of(context).colorScheme.onPrimary,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Navigation",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoutingSettingsPage(),
                      ),
                    );
                  },
                  child: CircleAvatar(child: Icon(Icons.settings)),
                ),
              ],
            ),
          ),
          _buildLocationTile(
            icon: Icons.trip_origin,
            iconColor: Colors.green,
            hint: 'Choose starting point',
            value: widget.from?.address,
            isSelected: _isSelectingFrom,
            // onTap: () => setState(() => _isSelectingFrom = true),
            onTap: () async {
              var result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GooglePlaceSearch(),
                ),
              );
              if (result != null) {
                // onOriginSelected(result);
                widget.from = MapBoxPosition(
                  longitude: result["longitude"],
                  latitude: result["latitude"],
                  address: result["title"],
                );
              }
              setState(() {});
            },
            onClear: () {
              setState(() {
                widget.from = null;
              });
            },
            myLocation: IconButton(
              onPressed: () async {
                try {
                  showLoading(context, "Fetching...");
                  var position = await geo.Geolocator.getCurrentPosition();

                  widget.from = MapBoxPosition(
                    longitude: double.parse(
                      position.longitude.toStringAsFixed(7),
                    ),
                    latitude: double.parse(
                      position.latitude.toStringAsFixed(7),
                    ),
                    address: "Your location",
                  );
                  _currentPosition = widget.from;

                  hideDialog(context);
                } catch (e) {
                  hideDialog(context);
                }
                setState(() {});
              },
              icon: Icon(Icons.my_location_rounded),
            ),
          ),
          Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.2)),
          _buildLocationTile(
            icon: Icons.location_on,
            iconColor: Colors.red,
            hint: 'Choose destination',
            value: widget.to?.address,
            isSelected: !_isSelectingFrom,
            // onTap: () => setState(() => _isSelectingFrom = false),
            onTap: () async {
              var result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GooglePlaceSearch(),
                ),
              );
              if (result != null) {
                // onOriginSelected(result);

                widget.to = MapBoxPosition(
                  longitude: result["longitude"],
                  latitude: result["latitude"],
                  address: result["title"],
                );
              }
              setState(() {});
            },
            onClear: () {
              setState(() {
                widget.to = null;
              });
            },
          ),
          if (widget.from != null && widget.to != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: FilledButton.icon(
                onPressed: () {
                  widget.onSearch(widget.from!, widget.to!);
                },
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay({String? text}) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                text ?? 'Calculating route...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  showLoading(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) {
        return _buildLoadingOverlay(text: text);
      },
    );
  }

  hideDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSearchPanel();
  }

  @override
  bool get wantKeepAlive => true;
}
