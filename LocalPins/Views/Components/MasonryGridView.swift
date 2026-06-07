import SwiftUI

struct MasonryGridView: View {
    let pins: [PhotoPin]
    let onSelect: (PhotoPin) -> Void

    var body: some View {
        GeometryReader { proxy in
            let columns = splitPins(for: proxy.size.width)

            ScrollView {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(columns.enumerated()), id: \.offset) { _, columnPins in
                        LazyVStack(spacing: 12) {
                            ForEach(columnPins, id: \.id) { pin in
                                PinCardView(pin: pin, availableWidth: columnWidth(totalWidth: proxy.size.width))
                                    .onTapGesture {
                                        onSelect(pin)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private func splitPins(for totalWidth: CGFloat) -> [[PhotoPin]] {
        let columnCount = totalWidth > 700 ? 3 : 2
        var columns = Array(repeating: [PhotoPin](), count: columnCount)
        var heights = Array(repeating: CGFloat.zero, count: columnCount)
        let targetWidth = columnWidth(totalWidth: totalWidth, columnCount: columnCount)

        for pin in pins {
            let aspectRatio = CGFloat(max(pin.aspectRatio, 0.45))
            let itemHeight = targetWidth / aspectRatio
            let targetIndex = heights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            columns[targetIndex].append(pin)
            heights[targetIndex] += itemHeight + 12
        }

        return columns
    }

    private func columnWidth(totalWidth: CGFloat, columnCount: Int = 2) -> CGFloat {
        let totalSpacing = CGFloat((columnCount - 1) * 12)
        let horizontalPadding: CGFloat = 32
        return max((totalWidth - totalSpacing - horizontalPadding) / CGFloat(columnCount), 120)
    }
}
