import SwiftUI

struct ShelfView: View {
    @ObservedObject var collector: ClipboardCollector
    let onDone: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if collector.items.isEmpty {
                emptyState
            } else {
                itemGrid
            }
            Divider()
            footer
        }
        .frame(width: 340, height: 300)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.28), radius: 24, y: 10)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 7, height: 7)
                .opacity(collector.isCollecting ? 1 : 0.25)
            Text(collector.isCollecting ? "Collecting…" : "Bunchy")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Text("\(collector.items.count)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 30))
                .foregroundStyle(.tertiary)
            Text("Copy anything, anywhere")
                .font(.system(size: 13, weight: .medium))
            Text("Each ⌘C you make elsewhere shows up here.\nKeep going, then finish to copy them all at once.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 10)], spacing: 10) {
                ForEach(collector.items) { item in
                    ShelfItemView(item: item) {
                        collector.removeItem(item.id)
                    }
                }
            }
            .padding(12)
        }
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                collector.clear()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .disabled(collector.items.isEmpty)
            .opacity(collector.items.isEmpty ? 0.35 : 1)
            .help("Clear all")

            Button("Done — Copy \(collector.items.count)", action: onDone)
                .buttonStyle(.borderedProminent)
                .disabled(collector.items.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

private struct ShelfItemView: View {
    let item: CollectedItem
    let onRemove: () -> Void
    @State private var hovering = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.15))
                    if let thumbnail = item.thumbnail {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        ProgressView().controlSize(.small)
                    }
                }
                .frame(width: 64, height: 64)

                Text(item.displayName)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: 72)
            }
            .onHover { hovering = $0 }

            if hovering {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, .black.opacity(0.6))
                        .font(.system(size: 15))
                }
                .buttonStyle(.plain)
                .offset(x: 4, y: -4)
            }
        }
    }
}
