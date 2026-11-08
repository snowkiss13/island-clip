import Combine
import Foundation
import UIKit

/// 保存したクリップ1件
struct ClipItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var text: String
    var createdAt: Date = Date()
    var pinned: Bool = false

    /// Dynamic Island に出す短いプレビュー
    var preview: String {
        let oneLine = text.replacingOccurrences(of: "\n", with: " ")
        return oneLine.count > 40 ? String(oneLine.prefix(40)) + "…" : oneLine
    }
}

/// App Group 経由でアプリ本体とウィジェットが共有する保存庫
final class ClipStore: ObservableObject {
    static let appGroupID = "group.com.snowkiss13.islandclip"
    private static let key = "clips.v1"
    static let maxItems = 50

    @Published private(set) var items: [ClipItem] = []

    private var defaults: UserDefaults {
        UserDefaults(suiteName: Self.appGroupID) ?? .standard
    }

    init() { load() }

    /// 新しい順（Live Activity のプレビューとアプリ側コピーの並びを一致させる正）
    var recentItems: [ClipItem] {
        items.sorted { $0.createdAt > $1.createdAt }
    }

    var pinnedItems: [ClipItem] {
        recentItems.filter { $0.pinned }
    }

    var unpinnedItems: [ClipItem] {
        recentItems.filter { !$0.pinned }
    }

    func add(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // 同じ内容があれば先頭に繰り上げる（重複を作らない）
        if let idx = items.firstIndex(where: { $0.text == trimmed }) {
            items[idx].createdAt = Date()
        } else {
            items.append(ClipItem(text: trimmed))
        }
        if items.count > Self.maxItems {
            // ピン留め以外で古いものから落とす
            let overflow = items.count - Self.maxItems
            var removed = 0
            items = items.sorted { $0.createdAt < $1.createdAt }.filter { item in
                if removed < overflow && !item.pinned {
                    removed += 1
                    return false
                }
                return true
            }
        }
        save()
    }

    func delete(_ item: ClipItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func togglePin(_ item: ClipItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].pinned.toggle()
        save()
    }

    func clearUnpinned() {
        items.removeAll { !$0.pinned }
        save()
    }

    /// recentItems の index 番目をシステムのクリップボードへ書き戻す（書き込みに許可バナーは出ない）
    func copyBack(atRecentIndex index: Int) {
        let recent = recentItems
        guard recent.indices.contains(index) else { return }
        UIPasteboardWrite(recent[index].text)
    }

    func copyBack(_ item: ClipItem) {
        UIPasteboardWrite(item.text)
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([ClipItem].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: Self.key)
        }
    }
}

/// クリップボードへの書き込みだけを切り出した小さなヘルパー
func UIPasteboardWrite(_ text: String) {
    UIPasteboard.general.string = text
}
