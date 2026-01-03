# MVVM リファクタリング概要

`main.dart` の肥大化を解消するため、MVVM (Model-View-ViewModel) アーキテクチャを導入し、責務の分離を行いました。

## 変更のポイント

- **責務の分離**: UI 構築 (View) と 状態管理・ロジック (ViewModel) を分離しました。
- **可読性の向上**: ファイルを役割ごとに分割し、見通しを良くしました。

## フォルダ構成

リファクタリング後のフォルダ構成は以下の通りです。

```text
lib/
├── main.dart                  # アプリのエントリーポイント
├── view_models/               # ViewModel層 (状態管理・ロジック)
│   └── home_view_model.dart   # アプリ全体の主要な状態を管理 (旧 MyAppState)
└── views/                     # View層 (UI実装)
    ├── home_page.dart         # メイン画面 (ナビゲーション管理)
    ├── generator_page.dart    # 単語生成画面
    ├── favorites_page.dart    # お気に入り一覧画面
    └── widgets/               # UI部品
        ├── big_card.dart          # 単語カード表示部品
        └── history_list_view.dart # 履歴リスト表示部品
```

## 各層の役割

### 1. ViewModels (`lib/view_models/`)

UI の状態（データ）とビジネスロジック（操作）を保持します。

- `ChangeNotifier` を継承し、状態の変化を View に通知します。
- UI コード（Widget）は含みません。

### 2. Views (`lib/views/`)

ユーザーインターフェースを構築します。

- ViewModel を監視 (`watch`) し、データの変更に応じて画面を再描画します。
- ユーザーの操作を ViewModel のメソッド呼び出しに変換します。

### 3. Main (`lib/main.dart`)

アプリの起動と構成設定を行います。ViewModel をアプリ全体に提供（DI）する設定のみを残しています。
