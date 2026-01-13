import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_navigation/navigation_bloc/view/map_box_view.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await [Permission.locationWhenInUse].request().then((value) {
    Permission.locationAlways.request();
  });

  // runApp(const NavigationApp());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapBoxView(
        accessToken:
            AppEnv.mapBoxToken,
      ),
    );
  }
}

class AppEnv {
  static String googleApiKey = dotenv.get("googleMapApiKey");
  static String googlePlaceApiKey = dotenv.get("googleMapPlaceApiKey");

  static String mapBoxToken = dotenv.get("mapBoxToken");
}
