import ActivityKit
import Foundation

/// Dynamic Island / Live Activity の型定義（アプリとウィジェットで共有）
struct ClipActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// 新しい順のプレビュー（最大3件）。タップ時はこの並びの index でコピーし直す
        var previews: [String]
        var totalCount: Int
    }
}
