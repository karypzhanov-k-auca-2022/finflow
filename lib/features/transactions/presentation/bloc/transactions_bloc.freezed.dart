// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transactions_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionsState {

 TransactionsStatus get status; List<FinanceTransaction> get all; List<FinanceTransaction> get visible; TransactionFilter get filter; Failure? get failure;
/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionsStateCopyWith<TransactionsState> get copyWith => _$TransactionsStateCopyWithImpl<TransactionsState>(this as TransactionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.all, all)&&const DeepCollectionEquality().equals(other.visible, visible)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(all),const DeepCollectionEquality().hash(visible),filter,failure);

@override
String toString() {
  return 'TransactionsState(status: $status, all: $all, visible: $visible, filter: $filter, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $TransactionsStateCopyWith<$Res>  {
  factory $TransactionsStateCopyWith(TransactionsState value, $Res Function(TransactionsState) _then) = _$TransactionsStateCopyWithImpl;
@useResult
$Res call({
 TransactionsStatus status, List<FinanceTransaction> all, List<FinanceTransaction> visible, TransactionFilter filter, Failure? failure
});




}
/// @nodoc
class _$TransactionsStateCopyWithImpl<$Res>
    implements $TransactionsStateCopyWith<$Res> {
  _$TransactionsStateCopyWithImpl(this._self, this._then);

  final TransactionsState _self;
  final $Res Function(TransactionsState) _then;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? all = null,Object? visible = null,Object? filter = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionsStatus,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<FinanceTransaction>,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as List<FinanceTransaction>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as TransactionFilter,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionsState].
extension TransactionsStatePatterns on TransactionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionsState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionsState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransactionsStatus status,  List<FinanceTransaction> all,  List<FinanceTransaction> visible,  TransactionFilter filter,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
return $default(_that.status,_that.all,_that.visible,_that.filter,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransactionsStatus status,  List<FinanceTransaction> all,  List<FinanceTransaction> visible,  TransactionFilter filter,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _TransactionsState():
return $default(_that.status,_that.all,_that.visible,_that.filter,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransactionsStatus status,  List<FinanceTransaction> all,  List<FinanceTransaction> visible,  TransactionFilter filter,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
return $default(_that.status,_that.all,_that.visible,_that.filter,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionsState implements TransactionsState {
  const _TransactionsState({this.status = TransactionsStatus.initial, final  List<FinanceTransaction> all = const [], final  List<FinanceTransaction> visible = const [], this.filter = const TransactionFilter(), this.failure}): _all = all,_visible = visible;
  

@override@JsonKey() final  TransactionsStatus status;
 final  List<FinanceTransaction> _all;
@override@JsonKey() List<FinanceTransaction> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

 final  List<FinanceTransaction> _visible;
@override@JsonKey() List<FinanceTransaction> get visible {
  if (_visible is EqualUnmodifiableListView) return _visible;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_visible);
}

@override@JsonKey() final  TransactionFilter filter;
@override final  Failure? failure;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionsStateCopyWith<_TransactionsState> get copyWith => __$TransactionsStateCopyWithImpl<_TransactionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._all, _all)&&const DeepCollectionEquality().equals(other._visible, _visible)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_all),const DeepCollectionEquality().hash(_visible),filter,failure);

@override
String toString() {
  return 'TransactionsState(status: $status, all: $all, visible: $visible, filter: $filter, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$TransactionsStateCopyWith<$Res> implements $TransactionsStateCopyWith<$Res> {
  factory _$TransactionsStateCopyWith(_TransactionsState value, $Res Function(_TransactionsState) _then) = __$TransactionsStateCopyWithImpl;
@override @useResult
$Res call({
 TransactionsStatus status, List<FinanceTransaction> all, List<FinanceTransaction> visible, TransactionFilter filter, Failure? failure
});




}
/// @nodoc
class __$TransactionsStateCopyWithImpl<$Res>
    implements _$TransactionsStateCopyWith<$Res> {
  __$TransactionsStateCopyWithImpl(this._self, this._then);

  final _TransactionsState _self;
  final $Res Function(_TransactionsState) _then;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? all = null,Object? visible = null,Object? filter = null,Object? failure = freezed,}) {
  return _then(_TransactionsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionsStatus,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<FinanceTransaction>,visible: null == visible ? _self._visible : visible // ignore: cast_nullable_to_non_nullable
as List<FinanceTransaction>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as TransactionFilter,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
