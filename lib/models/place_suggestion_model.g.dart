// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_suggestion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceSuggestionsResponse _$PlaceSuggestionsResponseFromJson(
  Map<String, dynamic> json,
) => _PlaceSuggestionsResponse(
  suggestions:
      (json['suggestions'] as List<dynamic>?)
          ?.map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlaceSuggestionsResponseToJson(
  _PlaceSuggestionsResponse instance,
) => <String, dynamic>{'suggestions': instance.suggestions};

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  placePrediction: json['placePrediction'] == null
      ? null
      : PlacePrediction.fromJson(
          json['placePrediction'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{'placePrediction': instance.placePrediction};

_PlacePrediction _$PlacePredictionFromJson(Map<String, dynamic> json) =>
    _PlacePrediction(
      place: json['place'] as String?,
      placeId: json['placeId'] as String?,
      text: json['text'] == null
          ? null
          : PlaceText.fromJson(json['text'] as Map<String, dynamic>),
      structuredFormat: json['structuredFormat'] == null
          ? null
          : StructuredFormat.fromJson(
              json['structuredFormat'] as Map<String, dynamic>,
            ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$PlacePredictionToJson(_PlacePrediction instance) =>
    <String, dynamic>{
      'place': instance.place,
      'placeId': instance.placeId,
      'text': instance.text,
      'structuredFormat': instance.structuredFormat,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'types': instance.types,
    };

_PlaceText _$PlaceTextFromJson(Map<String, dynamic> json) => _PlaceText(
  text: json['text'] as String?,
  matches:
      (json['matches'] as List<dynamic>?)
          ?.map((e) => TextMatch.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlaceTextToJson(_PlaceText instance) =>
    <String, dynamic>{'text': instance.text, 'matches': instance.matches};

_StructuredFormat _$StructuredFormatFromJson(Map<String, dynamic> json) =>
    _StructuredFormat(
      mainText: json['mainText'] == null
          ? null
          : PlaceText.fromJson(json['mainText'] as Map<String, dynamic>),
      secondaryText: json['secondaryText'] == null
          ? null
          : PlaceText.fromJson(json['secondaryText'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StructuredFormatToJson(_StructuredFormat instance) =>
    <String, dynamic>{
      'mainText': instance.mainText,
      'secondaryText': instance.secondaryText,
    };

_TextMatch _$TextMatchFromJson(Map<String, dynamic> json) =>
    _TextMatch(endOffset: (json['endOffset'] as num?)?.toInt());

Map<String, dynamic> _$TextMatchToJson(_TextMatch instance) =>
    <String, dynamic>{'endOffset': instance.endOffset};
