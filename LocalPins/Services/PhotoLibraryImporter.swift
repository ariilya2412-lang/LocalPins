import Foundation
import SwiftData
import UIKit

@MainActor
final class PhotoLibraryImporter {
    private let storageService: ImageStorageService

    init(storageService: ImageStorageService = .shared) {
        self.storageService = storageService
    }

    func importPickerData(
        _ items: [Data],
        to boards: [PinBoard],
        in modelContext: ModelContext
    ) throws {
        for data in items {
            try persistPin(from: data, to: boards, in: modelContext)
        }
    }

    func importCameraImage(
        _ image: UIImage,
        to boards: [PinBoard],
        in modelContext: ModelContext
    ) throws {
        let payload = try storageService.saveImage(image)
        let pin = PhotoPin(
            imageFileName: payload.fileName,
            pixelWidth: payload.width,
            pixelHeight: payload.height
        )

        pin.boards = boards
        boards.forEach { board in
            board.updatedAt = .now
            if !board.pins.contains(where: { $0.id == pin.id }) {
                board.pins.append(pin)
            }
        }

        modelContext.insert(pin)
        try modelContext.save()
    }

    private func persistPin(from data: Data, to boards: [PinBoard], in modelContext: ModelContext) throws {
        let payload = try storageService.saveImageData(data)
        let pin = PhotoPin(
            imageFileName: payload.fileName,
            pixelWidth: payload.width,
            pixelHeight: payload.height
        )

        pin.boards = boards
        boards.forEach { board in
            board.updatedAt = .now
            if !board.pins.contains(where: { $0.id == pin.id }) {
                board.pins.append(pin)
            }
        }

        modelContext.insert(pin)
        try modelContext.save()
    }
}
