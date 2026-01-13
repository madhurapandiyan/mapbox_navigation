import 'package:mapbox_navigation/models/route.dart';
import 'package:mapbox_navigation/navigation_bloc/controller/mapbox_navigation_controller.dart';

class NavigationUIState {
  final Route? route;
  final MapBoxPosition? start;
  final MapBoxPosition? end;
  final NavigationStatus status;
  final NavigationInfo? navigationInfo;
  final NavigationState? navigationState;
  final String? instruction;

  NavigationUIState({
    this.route,
    this.end,
    this.start,
    this.navigationInfo,
    this.navigationState,
    this.status = NavigationStatus.Initial,
    this.instruction,
  });

  NavigationUIState copyWith({
    Route? route,
    MapBoxPosition? start,
    MapBoxPosition? end,
    NavigationStatus? status,
    NavigationInfo? navigationInfo,
    NavigationState? navigationState,
    String? instruction,
  }) {
    return NavigationUIState(
      instruction: instruction,
      navigationState: navigationState ?? this.navigationState,
      navigationInfo: navigationInfo ?? this.navigationInfo,
      end: end ?? this.end,
      route: route ?? this.route,
      start: start ?? this.start,
      status: status ?? this.status,
    );
  }
}

enum NavigationStatus {
  Initial,
  Loading,
  Route_Calculated,
  Start_Navigation,
  Stop_Navigation,
  Update_User_Location,
}
