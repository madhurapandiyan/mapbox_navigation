import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_suggestion_model.freezed.dart';
part 'place_suggestion_model.g.dart';

@freezed
abstract class PlaceSuggestionsResponse with _$PlaceSuggestionsResponse {
  const factory PlaceSuggestionsResponse({
    @Default([]) List<Suggestion> suggestions,
  }) = _PlaceSuggestionsResponse;

  factory PlaceSuggestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceSuggestionsResponseFromJson(json);
}

@freezed
abstract class Suggestion with _$Suggestion {
  const factory Suggestion({PlacePrediction? placePrediction}) = _Suggestion;

  factory Suggestion.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFromJson(json);
}

@freezed
abstract class PlacePrediction with _$PlacePrediction {
  const factory PlacePrediction({
    String? place,
    String? placeId,
    PlaceText? text,
    StructuredFormat? structuredFormat,
    double? latitude,
    double? longitude,
    @Default([]) List<String> types,
  }) = _PlacePrediction;

  factory PlacePrediction.fromJson(Map<String, dynamic> json) =>
      _$PlacePredictionFromJson(json);
}

@freezed
abstract class PlaceText with _$PlaceText {
  const factory PlaceText({
    String? text,
    @Default([]) List<TextMatch> matches,
  }) = _PlaceText;

  factory PlaceText.fromJson(Map<String, dynamic> json) =>
      _$PlaceTextFromJson(json);
}

@freezed
abstract class StructuredFormat with _$StructuredFormat {
  const factory StructuredFormat({
    PlaceText? mainText,
    PlaceText? secondaryText,
  }) = _StructuredFormat;

  factory StructuredFormat.fromJson(Map<String, dynamic> json) =>
      _$StructuredFormatFromJson(json);
}

@freezed
abstract class TextMatch with _$TextMatch {
  const factory TextMatch({int? endOffset}) = _TextMatch;

  factory TextMatch.fromJson(Map<String, dynamic> json) =>
      _$TextMatchFromJson(json);
}
