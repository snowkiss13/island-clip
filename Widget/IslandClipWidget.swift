import ActivityKit
import SwiftUI
import WidgetKit

@main
struct IslandClipWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClipLiveActivity()
    }
}

struct ClipLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClipActivityAttributes.self) { context in
            // ロック画面／バナー表示
            HStack(spacing: 8) {
                Image(systemName: "clipboard.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("保存したクリップ \(context.state.totalCount)件")
                        .font(.headline)
                    if let latest = context.state.previews.first {
                        Text(latest).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
                Spacer()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // 展開時: 最近の3件をタップでコピーし直す
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(context.state.previews.enumerated()), id: \.offset) { index, preview in
                            Link(destination: URL(string: "islandclip://copy?index=\(index)")!) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.on.clipboard")
                                        .font(.caption)
                                    Text(preview)
                                        .font(.callout)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "arrow.right.circle")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        if context.state.previews.isEmpty {
                            Text("保存したクリップはありません").font(.callout).foregroundStyle(.secondary)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "clipboard.fill")
            } compactTrailing: {
                Text("\(context.state.totalCount)")
                    .font(.caption).bold()
            } minimal: {
                Image(systemName: "clipboard")
            }
            .widgetURL(URL(string: "islandclip://"))
        }
    }
}
