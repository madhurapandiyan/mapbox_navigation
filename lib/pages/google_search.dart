import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_navigation/models/place_suggestion_model.dart';

class GooglePlaceSearch extends StatefulWidget {
  const GooglePlaceSearch({super.key, this.text});

  final String? text;

  @override
  State<GooglePlaceSearch> createState() => _GooglePlaceSearchState();
}

class _GooglePlaceSearchState extends State<GooglePlaceSearch> {
  Future<void> getPlacesByKeyword(String value) async {
    try {
      isSearching.value = true;

      var key = "AIzaSyAlTKK3yAE2kTZOaKmkSurHn9XCwbK-L58";
      var result = await client.post(
        "/v1/places:autocomplete",
        queryParameters: {"key": key},
        data: {"input": value},
      );
      final data = PlaceSuggestionsResponse.fromJson(
        result.data as Map<String, dynamic>,
      );
      suggestions = data.suggestions;
      isSearching.value = false;
    } catch (e) {
      isSearching.value = false;
    }
  }

  List<Suggestion> suggestions = [];
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  late TextEditingController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();
    client = Dio(BaseOptions(baseUrl: "https://places.googleapis.com"))
      ..interceptors.add(LogInterceptor(request: true, responseBody: true));
    controller.addListener(() {
      debounce();
    });
    if (widget.text != null) {
      controller.text = widget.text!;
    }
  }

  Timer? timer;
  late Dio client;

  void debounce() {
    if (timer?.isActive ?? true) {
      timer?.cancel();
    }

    timer = Timer(Duration(seconds: 1), () async {
      await getPlacesByKeyword(controller.text);
    });
  }

  getPlaceDetail() async {
    try {
      var key = "AIzaSyAlTKK3yAE2kTZOaKmkSurHn9XCwbK-L58";
      var result = await client.get(
        "/v1/places/${selectedPrediction!.placeId}",
        options: Options(headers: {"X-Goog-FieldMask": "*"}),
        queryParameters: {"key": key},
      );
      if (result.data is Map) {
        if ((result.data as Map).containsKey("location")) {
          var location = result.data["location"];
          selectedPrediction = selectedPrediction?.copyWith(
            latitude: location["latitude"],
            longitude: location["longitude"],
          );
        }
      }
      print(selectedPrediction);
      Navigator.of(context).pop({
        "title": selectedPrediction?.text?.text,
        "longitude": double.parse(
          selectedPrediction!.longitude!.toStringAsFixed(7),
        ),
        "latitude": double.parse(
          selectedPrediction!.latitude!.toStringAsFixed(7),
        ),
        "id": selectedPrediction?.placeId,
        "type": "GoogleSearch",
      });
    } catch (e) {
      print(e);
    }
  }

  PlacePrediction? selectedPrediction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(
          double.infinity,
          MediaQuery.of(context).size.height * 0.2,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 80),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Search place",
                        suffix: IconButton(
                          onPressed: () {
                            controller.clear();
                          },
                          icon: Icon(Icons.close),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: isSearching,
        builder: (context, value, child) {
          return value
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    var result = suggestions[index];
                    return ListTile(
                      onTap: () {
                        try {
                          selectedPrediction = result.placePrediction;
                          getPlaceDetail();
                        } catch (e) {
                          print(e);
                        }
                      },
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      title: Text(
                        result.placePrediction?.text?.text ?? "No result",
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    timer?.cancel();
  }
}
