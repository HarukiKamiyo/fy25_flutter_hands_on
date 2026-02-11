# モダン MVVM へのリファクタリング (Riverpod + Freezed)

本セクションでは、プロジェクトをさらに堅牢かつメンテナンスしやすくするため、**Riverpod (Code Generation)** と **Freezed** を導入し、モダンな **MVVM (Model-View-ViewModel)** アーキテクチャへリファクタリングした内容を解説します。

## 1. 導入した技術の役割

### Riverpod (Code Generation)

- **役割**: 状態管理および依存関係の注入 (DI)。
- **特徴**: `@riverpod` アノテーションを使用することで、Provider の定義を自動生成します。型安全性が高く、ボイラープレートコード（定型文）を大幅に削減できます。

### Freezed

- **役割**: 不変（Immutable）なデータモデルの作成。
- **特徴**: 状態を「不変」に保つことで、意図しない書き換えを防ぎ、状態の変化を確実に Riverpod へ通知できるようにします。`copyWith` メソッドなどが自動生成され、状態の更新が容易になります。

## 2. アーキテクチャ構成

リファクタリング後は、責務が明確に 3 つの層に分離されています。

```text
lib/
├── models/             # [Model] 不変な状態を定義 (Freezed)
├── view_models/        # [ViewModel] ロジックと状態更新 (Riverpod Notifier)
└── views/              # [View] UI 実装 (ConsumerWidget)
```

### Model (`lib/models/home_state.dart`)

`Freezed` を用いて、アプリの状態をひとまとめにしたクラスです。
現在の単語ペア、履歴、お気に入り、選択中のインデックスを保持します。

```dart
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required WordPair current,
    @Default([]) List<WordPair> history,
    @Default([]) List<WordPair> favorites,
    @Default(0) int selectedIndex,
  }) = _HomeState;
}
```

### ViewModel (`lib/view_models/home_view_model.dart`)

`Riverpod` の `Notifier` を使用し、状態（`HomeState`）の管理と操作ロジックを担います。
以前の `ChangeNotifier` とは異なり、`state = state.copyWith(...)` を通じて宣言的に状態を更新します。

```dart
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() => HomeState(current: WordPair.random());

  void getNext() {
    // 状態の更新は copyWith を使用して新しいインスタンスを生成する
    state = state.copyWith(
      history: [state.current, ...state.history],
      current: WordPair.random(),
    );
  }
  // ... その他のロジック
}
```

### View (`lib/views/`)

`ConsumerWidget` を使用して、ViewModel の `state` を監視 (`watch`) します。
状態が更新されると、View は自動的に再描画されます。

```dart
class GeneratorPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態を監視
    final state = ref.watch(homeViewModelProvider);
    // 操作（Notifier）を取得
    final notifier = ref.read(homeViewModelProvider.notifier);

    return Column(
      children: [
        BigCard(pair: state.current), // 状態を参照
        ElevatedButton(
          onPressed: () => notifier.getNext(), // ロジックを呼び出し
          child: Text('Next'),
        ),
      ],
    );
  }
}
```

## 3. リファクタリングによるメリット

1. **予測可能性の向上**: 状態が不変であるため、「いつの間にか値が変わっていた」というバグが防げます。
2. **型安全**: コード生成を利用することで、Provider や状態へのアクセスが強力に型保護されます。
3. **テストの容易性**: ロジックが ViewModel に集約され、UI から独立しているため、ユニットテストが書きやすくなります。
4. **保守性**: ファイルごとの役割が明確になり、チーム開発や長期的なメンテナンスにおいて、どこに何があるか迷わなくなります。

---

**補足**: 変更を反映するには、ターミナルで `fvm flutter pub run build_runner build` を実行して、必要なコードを自動生成する必要があります。
