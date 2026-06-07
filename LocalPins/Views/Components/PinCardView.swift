import SwiftUI

struct PinCardView: View {
    let pin: PhotoPin
    let availableWidth: CGFloat

    var body: some View {
        let aspectRatio = CGFloat(max(pin.aspectRatio, 0.5))
        let cardHeight = availableWidth / aspectRatio

        StoredImageView(fileName: pin.imageFileName)
            .aspectRatio(aspectRatio, contentMode: .fill)
            .frame(width: availableWidth, height: cardHeight)
            .clipped()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                if let boardName = pin.boards.first?.name {
                    Text(boardName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.35))
                        .clipShape(Capsule())
                        .padding(12)
                }
            }
    }
}
