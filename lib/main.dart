import 'package:flutter/material.dart';

// アプリケーションのエントリーポイント（開始地点）です。
void main() {
  // runApp 関数でルートウィジェット（MyApp）を起動します。
  runApp(const MyApp());
}

// アプリケーションのルート（根幹）となるウィジェットです。
// 状態を持たない（静的な）StatelessWidget を継承しています。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // MaterialApp はマテリアルデザインのアプリを作成するためのウィジェットです。
    return MaterialApp(
      title: 'Flutter Demo',
      // アプリ全体のテーマ設定を行います。
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // アプリ起動時に最初に表示される画面を設定します。
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// 状態を持つ（動的な）ウィジェットです。
// ユーザーの操作などによって表示内容が変化する場合に使用します。
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  // このウィジェットの状態を管理する State クラスを作成します。
  State<MyHomePage> createState() => _MyHomePageState();
}

// MyHomePage の状態（State）と UI を管理するクラスです。
class _MyHomePageState extends State<MyHomePage> {
  // ボタンが押された回数を保持する変数（状態）です。
  int _counter = 0;

  // カウンターを増やして画面を更新するメソッドです。
  void _incrementCounter() {
    // setState を呼ぶと、Flutter フレームワークに「状態が変わったので画面を再描画してほしい」と伝えます。
    // これにより build メソッドが再度実行され、新しい _counter の値が画面に反映されます。
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold は基本的な画面レイアウト（AppBar, Body, FloatingActionButton など）を提供します。
    return Scaffold(
      // 画面上部のヘッダーバーです。
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 親ウィジェット（MyHomePage）から渡されたタイトルを表示します。
        title: Text(widget.title),
      ),
      // 画面のメインコンテンツ部分です。Center で中央寄せしています。
      body: Center(
        // Column は子ウィジェットを縦方向に並べます。
        child: Column(
          // 縦方向の中央に配置します。
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            // 現在のカウンターの値を表示します。
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      // 右下に表示されるフローティングアクションボタンです。
      floatingActionButton: FloatingActionButton(
        // ボタンが押された時に実行されるメソッドを指定します。
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
