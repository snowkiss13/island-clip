import ActivityKit
import Foundation

/// Live Activity（Dynamic Island 表示）の開始・更新・終了
final class ClipActivityManager: ObservableObject {
    @Published private(set) var isActive = false
    private var activity: Activity<ClipActivityAttributes>?

    private func state(from store: ClipStore) -> ClipActivityAttributes.ContentState {
        .init(
            previews: store.recentItems.prefix(3).map { $0.preview },
            totalCount: store.items.count
        )
    }

    func start(store: ClipStore) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        if activity != nil {
            refresh(store: store)
            return
        }
        do {
            activity = try Activity.request(
                attributes: ClipActivityAttributes(),
                content: .init(state: state(from: store), staleDate: nil)
            )
            isActive = true
        } catch {
            isActive = false
        }
    }

    func refresh(store: ClipStore) {
        guard let activity else { return }
        let content = ActivityContent(state: state(from: store), staleDate: nil)
        Task { await activity.update(content) }
    }

    func end() {
        guard let activity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        self.activity = nil
        isActive = false
    }
}
