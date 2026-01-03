# ハンズオン: 発展形コードの実装解説

このドキュメントでは、基本アプリに対して追加された「発展形（Advanced）」機能の実装について解説します。
主な変更点は、**履歴機能**、**アニメーション**、**レスポンシブ対応**、そして**UI の洗練**です。

## 1. 状態管理の強化 (`MyAppState`)

アプリの状態を管理する `MyAppState` クラスに、履歴機能とリストアニメーションの制御ロジックが追加されました。

### 履歴リストと GlobalKey

```dart
var history = <WordPair>[];
GlobalKey? historyListKey;
```

- `history`: 生成された単語ペアを保存するリストです。
- `historyListKey`: UI 側の `AnimatedList` を操作するために必要なキーです。これにより、ロジック側から UI のアニメーションをトリガーできます。

### getNext メソッドの拡張

```dart
void getNext() {
  history.insert(0, current);
  var animatedList = historyListKey?.currentState as AnimatedListState?;
  animatedList?.insertItem(0);
  // ...
}
```

新しい単語を生成する前に、現在の単語を履歴の先頭に追加し、`animatedList?.insertItem(0)` を呼び出してリスト追加のアニメーションを実行しています。

## 2. レスポンシブ対応 (`MyHomePage`)

画面サイズに応じてレイアウトを切り替える機能が実装されました。

### LayoutBuilder の使用

```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 450) {
      // モバイル向けレイアウト (BottomNavigationBar)
    } else {
      // デスクトップ/タブレット向けレイアウト (NavigationRail)
    }
  },
),
```

`LayoutBuilder` を使用して親ウィジェットの制約（サイズ）を取得し、幅が 450px 未満なら縦並びのナビゲーション、それ以上なら横並びのナビゲーションを表示するように分岐しています。

## 3. アニメーションと視覚効果

### ページ遷移アニメーション

```dart
child: AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  child: page,
),
```

`AnimatedSwitcher` を使用することで、`page` の内容が切り替わる際に自動的にフェードアニメーションが適用されます。

### 履歴リストのフェードアウト (`HistoryListView`)

```dart
return ShaderMask(
  shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
  blendMode: BlendMode.dstIn,
  child: AnimatedList( ... ),
);
```

`ShaderMask` と `LinearGradient`（透明から黒へのグラデーション）を使用し、`BlendMode.dstIn` を適用することで、リストの上部が徐々に透明になる「フェードアウト効果」を実現しています。これにより、リストが上に見切れているような自然な見た目になります。

## 4. UI コンポーネントの改善

### BigCard の調整

- **AnimatedSize**: カード内のテキストサイズが変わった際に、カード自体のサイズ変更を滑らかにアニメーションさせます。
- **Wrap**: 画面幅が極端に狭い場合に、単語が折り返されるようにします。
- **MergeSemantics**: アクセシビリティ対応として、2 つのテキストウィジェットを 1 つの読み上げ要素として統合します。

### FavoritesPage のグリッド表示

- `ListView` の代わりに `GridView` を使用し、画面幅が広い場合にアイテムをタイル状に並べてスペースを有効活用しています。
- 各アイテムに削除ボタン（ゴミ箱アイコン）を追加し、個別に削除できるようにしています。

---

これらの変更により、アプリは単なる機能デモを超えて、実際のプロダクトに近いユーザー体験（UX）を提供するようになります。
