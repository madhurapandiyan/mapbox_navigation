import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:mapbox_navigation/models/route.dart';
import 'package:mapbox_navigation/navigation_bloc/bloc/navigation_cubit.dart';
import 'package:mapbox_navigation/navigation_bloc/controller/mapbox_navigation_controller.dart';
import 'package:mapbox_navigation/navigation_bloc/widget/navigation_info_widget.dart';
import 'package:mapbox_navigation/navigation_bloc/widget/route_panel.dart';
import 'package:mapbox_navigation/navigation_bloc/widget/search_panel.dart';
import 'package:mapbox_navigation/service/text_to_speech.dart';
import 'package:mapbox_navigation/utils/map_utils%20copy.dart';

class MapBoxView extends StatefulWidget {
  const MapBoxView({super.key, required this.accessToken});
  final String accessToken;

  @override
  State<MapBoxView> createState() => _MapBoxViewState();
}

class _MapBoxViewState extends State<MapBoxView> with TickerProviderStateMixin {
  // Controller
  MapboxMap? mapBoxController;
  AnimationController? animationController;

  // Animation Value
  Animation<double>? animationValue;

  // Annotaion Manager
  PointAnnotationManager? pointAnnotationManager;

  PolylineAnnotationManager? polylineAnnotationManager;

  PointAnnotationManager? userLocationManager;

  // Annotation
  PointAnnotation? userMarkerAnnotaion;
  Uint8List? userNavigationIcon;

  // User Position
  Position? userPosition;

  // Animation Duration Parameter
  geo.Position? lastPosition;
  geo.Position? currentPosition;

  // Nav controller
  late MapBoxNavigationController mapBoxNavigationController;

  // TTS instance
  late TtsHelper _tts;

  Duration? _lastCalculatedDuration;
  static const double _durationSmoothingFactor = 0.3;

  // Listener
  StreamSubscription<geo.Position>? userLocationStream;

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(widget.accessToken);
    mapBoxNavigationController = MapBoxNavigationController();

    _tts = TtsHelper();
    _initializeTTS();

    animationController = AnimationController(vsync: this);
    userLocationStream = geo.Geolocator.getPositionStream(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.bestForNavigation,
      ),
    ).listen((event) => event);
    MapBoxUtils.getResizedImageBytes("asset/image/navigation_marker.png").then((
      value,
    ) {
      userNavigationIcon = value;
    });
  }

  Future<void> _initializeTTS() async {
    var voices = await _tts.getEnglishVoices();
    var usVoices = voices.where((element) {
      return element["locale"] == "en-US";
    }).toList();
    if (usVoices.isNotEmpty) {
      await _tts.setVoice(usVoices.last);
    }
  }

  onReceiveLocationData(geo.Position data) {
    currentPosition = data;
    mapBoxNavigationController.simulateLocation(
      data.latitude,
      data.longitude,
      accuracy: data.accuracy,
      bearing: data.heading,
      speed: data.speed,
    );
  }

  onReceiveNavigationInfo(NavigationInfo info) {
    var data = info.currentLocation.toPosition();
    var duration = _calculateAnimationDuration(data);
    animateListener(duration, data);
  }

  Duration _calculateAnimationDuration(geo.Position position) {
    if (lastPosition == null) {
      return const Duration(milliseconds: 500);
    }

    final double currentSpeed = position.speed > 0 ? position.speed : 0.0;
    final double lastSpeed = (lastPosition?.speed ?? 0.0) > 0
        ? lastPosition!.speed
        : 0.0;
    final double speedAvg = (currentSpeed + lastSpeed) / 2;

    final double distance = geo.Geolocator.distanceBetween(
      lastPosition!.latitude,
      lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    final Duration timeDiff = position.timestamp.difference(
      lastPosition!.timestamp,
    );

    Duration calculatedDuration;

    if (speedAvg > 0.5 && distance > 0.1) {
      final double estTimeSeconds = distance / speedAvg;
      final int estMs = (estTimeSeconds * 1000).toInt();
      calculatedDuration = Duration(
        milliseconds: math.max(estMs, timeDiff.inMilliseconds),
      );
    } else {
      calculatedDuration = timeDiff;
    }

    if (_lastCalculatedDuration != null) {
      final int lastMs = _lastCalculatedDuration!.inMilliseconds;
      final int newMs = calculatedDuration.inMilliseconds;
      final int smoothedMs =
          (lastMs * (1 - _durationSmoothingFactor) +
                  newMs * _durationSmoothingFactor)
              .round();
      calculatedDuration = Duration(milliseconds: smoothedMs);
    }

    final int clampedMs = calculatedDuration.inMilliseconds.clamp(100, 2000);
    _lastCalculatedDuration = Duration(milliseconds: clampedMs);
    return _lastCalculatedDuration!;
  }

  Future<void> _loadLocation() async {
    try {
      currentPosition = await geo.Geolocator.getCurrentPosition();
      userPosition = Position(
        currentPosition!.longitude,
        currentPosition!.latitude,
      );
      await mapBoxController?.location.updateSettings(
        LocationComponentSettings(enabled: false), // We use custom marker
      );
      Future.delayed(Duration(seconds: 1), () async {
        mapBoxController?.flyTo(
          CameraOptions(zoom: 17, center: Point(coordinates: userPosition!)),
          MapAnimationOptions(),
        );
        userMarkerAnnotaion = await userLocationManager?.create(
          /*     CircleAnnotationOptions(
            geometry: Point(coordinates: userPosition!),
            circleColor: Colors.blue.toARGB32(),
            circleRadius: 8,
            circleStrokeWidth: 4,
            circleStrokeColor: Colors.white.toARGB32(),
          ), */
          PointAnnotationOptions(
            geometry: Point(coordinates: userPosition!),
            image: userNavigationIcon,
          ),
        );
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _createAnnotationManagers() async {
    pointAnnotationManager = await mapBoxController?.annotations
        .createPointAnnotationManager();
    polylineAnnotationManager = await mapBoxController?.annotations
        .createPolylineAnnotationManager();
    userLocationManager = await mapBoxController?.annotations
        .createPointAnnotationManager();
  }

  animateListener(Duration duration, geo.Position position) {
    if (animationController?.isAnimating == true) {
      animationController!.stop();
    }

    // Capture start position BEFORE animation starts (this is the key fix!)
    final startCoords = userMarkerAnnotaion!.geometry.coordinates;
    final from = Position(startCoords.lng, startCoords.lat);
    final to = Position(position.longitude, position.latitude);
    print(duration);
    animationController?.dispose();
    animationController = AnimationController(
      vsync: this,
      duration: duration.abs(),
    );
    animationValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController!, curve: Curves.linear),
    );

    animationController?.addListener(() {
      final t = animationValue!.value;

      // Interpolate between captured start and end positions
      final lat = from.lat + (to.lat - from.lat) * t;
      final lng = from.lng + (to.lng - from.lng) * t;

      userMarkerAnnotaion?.geometry = Point(coordinates: Position(lng, lat));
      userLocationManager?.update(userMarkerAnnotaion!);
    });

    animationController?.forward(from: 0);

    animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        userPosition = to;
        lastPosition = position;
      }
    });

    animateCamera(position, duration);
  }

  animateCamera(geo.Position value, Duration duration) {
    mapBoxController?.easeTo(
      CameraOptions(
        zoom: 20,
        bearing: value.heading,
        center: Point(coordinates: Position(value.longitude, value.latitude)),
      ),
      MapAnimationOptions(duration: duration.inMilliseconds),
    );
  }

  Future<void> displayRoute(Route route, [bool animateCamera = true]) async {
    final points = route.locations
        .map((loc) => Position(loc.longitude, loc.latitude))
        .toList();

    await _createPolylineAnnotation(points);

    if (points.isNotEmpty && animateCamera) {
      // Calculate bounds
      double minLat = points.first.lat.toDouble();
      double maxLat = points.first.lat.toDouble();
      double minLng = points.first.lng.toDouble();
      double maxLng = points.first.lng.toDouble();

      for (var point in points) {
        if (point.lat < minLat) minLat = point.lat.toDouble();
        if (point.lat > maxLat) maxLat = point.lat.toDouble();
        if (point.lng < minLng) minLng = point.lng.toDouble();
        if (point.lng > maxLng) maxLng = point.lng.toDouble();
      }

      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      await mapBoxController?.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(centerLng, centerLat)),
          zoom: 13,
        ),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  Future<void> _createPolylineAnnotation(List<Position> route) async {
    await polylineAnnotationManager?.deleteAll();
    await polylineAnnotationManager?.create(
      PolylineAnnotationOptions(
        lineColor: const Color(0xFF1A73E8).toARGB32(),
        lineWidth: 10.0,
        lineJoin: LineJoin.ROUND,
        geometry: LineString(coordinates: route),
      ),
    );
  }

  void speakInstruction(String value) async {
    await _tts.speak(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationCubit>(
      create: (context) {
        return NavigationCubit(
          mapBoxNavigationController: mapBoxNavigationController,
        );
      },
      child: BlocListener<NavigationCubit, NavigationUIState>(
        listener: (context, state) {
          if (state.instruction != null) {
            speakInstruction(state.instruction!);
          }
        },
        child: Builder(
          builder: (context) {
            var ref = context.read<NavigationCubit>();
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size(
                  double.infinity,
                  MediaQuery.of(context).size.height * 0.3,
                ),
                child: BlocBuilder<NavigationCubit, NavigationUIState>(
                  builder: (context, state) {
                    if (state.status == NavigationStatus.Initial ||
                        state.status == NavigationStatus.Route_Calculated) {
                      return SearchPanel(
                        from: state.start,
                        to: state.end,
                        onSearch: (start, end) {
                          ref.calculateRoute(start, end);
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: MapWidget(
                          onMapCreated: (value) async {
                            mapBoxController = value;
                            await mapBoxController?.loadStyleURI(
                              // MapboxStyles.DARK,
                              // "mapbox://styles/mapbox/navigation-day-v1",
                              "mapbox://styles/mapbox/navigation-night-v1",
                              // "mapbox://styles/mapbox/navigation-preview-day-v4"
                            );
                            await _createAnnotationManagers();
                            _loadLocation();
                          },
                          onTapListener: (context) {},
                        ),
                      ),

                      BlocBuilder<NavigationCubit, NavigationUIState>(
                        builder: (context, state) {
                          if (state.status ==
                                  NavigationStatus.Start_Navigation ||
                              state.status ==
                                  NavigationStatus.Update_User_Location) {
                            onReceiveNavigationInfo(state.navigationInfo!);
                            return NavigationInfoWidget(
                              navigationState: state.navigationState!,
                              navigationInfo: state.navigationInfo!,
                              onStopNavigation: () {
                                userLocationStream?.cancel();
                              },
                              onReRoute: () {},
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                    ],
                  ),

                  BlocBuilder<NavigationCubit, NavigationUIState>(
                    builder: (context, state) {
                      if (state.status == NavigationStatus.Route_Calculated) {
                        displayRoute(state.route!);
                        return RoutePanel(
                          onCancel: () {
                            polylineAnnotationManager?.deleteAll();
                          },
                          onLiveGPSStarted: () {
                            if (userLocationStream?.isPaused == true) {
                              userLocationStream?.resume();
                            } else {
                              userLocationStream?.onData(onReceiveLocationData);
                            }
                            ref.emitStartNavigation();

                            animateCamera(
                              currentPosition!,
                              Duration(seconds: 1),
                            );
                          },
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController?.dispose();
    userLocationStream?.cancel();
    super.dispose();
  }
}
