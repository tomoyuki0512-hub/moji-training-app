# たしざん（tashizan）

4さい から はじめる、かわいい たしざん アプリ（Flutter / iOS 向け）。

はじめて 計算を する 子ども が、くだものを かぞえながら たのしく たしざんを
れんしゅう できる ように デザインしています。

## 特長

- **レベル制でステップアップ**
  - **レベル1**: 1けた ＋ 1けた で 10を こえない たしざん（こたえ 2〜10）
  - **レベル2**: 1けた ＋ 1けた で 2けたに なる くりあがりの たしざん（こたえ 11〜18）
- **4さいむけの かわいい UI**: 大きくて 丸い ボタン、やわらかい パステルカラー、
  マスコットの 絵文字
- **わかりやすい サポート**
  - 🍎 と 🍊 の くだもの で、問題を 目で 見て かぞえられる
  - 「かぞえてみよう」ヒントで、くだものを 1つずつ 順番に かぞえて こたえへ 導く
  - まちがえても ペナルティなし。せいかい するまで 何度でも やりなおせる
- **ごほうび**: 1回で せいかい できた 数だけ ⭐ が もらえる 結果画面

## 構成

```
lib/
  main.dart                  アプリのエントリポイント
  theme.dart                 かわいい配色・テーマ
  models/
    level.dart               レベル（こたえの範囲）の定義
    addition_problem.dart     1問分のデータ
  services/
    addition_service.dart    問題生成ロジック
  screens/
    home_screen.dart         レベル選択
    play_screen.dart         出題・回答・ヒント
    result_screen.dart       結果（ほし）表示
  widgets/
    counting_objects.dart    かぞえる くだもの ビジュアル
    choice_button.dart       こたえの選択肢ボタン
```

## 開発

```sh
flutter pub get
flutter test
flutter run
```

iOS の署名なしビルドは GitHub Actions（`.github/workflows/build-ios.yml`）で自動生成されます。
