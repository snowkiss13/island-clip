import AppIntents

/// ショートカット／背面タップ／アクションボタンからアプリを開くための入口。
/// 開いた直後に「取り込み」ボタンへ誘導するのが v1 の割り切り
/// （バックグラウンドでクリップボードを読むことは iOS では許可されないため）。
struct OpenIslandClipIntent: AppIntent {
    static var title: LocalizedStringResource = "Island Clipを開く"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct IslandClipShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenIslandClipIntent(),
            phrases: ["\(.applicationName)を開く"],
            shortTitle: "Island Clipを開く",
            systemImageName: "clipboard"
        )
    }
}
