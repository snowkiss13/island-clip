import SwiftUI

@main
struct IslandClipApp: App {
    @StateObject private var store = ClipStore()
    @StateObject private var activityManager = ClipActivityManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(activityManager)
                // Dynamic Island の項目タップ: islandclip://copy?index=N
                .onOpenURL { url in
                    guard url.scheme == "islandclip",
                          url.host == "copy",
                          let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let raw = comps.queryItems?.first(where: { $0.name == "index" })?.value,
                          let index = Int(raw) else { return }
                    store.copyBack(atRecentIndex: index)
                }
        }
    }
}
