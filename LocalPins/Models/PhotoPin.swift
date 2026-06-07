import Foundation
import SwiftData

@Model
final class PhotoPin: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var imageFileName: String
    var pixelWidth: Double
    var pixelHeight: Double
    @Relationship(inverse: \PinBoard.pins) var boards: [PinBoard]

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        updatedAt: Date = .now,
        imageFileName: String,
        pixelWidth: Double,
        pixelHeight: Double,
        boards: [PinBoard] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageFileName = imageFileName
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.boards = boards
    }

    var aspectRatio: Double {
        guard pixelWidth > 0, pixelHeight > 0 else { return 1 }
        return pixelWidth / pixelHeight
    }
}
