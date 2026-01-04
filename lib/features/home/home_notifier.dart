import 'package:english_words/english_words.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fy25_flutter_hands_on/features/home/home_state.dart';

export 'package:fy25_flutter_hands_on/features/home/home_state.dart';

final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(current: WordPair.random());
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void getNext() {
    final newHistory = [state.current, ...state.history];
    state = state.copyWith(
      history: newHistory,
      current: WordPair.random(),
    );
  }

  void toggleFavorite([WordPair? pair]) {
    final target = pair ?? state.current;
    final currentFavorites = state.favorites;
    if (currentFavorites.contains(target)) {
      state = state.copyWith(
          favorites: currentFavorites.where((p) => p != target).toList());
    } else {
      state = state.copyWith(favorites: [...currentFavorites, target]);
    }
  }

  void removeFavorite(WordPair pair) {
    state = state.copyWith(
        favorites: state.favorites.where((p) => p != pair).toList());
  }
}
