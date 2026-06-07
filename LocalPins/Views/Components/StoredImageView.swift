import SwiftUI
import UIKit

struct StoredImageView: View {
    let fileName: String

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.tertiarySystemFill))

                    Image(systemName: "photo")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .task(id: fileName) {
                    loadImage()
                }
            }
        }
    }

    private func loadImage() {
        guard uiImage == nil else { return }
        guard let url = try? ImageStorageService.shared.imageURL(for: fileName),
              let image = UIImage(contentsOfFile: url.path) else {
            return
        }

        uiImage = image
    }
}
