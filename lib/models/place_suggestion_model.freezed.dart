// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_suggestion_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceSuggestionsResponse {

 List<Suggestion> get suggestions;
/// Create a copy of PlaceSuggestionsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceSuggestionsResponseCopyWith<PlaceSuggestionsResponse> get copyWith => _$PlaceSuggestionsResponseCopyWithImpl<PlaceSuggestionsResponse>(this as PlaceSuggestionsResponse, _$identity);

  /// Serializes this PlaceSuggestionsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceSuggestionsResponse&&const DeepCollectionEquality().equals(other.suggestions, suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(suggestions));

@override
String toString() {
  return 'PlaceSuggestionsResponse(suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class $PlaceSuggestionsResponseCopyWith<$Res>  {
  factory $PlaceSuggestionsResponseCopyWith(PlaceSuggestionsResponse value, $Res Function(PlaceSuggestionsResponse) _then) = _$PlaceSuggestionsResponseCopyWithImpl;
@useResult
$Res call({
 List<Suggestion> suggestions
});




}
/// @nodoc
class _$PlaceSuggestionsResponseCopyWithImpl<$Res>
    implements $PlaceSuggestionsResponseCopyWith<$Res> {
  _$PlaceSuggestionsResponseCopyWithImpl(this._self, this._then);

  final PlaceSuggestionsResponse _self;
  final $Res Function(PlaceSuggestionsResponse) _then;

/// Create a copy of PlaceSuggestionsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? suggestions = null,}) {
  return _then(_self.copyWith(
suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<Suggestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceSuggestionsResponse].
extension PlaceSuggestionsResponsePatterns on PlaceSuggestionsResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceSuggestionsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceSuggestionsResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceSuggestionsResponse value)  $default,){
final _that = this;
switch (_that) {
case _PlaceSuggestionsResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceSuggestionsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceSuggestionsResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Suggestion> suggestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceSuggestionsResponse() when $default != null:
return $default(_that.suggestions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Suggestion> suggestions)  $default,) {final _that = this;
switch (_that) {
case _PlaceSuggestionsResponse():
return $default(_that.suggestions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Suggestion> suggestions)?  $default,) {final _that = this;
switch (_that) {
case _PlaceSuggestionsResponse() when $default != null:
return $default(_that.suggestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceSuggestionsResponse implements PlaceSuggestionsResponse {
  const _PlaceSuggestionsResponse({final  List<Suggestion> suggestions = const []}): _suggestions = suggestions;
  factory _PlaceSuggestionsResponse.fromJson(Map<String, dynamic> json) => _$PlaceSuggestionsResponseFromJson(json);

 final  List<Suggestion> _suggestions;
@override@JsonKey() List<Suggestion> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}


/// Create a copy of PlaceSuggestionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceSuggestionsResponseCopyWith<_PlaceSuggestionsResponse> get copyWith => __$PlaceSuggestionsResponseCopyWithImpl<_PlaceSuggestionsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceSuggestionsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceSuggestionsResponse&&const DeepCollectionEquality().equals(other._suggestions, _suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_suggestions));

@override
String toString() {
  return 'PlaceSuggestionsResponse(suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class _$PlaceSuggestionsResponseCopyWith<$Res> implements $PlaceSuggestionsResponseCopyWith<$Res> {
  factory _$PlaceSuggestionsResponseCopyWith(_PlaceSuggestionsResponse value, $Res Function(_PlaceSuggestionsResponse) _then) = __$PlaceSuggestionsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Suggestion> suggestions
});




}
/// @nodoc
class __$PlaceSuggestionsResponseCopyWithImpl<$Res>
    implements _$PlaceSuggestionsResponseCopyWith<$Res> {
  __$PlaceSuggestionsResponseCopyWithImpl(this._self, this._then);

  final _PlaceSuggestionsResponse _self;
  final $Res Function(_PlaceSuggestionsResponse) _then;

/// Create a copy of PlaceSuggestionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? suggestions = null,}) {
  return _then(_PlaceSuggestionsResponse(
suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<Suggestion>,
  ));
}


}


/// @nodoc
mixin _$Suggestion {

 PlacePrediction? get placePrediction;
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestionCopyWith<Suggestion> get copyWith => _$SuggestionCopyWithImpl<Suggestion>(this as Suggestion, _$identity);

  /// Serializes this Suggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Suggestion&&(identical(other.placePrediction, placePrediction) || other.placePrediction == placePrediction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placePrediction);

@override
String toString() {
  return 'Suggestion(placePrediction: $placePrediction)';
}


}

/// @nodoc
abstract mixin class $SuggestionCopyWith<$Res>  {
  factory $SuggestionCopyWith(Suggestion value, $Res Function(Suggestion) _then) = _$SuggestionCopyWithImpl;
@useResult
$Res call({
 PlacePrediction? placePrediction
});


$PlacePredictionCopyWith<$Res>? get placePrediction;

}
/// @nodoc
class _$SuggestionCopyWithImpl<$Res>
    implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._self, this._then);

  final Suggestion _self;
  final $Res Function(Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placePrediction = freezed,}) {
  return _then(_self.copyWith(
placePrediction: freezed == placePrediction ? _self.placePrediction : placePrediction // ignore: cast_nullable_to_non_nullable
as PlacePrediction?,
  ));
}
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlacePredictionCopyWith<$Res>? get placePrediction {
    if (_self.placePrediction == null) {
    return null;
  }

  return $PlacePredictionCopyWith<$Res>(_self.placePrediction!, (value) {
    return _then(_self.copyWith(placePrediction: value));
  });
}
}


/// Adds pattern-matching-related methods to [Suggestion].
extension SuggestionPatterns on Suggestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Suggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Suggestion value)  $default,){
final _that = this;
switch (_that) {
case _Suggestion():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Suggestion value)?  $default,){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlacePrediction? placePrediction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.placePrediction);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlacePrediction? placePrediction)  $default,) {final _that = this;
switch (_that) {
case _Suggestion():
return $default(_that.placePrediction);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlacePrediction? placePrediction)?  $default,) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.placePrediction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Suggestion implements Suggestion {
  const _Suggestion({this.placePrediction});
  factory _Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

@override final  PlacePrediction? placePrediction;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestionCopyWith<_Suggestion> get copyWith => __$SuggestionCopyWithImpl<_Suggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suggestion&&(identical(other.placePrediction, placePrediction) || other.placePrediction == placePrediction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placePrediction);

@override
String toString() {
  return 'Suggestion(placePrediction: $placePrediction)';
}


}

/// @nodoc
abstract mixin class _$SuggestionCopyWith<$Res> implements $SuggestionCopyWith<$Res> {
  factory _$SuggestionCopyWith(_Suggestion value, $Res Function(_Suggestion) _then) = __$SuggestionCopyWithImpl;
@override @useResult
$Res call({
 PlacePrediction? placePrediction
});


@override $PlacePredictionCopyWith<$Res>? get placePrediction;

}
/// @nodoc
class __$SuggestionCopyWithImpl<$Res>
    implements _$SuggestionCopyWith<$Res> {
  __$SuggestionCopyWithImpl(this._self, this._then);

  final _Suggestion _self;
  final $Res Function(_Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placePrediction = freezed,}) {
  return _then(_Suggestion(
placePrediction: freezed == placePrediction ? _self.placePrediction : placePrediction // ignore: cast_nullable_to_non_nullable
as PlacePrediction?,
  ));
}

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlacePredictionCopyWith<$Res>? get placePrediction {
    if (_self.placePrediction == null) {
    return null;
  }

  return $PlacePredictionCopyWith<$Res>(_self.placePrediction!, (value) {
    return _then(_self.copyWith(placePrediction: value));
  });
}
}


/// @nodoc
mixin _$PlacePrediction {

 String? get place; String? get placeId; PlaceText? get text; StructuredFormat? get structuredFormat; double? get latitude; double? get longitude; List<String> get types;
/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlacePredictionCopyWith<PlacePrediction> get copyWith => _$PlacePredictionCopyWithImpl<PlacePrediction>(this as PlacePrediction, _$identity);

  /// Serializes this PlacePrediction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlacePrediction&&(identical(other.place, place) || other.place == place)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.text, text) || other.text == text)&&(identical(other.structuredFormat, structuredFormat) || other.structuredFormat == structuredFormat)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.types, types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,place,placeId,text,structuredFormat,latitude,longitude,const DeepCollectionEquality().hash(types));

@override
String toString() {
  return 'PlacePrediction(place: $place, placeId: $placeId, text: $text, structuredFormat: $structuredFormat, latitude: $latitude, longitude: $longitude, types: $types)';
}


}

/// @nodoc
abstract mixin class $PlacePredictionCopyWith<$Res>  {
  factory $PlacePredictionCopyWith(PlacePrediction value, $Res Function(PlacePrediction) _then) = _$PlacePredictionCopyWithImpl;
@useResult
$Res call({
 String? place, String? placeId, PlaceText? text, StructuredFormat? structuredFormat, double? latitude, double? longitude, List<String> types
});


$PlaceTextCopyWith<$Res>? get text;$StructuredFormatCopyWith<$Res>? get structuredFormat;

}
/// @nodoc
class _$PlacePredictionCopyWithImpl<$Res>
    implements $PlacePredictionCopyWith<$Res> {
  _$PlacePredictionCopyWithImpl(this._self, this._then);

  final PlacePrediction _self;
  final $Res Function(PlacePrediction) _then;

/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? place = freezed,Object? placeId = freezed,Object? text = freezed,Object? structuredFormat = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? types = null,}) {
  return _then(_self.copyWith(
place: freezed == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as PlaceText?,structuredFormat: freezed == structuredFormat ? _self.structuredFormat : structuredFormat // ignore: cast_nullable_to_non_nullable
as StructuredFormat?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<$Res>? get text {
    if (_self.text == null) {
    return null;
  }

  return $PlaceTextCopyWith<$Res>(_self.text!, (value) {
    return _then(_self.copyWith(text: value));
  });
}/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredFormatCopyWith<$Res>? get structuredFormat {
    if (_self.structuredFormat == null) {
    return null;
  }

  return $StructuredFormatCopyWith<$Res>(_self.structuredFormat!, (value) {
    return _then(_self.copyWith(structuredFormat: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlacePrediction].
extension PlacePredictionPatterns on PlacePrediction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlacePrediction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlacePrediction value)  $default,){
final _that = this;
switch (_that) {
case _PlacePrediction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlacePrediction value)?  $default,){
final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? place,  String? placeId,  PlaceText? text,  StructuredFormat? structuredFormat,  double? latitude,  double? longitude,  List<String> types)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
return $default(_that.place,_that.placeId,_that.text,_that.structuredFormat,_that.latitude,_that.longitude,_that.types);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? place,  String? placeId,  PlaceText? text,  StructuredFormat? structuredFormat,  double? latitude,  double? longitude,  List<String> types)  $default,) {final _that = this;
switch (_that) {
case _PlacePrediction():
return $default(_that.place,_that.placeId,_that.text,_that.structuredFormat,_that.latitude,_that.longitude,_that.types);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? place,  String? placeId,  PlaceText? text,  StructuredFormat? structuredFormat,  double? latitude,  double? longitude,  List<String> types)?  $default,) {final _that = this;
switch (_that) {
case _PlacePrediction() when $default != null:
return $default(_that.place,_that.placeId,_that.text,_that.structuredFormat,_that.latitude,_that.longitude,_that.types);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlacePrediction implements PlacePrediction {
  const _PlacePrediction({this.place, this.placeId, this.text, this.structuredFormat, this.latitude, this.longitude, final  List<String> types = const []}): _types = types;
  factory _PlacePrediction.fromJson(Map<String, dynamic> json) => _$PlacePredictionFromJson(json);

@override final  String? place;
@override final  String? placeId;
@override final  PlaceText? text;
@override final  StructuredFormat? structuredFormat;
@override final  double? latitude;
@override final  double? longitude;
 final  List<String> _types;
@override@JsonKey() List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}


/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlacePredictionCopyWith<_PlacePrediction> get copyWith => __$PlacePredictionCopyWithImpl<_PlacePrediction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlacePredictionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlacePrediction&&(identical(other.place, place) || other.place == place)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.text, text) || other.text == text)&&(identical(other.structuredFormat, structuredFormat) || other.structuredFormat == structuredFormat)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._types, _types));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,place,placeId,text,structuredFormat,latitude,longitude,const DeepCollectionEquality().hash(_types));

@override
String toString() {
  return 'PlacePrediction(place: $place, placeId: $placeId, text: $text, structuredFormat: $structuredFormat, latitude: $latitude, longitude: $longitude, types: $types)';
}


}

/// @nodoc
abstract mixin class _$PlacePredictionCopyWith<$Res> implements $PlacePredictionCopyWith<$Res> {
  factory _$PlacePredictionCopyWith(_PlacePrediction value, $Res Function(_PlacePrediction) _then) = __$PlacePredictionCopyWithImpl;
@override @useResult
$Res call({
 String? place, String? placeId, PlaceText? text, StructuredFormat? structuredFormat, double? latitude, double? longitude, List<String> types
});


@override $PlaceTextCopyWith<$Res>? get text;@override $StructuredFormatCopyWith<$Res>? get structuredFormat;

}
/// @nodoc
class __$PlacePredictionCopyWithImpl<$Res>
    implements _$PlacePredictionCopyWith<$Res> {
  __$PlacePredictionCopyWithImpl(this._self, this._then);

  final _PlacePrediction _self;
  final $Res Function(_PlacePrediction) _then;

/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? place = freezed,Object? placeId = freezed,Object? text = freezed,Object? structuredFormat = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? types = null,}) {
  return _then(_PlacePrediction(
place: freezed == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as PlaceText?,structuredFormat: freezed == structuredFormat ? _self.structuredFormat : structuredFormat // ignore: cast_nullable_to_non_nullable
as StructuredFormat?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<$Res>? get text {
    if (_self.text == null) {
    return null;
  }

  return $PlaceTextCopyWith<$Res>(_self.text!, (value) {
    return _then(_self.copyWith(text: value));
  });
}/// Create a copy of PlacePrediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StructuredFormatCopyWith<$Res>? get structuredFormat {
    if (_self.structuredFormat == null) {
    return null;
  }

  return $StructuredFormatCopyWith<$Res>(_self.structuredFormat!, (value) {
    return _then(_self.copyWith(structuredFormat: value));
  });
}
}


/// @nodoc
mixin _$PlaceText {

 String? get text; List<TextMatch> get matches;
/// Create a copy of PlaceText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<PlaceText> get copyWith => _$PlaceTextCopyWithImpl<PlaceText>(this as PlaceText, _$identity);

  /// Serializes this PlaceText to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceText&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.matches, matches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(matches));

@override
String toString() {
  return 'PlaceText(text: $text, matches: $matches)';
}


}

/// @nodoc
abstract mixin class $PlaceTextCopyWith<$Res>  {
  factory $PlaceTextCopyWith(PlaceText value, $Res Function(PlaceText) _then) = _$PlaceTextCopyWithImpl;
@useResult
$Res call({
 String? text, List<TextMatch> matches
});




}
/// @nodoc
class _$PlaceTextCopyWithImpl<$Res>
    implements $PlaceTextCopyWith<$Res> {
  _$PlaceTextCopyWithImpl(this._self, this._then);

  final PlaceText _self;
  final $Res Function(PlaceText) _then;

/// Create a copy of PlaceText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? matches = null,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as List<TextMatch>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceText].
extension PlaceTextPatterns on PlaceText {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceText value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceText() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceText value)  $default,){
final _that = this;
switch (_that) {
case _PlaceText():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceText value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceText() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  List<TextMatch> matches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceText() when $default != null:
return $default(_that.text,_that.matches);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  List<TextMatch> matches)  $default,) {final _that = this;
switch (_that) {
case _PlaceText():
return $default(_that.text,_that.matches);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  List<TextMatch> matches)?  $default,) {final _that = this;
switch (_that) {
case _PlaceText() when $default != null:
return $default(_that.text,_that.matches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceText implements PlaceText {
  const _PlaceText({this.text, final  List<TextMatch> matches = const []}): _matches = matches;
  factory _PlaceText.fromJson(Map<String, dynamic> json) => _$PlaceTextFromJson(json);

@override final  String? text;
 final  List<TextMatch> _matches;
@override@JsonKey() List<TextMatch> get matches {
  if (_matches is EqualUnmodifiableListView) return _matches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matches);
}


/// Create a copy of PlaceText
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceTextCopyWith<_PlaceText> get copyWith => __$PlaceTextCopyWithImpl<_PlaceText>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceTextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceText&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._matches, _matches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_matches));

@override
String toString() {
  return 'PlaceText(text: $text, matches: $matches)';
}


}

/// @nodoc
abstract mixin class _$PlaceTextCopyWith<$Res> implements $PlaceTextCopyWith<$Res> {
  factory _$PlaceTextCopyWith(_PlaceText value, $Res Function(_PlaceText) _then) = __$PlaceTextCopyWithImpl;
@override @useResult
$Res call({
 String? text, List<TextMatch> matches
});




}
/// @nodoc
class __$PlaceTextCopyWithImpl<$Res>
    implements _$PlaceTextCopyWith<$Res> {
  __$PlaceTextCopyWithImpl(this._self, this._then);

  final _PlaceText _self;
  final $Res Function(_PlaceText) _then;

/// Create a copy of PlaceText
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? matches = null,}) {
  return _then(_PlaceText(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,matches: null == matches ? _self._matches : matches // ignore: cast_nullable_to_non_nullable
as List<TextMatch>,
  ));
}


}


/// @nodoc
mixin _$StructuredFormat {

 PlaceText? get mainText; PlaceText? get secondaryText;
/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StructuredFormatCopyWith<StructuredFormat> get copyWith => _$StructuredFormatCopyWithImpl<StructuredFormat>(this as StructuredFormat, _$identity);

  /// Serializes this StructuredFormat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StructuredFormat&&(identical(other.mainText, mainText) || other.mainText == mainText)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mainText,secondaryText);

@override
String toString() {
  return 'StructuredFormat(mainText: $mainText, secondaryText: $secondaryText)';
}


}

/// @nodoc
abstract mixin class $StructuredFormatCopyWith<$Res>  {
  factory $StructuredFormatCopyWith(StructuredFormat value, $Res Function(StructuredFormat) _then) = _$StructuredFormatCopyWithImpl;
@useResult
$Res call({
 PlaceText? mainText, PlaceText? secondaryText
});


$PlaceTextCopyWith<$Res>? get mainText;$PlaceTextCopyWith<$Res>? get secondaryText;

}
/// @nodoc
class _$StructuredFormatCopyWithImpl<$Res>
    implements $StructuredFormatCopyWith<$Res> {
  _$StructuredFormatCopyWithImpl(this._self, this._then);

  final StructuredFormat _self;
  final $Res Function(StructuredFormat) _then;

/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mainText = freezed,Object? secondaryText = freezed,}) {
  return _then(_self.copyWith(
mainText: freezed == mainText ? _self.mainText : mainText // ignore: cast_nullable_to_non_nullable
as PlaceText?,secondaryText: freezed == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as PlaceText?,
  ));
}
/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<$Res>? get mainText {
    if (_self.mainText == null) {
    return null;
  }

  return $PlaceTextCopyWith<$Res>(_self.mainText!, (value) {
    return _then(_self.copyWith(mainText: value));
  });
}/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<$Res>? get secondaryText {
    if (_self.secondaryText == null) {
    return null;
  }

  return $PlaceTextCopyWith<$Res>(_self.secondaryText!, (value) {
    return _then(_self.copyWith(secondaryText: value));
  });
}
}


/// Adds pattern-matching-related methods to [StructuredFormat].
extension StructuredFormatPatterns on StructuredFormat {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StructuredFormat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StructuredFormat() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StructuredFormat value)  $default,){
final _that = this;
switch (_that) {
case _StructuredFormat():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StructuredFormat value)?  $default,){
final _that = this;
switch (_that) {
case _StructuredFormat() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlaceText? mainText,  PlaceText? secondaryText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StructuredFormat() when $default != null:
return $default(_that.mainText,_that.secondaryText);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlaceText? mainText,  PlaceText? secondaryText)  $default,) {final _that = this;
switch (_that) {
case _StructuredFormat():
return $default(_that.mainText,_that.secondaryText);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlaceText? mainText,  PlaceText? secondaryText)?  $default,) {final _that = this;
switch (_that) {
case _StructuredFormat() when $default != null:
return $default(_that.mainText,_that.secondaryText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StructuredFormat implements StructuredFormat {
  const _StructuredFormat({this.mainText, this.secondaryText});
  factory _StructuredFormat.fromJson(Map<String, dynamic> json) => _$StructuredFormatFromJson(json);

@override final  PlaceText? mainText;
@override final  PlaceText? secondaryText;

/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StructuredFormatCopyWith<_StructuredFormat> get copyWith => __$StructuredFormatCopyWithImpl<_StructuredFormat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StructuredFormatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StructuredFormat&&(identical(other.mainText, mainText) || other.mainText == mainText)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mainText,secondaryText);

@override
String toString() {
  return 'StructuredFormat(mainText: $mainText, secondaryText: $secondaryText)';
}


}

/// @nodoc
abstract mixin class _$StructuredFormatCopyWith<$Res> implements $StructuredFormatCopyWith<$Res> {
  factory _$StructuredFormatCopyWith(_StructuredFormat value, $Res Function(_StructuredFormat) _then) = __$StructuredFormatCopyWithImpl;
@override @useResult
$Res call({
 PlaceText? mainText, PlaceText? secondaryText
});


@override $PlaceTextCopyWith<$Res>? get mainText;@override $PlaceTextCopyWith<$Res>? get secondaryText;

}
/// @nodoc
class __$StructuredFormatCopyWithImpl<$Res>
    implements _$StructuredFormatCopyWith<$Res> {
  __$StructuredFormatCopyWithImpl(this._self, this._then);

  final _StructuredFormat _self;
  final $Res Function(_StructuredFormat) _then;

/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mainText = freezed,Object? secondaryText = freezed,}) {
  return _then(_StructuredFormat(
mainText: freezed == mainText ? _self.mainText : mainText // ignore: cast_nullable_to_non_nullable
as PlaceText?,secondaryText: freezed == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as PlaceText?,
  ));
}

/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<$Res>? get mainText {
    if (_self.mainText == null) {
    return null;
  }

  return $PlaceTextCopyWith<$Res>(_self.mainText!, (value) {
    return _then(_self.copyWith(mainText: value));
  });
}/// Create a copy of StructuredFormat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceTextCopyWith<$Res>? get secondaryText {
    if (_self.secondaryText == null) {
    return null;
  }

  return $PlaceTextCopyWith<$Res>(_self.secondaryText!, (value) {
    return _then(_self.copyWith(secondaryText: value));
  });
}
}


/// @nodoc
mixin _$TextMatch {

 int? get endOffset;
/// Create a copy of TextMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextMatchCopyWith<TextMatch> get copyWith => _$TextMatchCopyWithImpl<TextMatch>(this as TextMatch, _$identity);

  /// Serializes this TextMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextMatch&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,endOffset);

@override
String toString() {
  return 'TextMatch(endOffset: $endOffset)';
}


}

/// @nodoc
abstract mixin class $TextMatchCopyWith<$Res>  {
  factory $TextMatchCopyWith(TextMatch value, $Res Function(TextMatch) _then) = _$TextMatchCopyWithImpl;
@useResult
$Res call({
 int? endOffset
});




}
/// @nodoc
class _$TextMatchCopyWithImpl<$Res>
    implements $TextMatchCopyWith<$Res> {
  _$TextMatchCopyWithImpl(this._self, this._then);

  final TextMatch _self;
  final $Res Function(TextMatch) _then;

/// Create a copy of TextMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? endOffset = freezed,}) {
  return _then(_self.copyWith(
endOffset: freezed == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TextMatch].
extension TextMatchPatterns on TextMatch {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextMatch() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextMatch value)  $default,){
final _that = this;
switch (_that) {
case _TextMatch():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextMatch value)?  $default,){
final _that = this;
switch (_that) {
case _TextMatch() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? endOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextMatch() when $default != null:
return $default(_that.endOffset);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? endOffset)  $default,) {final _that = this;
switch (_that) {
case _TextMatch():
return $default(_that.endOffset);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? endOffset)?  $default,) {final _that = this;
switch (_that) {
case _TextMatch() when $default != null:
return $default(_that.endOffset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextMatch implements TextMatch {
  const _TextMatch({this.endOffset});
  factory _TextMatch.fromJson(Map<String, dynamic> json) => _$TextMatchFromJson(json);

@override final  int? endOffset;

/// Create a copy of TextMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextMatchCopyWith<_TextMatch> get copyWith => __$TextMatchCopyWithImpl<_TextMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextMatch&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,endOffset);

@override
String toString() {
  return 'TextMatch(endOffset: $endOffset)';
}


}

/// @nodoc
abstract mixin class _$TextMatchCopyWith<$Res> implements $TextMatchCopyWith<$Res> {
  factory _$TextMatchCopyWith(_TextMatch value, $Res Function(_TextMatch) _then) = __$TextMatchCopyWithImpl;
@override @useResult
$Res call({
 int? endOffset
});




}
/// @nodoc
class __$TextMatchCopyWithImpl<$Res>
    implements _$TextMatchCopyWith<$Res> {
  __$TextMatchCopyWithImpl(this._self, this._then);

  final _TextMatch _self;
  final $Res Function(_TextMatch) _then;

/// Create a copy of TextMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? endOffset = freezed,}) {
  return _then(_TextMatch(
endOffset: freezed == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
