# Riverpod への移行ガイド

本プロジェクトでは、状態管理ライブラリを `provider` パッケージから `flutter_riverpod` パッケージへ移行しました。
以下にその主な変更点と手順をまとめます。

## 1. 依存関係の更新 (`pubspec.yaml`)

`provider` を削除し、`flutter_riverpod` を追加しました。

```yaml
dependencies:
  flutter:
    sdk: flutter
  english_words: ^4.0.0
  # provider: ^6.0.0  <-- 削除
  flutter_riverpod: ^2.0.0  <-- 追加
```

## 2. Provider の定義 (`lib/view_models/`)

Riverpod では Provider をグローバルな定数として定義します。
既存の `ChangeNotifier` を再利用するため、`ChangeNotifierProvider` を使用しています。

**変更前 (Provider):**
`main.dart` 内の `MultiProvider` や `ChangeNotifierProvider` でインスタンスを作成し、下位ツリーに提供していました。

**変更後 (Riverpod):**
ViewModel ファイル内で定義します。

```dart
// lib/view_models/home_view_model.dart

// グローバルにアクセス可能な Provider を定義
final homeViewModelProvider = ChangeNotifierProvider((ref) => HomeViewModel());

class HomeViewModel extends ChangeNotifier { ... }
```

## 3. アプリのルート設定 (`lib/main.dart`)

Riverpod の Provider を有効にするため、アプリのルート（`runApp` の直下）を `ProviderScope` でラップします。
また、従来の `ChangeNotifierProvider` によるラップは削除しました。

```dart
void main() {
  // ProviderScope でラップする
  runApp(ProviderScope(child: MyApp()));
}
```

## 4. UI 側の変更 (`lib/views/`)

Widget が Provider にアクセスする方法が変更されました。

### StatelessWidget の場合

- 継承元を `ConsumerWidget` に変更。
- `build` メソッドの引数に `WidgetRef ref` を追加。
- `context.watch<T>()` の代わりに `ref.watch(provider)` を使用。

```dart
// 変更後
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var viewModel = ref.watch(homeViewModelProvider);
    ...
  }
}
```

### StatefulWidget の場合

- 継承元を `ConsumerStatefulWidget` に変更。
- State クラスの継承元を `ConsumerState` に変更。
- `build` メソッド内で `ref.watch(provider)` を使用（`ref` はプロパティとしてアクセス可能）。
