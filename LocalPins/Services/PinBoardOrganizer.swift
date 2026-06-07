import Foundation
import SwiftData

@MainActor
enum PinBoardOrganizer {
    static func updateBoards(
        for pin: PhotoPin,
        selectedBoards: [PinBoard],
        in modelContext: ModelContext
    ) throws {
        let selectedIDs = Set(selectedBoards.map(\.id))

        for board in pin.boards where !selectedIDs.contains(board.id) {
            board.pins.removeAll { $0.id == pin.id }
            board.updatedAt = .now
        }

        pin.boards.removeAll { !selectedIDs.contains($0.id) }

        for board in selectedBoards where !pin.boards.contains(where: { $0.id == board.id }) {
            pin.boards.append(board)
            if !board.pins.contains(where: { $0.id == pin.id }) {
                board.pins.append(pin)
            }
            board.updatedAt = .now
        }

        pin.updatedAt = .now
        try modelContext.save()
    }
}
