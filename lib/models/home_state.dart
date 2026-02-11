import 'package:english_words/english_words.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required WordPair current,
    @Default([]) List<WordPair> history,
    @Default([]) List<WordPair> favorites,
    @Default(0) int selectedIndex,
  }) = _HomeState;
}
