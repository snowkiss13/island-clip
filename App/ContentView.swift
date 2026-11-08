import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ClipStore
    @EnvironmentObject private var activityManager: ClipActivityManager
    @State private var manualText = ""
    @State private var showManualAdd = false
    @State private var copiedItemID: ClipItem.ID?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    // PasteButton はシステムの貼り付けバナーなしで取り込める公式の方法
                    PasteButton(payloadType: String.self) { strings in
                        if let first = strings.first {
                            store.add(text: first)
                            if activityManager.isActive {
                                activityManager.refresh(store: store)
                            }
                        }
                    }
                    .buttonBorderShape(.capsule)

                    Button {
                        showManualAdd = true
                    } label: {
                        Label("テキストを入力して追加", systemImage: "square.and.pencil")
                    }
                } header: {
                    Text("取り込み")
                } footer: {
                    Text("iOSの仕様上、他アプリでのコピーを裏で自動検知することはできません。コピーしたらこのボタンで取り込むのが確実な方法です。")
                }

                Section {
                    Toggle(isOn: Binding(
                        get: { activityManager.isActive },
                        set: { on in
                            if on { activityManager.start(store: store) }
                            else { activityManager.end() }
                        }
                    )) {
                        Label("Dynamic Islandに表示", systemImage: "capsule.portrait")
                    }
                } footer: {
                    Text("表示中は、展開したIslandから最近の3件をタップしてそのままコピーし直せます（最大8時間）。")
                }

                if !store.pinnedItems.isEmpty {
                    Section("ピン留め") {
                        ForEach(store.pinnedItems) { item in row(item) }
                    }
                }

                Section("保存したクリップ") {
                    if store.unpinnedItems.isEmpty && store.pinnedItems.isEmpty {
                        Text("まだ何も保存していません").foregroundStyle(.secondary)
                    }
                    ForEach(store.unpinnedItems) { item in row(item) }
                }
            }
            .navigationTitle("Island Clip")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            store.clearUnpinned()
                            if activityManager.isActive { activityManager.refresh(store: store) }
                        } label: {
                            Label("ピン留め以外を全削除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showManualAdd) {
                NavigationStack {
                    TextEditor(text: $manualText)
                        .padding()
                        .navigationTitle("テキストを追加")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("キャンセル") { showManualAdd = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("保存") {
                                    store.add(text: manualText)
                                    manualText = ""
                                    showManualAdd = false
                                    if activityManager.isActive { activityManager.refresh(store: store) }
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
        }
    }

    @ViewBuilder
    private func row(_ item: ClipItem) -> some View {
        Button {
            store.copyBack(item)
            copiedItemID = item.id
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.text)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    Text(item.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if copiedItemID == item.id {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                store.delete(item)
                if activityManager.isActive { activityManager.refresh(store: store) }
            } label: { Label("削除", systemImage: "trash") }
        }
        .swipeActions(edge: .leading) {
            Button {
                store.togglePin(item)
                if activityManager.isActive { activityManager.refresh(store: store) }
            } label: {
                Label(item.pinned ? "ピン解除" : "ピン留め",
                      systemImage: item.pinned ? "pin.slash" : "pin")
            }
            .tint(.orange)
        }
    }
}
