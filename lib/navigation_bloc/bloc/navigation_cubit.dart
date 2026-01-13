import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_navigation/models/location.dart';
import 'package:mapbox_navigation/navigation_bloc/controller/mapbox_navigation_controller.dart';
import 'package:mapbox_navigation/navigation_bloc/state/navigation_state.dart';
export '../state/navigation_state.dart';

class NavigationCubit extends Cubit<NavigationUIState> {
  NavigationCubit({required this.mapBoxNavigationController})
    : super(NavigationUIState()) {
    _setupNavigationListeners();
  }

  final MapBoxNavigationController mapBoxNavigationController;

  void _setupNavigationListeners() {
    mapBoxNavigationController.stateStream.listen((value) {
      emit(state.copyWith(navigationState: value));
    });

    mapBoxNavigationController.navigationInfoStream.listen((info) {
      emit(state.copyWith(navigationInfo: info));
    });

    mapBoxNavigationController.voiceInstructionStream.listen((instruction) {
      emit(state.copyWith(instruction: instruction));

    });
  }

  calculateRoute(MapBoxPosition start, MapBoxPosition end) async {
    emit(state.copyWith(status: NavigationStatus.Loading));

    var result = await mapBoxNavigationController.startNavigation(
      start.toPosition(),
      end.toPosition(),
    );
    if (result != null) {
      emit(
        state.copyWith(
          route: result,
          end: end,
          start: start,
          status: NavigationStatus.Route_Calculated,
        ),
      );
    }
  }

  emitStartNavigation() async {
    if (state.route == null) return;
    var currentPosition = await Geolocator.getCurrentPosition();
    var location = Location.withCoords(
      "raw",
      currentPosition.latitude,
      currentPosition.longitude,
    );
    var navigationInfo = NavigationInfo(
      currentLocation: location,
      rawLocation: location,
      isOnRoute: true,
      remainingDistance: state.route?.totalDistance ?? 0,
      remainingTime: state.route?.estimatedTime ?? 0,
      currentSegmentIndex: 0,
      currentDirectionIndex: 0,
      currentDirection: state.route?.directions.isNotEmpty == true
          ? state.route!.directions.first
          : null,
      distanceToRoute: state.route?.directions.first.distance ?? 0,
      nextDirection: state.route?.directions.first,
      distanceToNextTurn: state.route?.directions.first.distance ?? 0,
    );

    emit(
      state.copyWith(
        status: NavigationStatus.Start_Navigation,
        navigationInfo: navigationInfo,
        navigationState: NavigationState.idle,
      ),
    );
  }
}
