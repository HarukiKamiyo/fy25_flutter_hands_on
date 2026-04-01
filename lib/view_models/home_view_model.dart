import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fy25_flutter_hands_on/models/home_state.dart';

class HomeViewModel extends AutoDisposeNotifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(
      current: WordPair.random(),
    );
  }

  GlobalKey? historyListKey;

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void getNext() {
    final history = [state.current, ...state.history];

    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    state = state.copyWith(
      history: history,
      current: WordPair.random(),
    );
  }

  void toggleFavorite([WordPair? pair]) {
    final targetPair = pair ?? state.current;
    final favorites = List<WordPair>.from(state.favorites);

    if (favorites.contains(targetPair)) {
      favorites.remove(targetPair);
    } else {
      favorites.add(targetPair);
    }

    state = state.copyWith(favorites: favorites);
  }

  void removeFavorite(WordPair pair) {
    final favorites = List<WordPair>.from(state.favorites);
    favorites.remove(pair);
    state = state.copyWith(favorites: favorites);
  }
}

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
