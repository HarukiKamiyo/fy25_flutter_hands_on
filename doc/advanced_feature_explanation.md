# ハンズオン: 発展形コード実装 詳細解説

このドキュメントでは、基本の単語生成アプリを、よりリッチで実践的なアプリケーションへと進化させる「発展形（Advanced）」の実装について、Flutter初心者の方にも分かりやすく、一歩ずつ詳細に解説します。

主な変更点は、**履歴機能**、**アニメーション**、**レスポンシブ対応**、そして**UIの洗練**です。なぜこのような変更が必要で、どのように実現しているのかを一緒に見ていきましょう。

---

## 1. 状態管理の進化 (`MyAppState`)

アプリケーション全体のデータ（状態）を管理する `MyAppState` クラスが、今回の改良の心臓部です。ここでは主に「履歴機能」が追加されました。

### 1.1. 履歴リストと `GlobalKey` の追加

まずは、`MyAppState` に追加された2つのプロパティを見てみましょう。

```dart
// advanced/lib/main.dart

class MyAppState extends ChangeNotifier {
  // ... basic と同じコード ...
  var history = <WordPair>[]; // ← 追加！

  GlobalKey? historyListKey; // ← 追加！
  // ...
}
```

- **`history` リスト**:
  - **役割**: 今まで生成した単語のペア (`WordPair`) を、どんどん保存していくためのリスト（配列）です。
  - **なぜ必要？**: ユーザーが「さっきの単語、良かったな…」と思ったときに、いつでも遡って見返せるようにするためです。これにより、アプリの利便性が格段に向上します。

- **`historyListKey`**:
  - **役割**: これは少し特殊な役割を持ちます。UI側にある `AnimatedList` というウィジェットを、ロジック側（`MyAppState`）から直接操作するための「**リモコン**」や「**あだ名**」のようなものです。
  - **なぜ必要？**: `getNext()` が呼ばれたとき、`MyAppState` は UI に対して「おい、リストの一番上に新しい単語を追加して、アニメーションさせてくれ！」と命令する必要があります。この命令を出す相手を特定するのが `GlobalKey` の役割です。

### 1.2. `getNext` メソッドの機能拡張

新しい単語を生成する `getNext` メソッドも、履歴機能のために拡張されました。

```dart
// advanced/lib/main.dart

void getNext() {
  history.insert(0, current); // ← 追加！
  var animatedList = historyListKey?.currentState as AnimatedListState?; // ← 追加！
  animatedList?.insertItem(0); // ← 追加！
  current = WordPair.random();
  notifyListeners();
}
```

1. **`history.insert(0, current);`**
   - **何をしている？**: 現在表示されている単語 (`current`) を、`history` リストの**一番先頭 (インデックス `0`)** に追加しています。
   - **なぜ？**: 履歴は新しいものが上に表示されるのが自然だからです。

2. **`var animatedList = historyListKey?.currentState as AnimatedListState?;`**
   - **何をしている？**: 先ほど用意した「リモコン」(`historyListKey`) を使って、UI上の `AnimatedList` の現在の状態（`currentState`）を取得しています。`?` が付いているのは、`historyListKey` がまだUIにセットされていなくて `null` の可能性があるため、安全にアクセスするための記法です。

3. **`animatedList?.insertItem(0);`**
   - **何をしている？**: 取得した `AnimatedList` に対して、「リストの先頭（インデックス `0`）に新しいアイテムが追加されたから、アニメーション付きで表示してね！」と命令しています。
   - **結果**: この一行のおかげで、履歴リストに新しい単語が「シュッ」と滑らかに追加されるアニメーションが実現されます。

---

## 2. どんな画面サイズにも対応するレスポンシブデザイン (`MyHomePage`)

現代のアプリは、スマホ、タブレット、PCなど、様々な画面サイズで使われるのが当たり前です。`advanced` 版では、画面の横幅に応じてレイアウトが自動で切り替わる「レスポンシブデザイン」が実装されました。

### `LayoutBuilder` の導入

この機能の主役は `LayoutBuilder` ウィジェットです。

```dart
// advanced/lib/main.dart (MyHomePage の build メソッド内)

return Scaffold(
  body: LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 450) {
        // スマホ向けのレイアウト
        return Column( ... );
      } else {
        // タブレット・PC向けのレイアウト
        return Row( ... );
      }
    },
  ),
);
```

- **`LayoutBuilder`**:
  - **役割**: このウィジェットで子要素を囲むと、`builder` の中で、親ウィジェットのサイズ情報（`constraints`）にアクセスできるようになります。「**サイズ測定器**」のようなものです。
  - **`constraints`**: 横幅 (`maxWidth`) や高さ (`maxHeight`) といった寸法情報が入っているオブジェクトです。

- **`if (constraints.maxWidth < 450)`**:
  - **何をしている？**: 画面の横幅が `450` ピクセルより小さいかどうかを判定しています。
  - **なぜ `450`？**: これは「スマホの縦持ち」を想定した、一般的な区切り方の一つです。この数値を変えれば、レイアウトが切り替わるタイミングを調整できます。

### 画面サイズに応じた2つのレイアウト

- **横幅が狭い場合 (スマホ)**: `Column` を使って、メインコンテンツとナビゲーションバーを縦に並べます。ナビゲーションには `BottomNavigationBar` を採用しています。
  - **なぜ？**: スマホでは画面下部は親指が届きやすく、操作性が良いためです。
- **横幅が広い場合 (タブレット/PC)**: `Row` を使って、左側にナビゲーション、右側にメインコンテンツを配置します。ナビゲーションには `NavigationRail` を採用しています。
  - **なぜ？**: 広い画面では、左右に要素を配置することで、スペースを有効活用し、一覧性を高めることができます。

---

## 3. アプリをリッチに見せるアニメーション

`advanced` 版では、ユーザー体験を向上させるためのさりげないアニメーションが各所に追加されています。

### 3.1. ページ遷移アニメーション (`AnimatedSwitcher`)

`Home` と `Favorites` のページが切り替わる際に、フワッと表示が変わるアニメーションです。

```dart
// advanced/lib/main.dart (MyHomePage の build メソッド内)

var mainArea = ColoredBox(
  color: colorScheme.surfaceContainerHighest,
  child: AnimatedSwitcher(
    duration: Duration(milliseconds: 200),
    child: page,
  ),
);
```

- **`AnimatedSwitcher`**:
  - **役割**: このウィジェットで囲んだ `child`（今回は `page`）が別のウィジェットに差し替えられたことを検知すると、自動でアニメーション（デフォルトではフェードイン・アウト）を適用してくれます。
  - **`duration`**: アニメーションにかける時間です。ここでは `200` ミリ秒（0.2秒）に設定しており、素早くも滑らかな切り替えを実現しています。

### 3.2. 履歴リストのフェードアウト効果 (`HistoryListView`)

これは、`GeneratorPage` に新しく追加された `HistoryListView` ウィジェットで使われている、少し高度なテクニックです。

```dart
// advanced/lib/main.dart (HistoryListView の build メソッド内)

return ShaderMask(
  shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
  blendMode: BlendMode.dstIn,
  child: AnimatedList( ... ),
);
```

- **`ShaderMask`**:
  - **役割**: 子ウィジェット (`AnimatedList`) に対して、グラデーションなどのシェーダー効果（マスク）をかけるためのウィジェットです。「**特殊効果フィルター**」のようなものと考えてください。
- **`_maskingGradient`**:
  - `LinearGradient` を使って、「上（`topCenter`）から中間（`stops: [0.0, 0.5]`）にかけて、透明（`transparent`）から黒（`black`）へ」と変化するグラデーションを定義しています。
- **`blendMode: BlendMode.dstIn`**:
  - **何をしている？**: これが魔法の正体です。このブレンドモードは、「**マスク（グラデーション）の透明な部分は、元の絵（リスト）も透明にする**」という描画ルールを適用します。
  - **結果**: 黒いグラデーションがかかっている部分は元のリストがそのまま表示され、透明なグラデーションがかかっている上部（`top`）は、元のリストも透明になります。これにより、リストが画面の上部に吸い込まれるように、自然に消えていく効果が生まれます。

---

## 4. 使いやすさを追求したUIコンポーネントの改善

### 4.1. `BigCard` ウィジェットの改良

単語を表示するカードも、より洗練された見た目と振る舞いになりました。

```dart
// advanced/lib/main.dart (BigCard の build メソッド内)

// ...
child: AnimatedSize(
  duration: Duration(milliseconds: 200),
  child: MergeSemantics(
    child: Wrap(
      children: [
        Text(pair.first, ...),
        Text(pair.second, ...),
      ],
    ),
  ),
),
// ...
```

- **`AnimatedSize`**:
  - **役割**: 子ウィジェットのサイズが変更されたときに、そのサイズ変化を滑らかにアニメーションさせます。例えば、単語が長くて折り返された（`Wrap`された）ときに、カードの高さが「カクッ」と変わるのではなく、「ぬるっ」と広がります。
- **`Wrap`**:
  - **役割**: `Row` と似ていますが、横幅が足りなくなった場合に、子要素を自動で下に折り返してくれます。これにより、極端に狭い画面でも単語がはみ出さずに表示されます。
- **`MergeSemantics`**:
  - **役割**: これはアクセシビリティ（特に目の不自由な方向けの読み上げ機能）のための改善です。通常、`Text` ウィジェットが2つあると「(単語1)」「(単語2)」と別々に読み上げられてしまいますが、`MergeSemantics` で囲むことで、これらを「(単語1 単語2)」という**一つの意味のあるまとまり**として読み上げさせることができます。

### 4.2. `FavoritesPage` の改良

お気に入りページは、ただのリストから、より機能的なグリッド表示に進化しました。

```dart
// advanced/lib/main.dart (FavoritesPage の build メソッド内)

Expanded(
  child: GridView(
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 400,
      childAspectRatio: 400 / 80,
    ),
    children: [ // ... ],
  ),
),
```

- **`GridView`**:
  - **役割**: 子要素を格子状（グリッド）に並べるウィジェットです。
  - **`SliverGridDelegateWithMaxCrossAxisExtent`**: `GridView` のアイテムのレイアウトを制御するクラスです。ここでは `maxCrossAxisExtent: 400` と設定することで、「各アイテムの最大幅は400pxとし、画面幅に応じて列数を自動で調整する」という賢いレイアウトを実現しています。これにより、広い画面では複数列、狭い画面では1列表示となり、スペースを有効活用できます。
- **削除ボタンの追加**:
  - `ListTile` の `leading` に `IconButton` を配置し、これを押すと `appState.removeFavorite(pair)` が呼ばれるようになりました。これにより、ユーザーはお気に入りの単語を個別かつ直感的に削除できます。

---

## まとめ

これらの変更を通じて、単なる単語生成アプリは、以下のような特徴を持つ、より実践的でユーザーフレンドリーなアプリケーションへと進化しました。

- **状態の保持**: 履歴機能により、過去の単語を見返せる。
- **柔軟なレイアウト**: どんな画面サイズでも最適化された表示。
- **心地よいフィードバック**: アニメーションによる滑らかな操作感。
- **洗練されたUI/UX**: アクセシビリティや使いやすさを考慮したコンポーネント。
