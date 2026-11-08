# Island Clip（仮称）

Dynamic Island を使った、iPhone 用クリップ保存アプリの v1 スケルトン。

## できること（v1）
- コピーしたテキストをアプリ内の「貼り付け」ボタンで取り込んで保存（最大50件、ピン留め可）
- 保存したクリップはタップでそのままクリップボードに書き戻し（貼り付け直し）
- Live Activity を開始すると Dynamic Island に常駐表示。展開すると最近の3件が出て、タップでその項目をコピーし直せる
- ショートカット／背面タップ／アクションボタンから開くための App Intent 同梱

## iOS の制約（正直なところ）
- **他アプリでのコピーを裏で自動検知・自動保存することは iOS の仕様でできません。** クリップボードの読み取りはユーザーの操作が起点のときだけが正道で、それ以外は貼り付け許可バナーが出ます。v1 は公式の `PasteButton`（バナーなし）で取り込む方式です。
- 「どこからでも取り込む」を強くしたい場合の追加手段（v2 候補）:
  - 共有シート拡張：どのアプリからも「共有 → Island Clipに保存」
  - キーボード拡張：キーボード切り替えで保存済みクリップを呼び出す（フルアクセス許可が必要）
- Live Activity の表示は最大8時間。Dynamic Island は iPhone 14 Pro 以降／15 シリーズ全モデルで使えます。

## 構成
- `Shared/` … アプリとウィジェットで共有（ClipItem、ClipStore、Activity 属性）
- `App/` … SwiftUI 本体、Live Activity 管理、App Intent
- `Widget/` … Live Activity の Dynamic Island UI
- `project.yml` … XcodeGen 用プロジェクト定義

## ビルド手順（Mac）
1. このフォルダを Mac に持っていく
2. XcodeGen がある場合: `xcodegen generate` → `IslandClip.xcodeproj` を Xcode で開く
   無い場合: `brew install xcodegen`、または Xcode で iOS App プロジェクトを新規作成し、`App/` `Shared/` `Widget/` のソースと各 entitlements を追加する
3. Signing は自分の Apple ID チームを選ぶ。Bundle ID と App Group は `com.snowkiss13.islandclip` / `group.com.snowkiss13.islandclip`（project.yml 内、自由に変更可。変えたら ClipItem.swift の appGroupID も合わせる）
4. 実機（iPhone 15）で実行。初回は設定アプリで開発者モード許可が必要な場合あり

## 注意
- これはスケルトンです。Mac の Xcode でビルド確認をしてから実機テストする前提です（雪の VM では iOS ビルドができません）。
- App Store 公開には Apple Developer Program（年 99 ドル）と審査が必要です。まず自分の iPhone だけで使う形から始めるのがおすすめです。
