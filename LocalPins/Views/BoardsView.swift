import SwiftData
import SwiftUI

struct BoardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PinBoard.updatedAt, order: .reverse) private var boards: [PinBoard]

    @State private var newBoardName = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Create Board") {
                    HStack(spacing: 12) {
                        TextField("Новая коллекция", text: $newBoardName)
                            .textInputAutocapitalization(.words)

                        Button("Создать") {
                            createBoard()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newBoardName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                Section("Collections") {
                    if boards.isEmpty {
                        Text("Пока нет коллекций. Создай первую, чтобы раскладывать фото по темам.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(boards, id: \.id) { board in
                            NavigationLink {
                                BoardDetailView(board: board)
                            } label: {
                                BoardRowView(board: board)
                            }
                        }
                        .onDelete(perform: deleteBoards)
                    }
                }
            }
            .navigationTitle("Boards")
            .alert("Ошибка", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func createBoard() {
        let trimmedName = newBoardName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        do {
            let board = PinBoard(name: trimmedName)
            modelContext.insert(board)
            try modelContext.save()
            newBoardName = ""
        } catch {
            presentError(error)
        }
    }

    private func deleteBoards(at offsets: IndexSet) {
        do {
            for offset in offsets {
                let board = boards[offset]
                board.pins.forEach { pin in
                    pin.boards.removeAll { $0.id == board.id }
                }
                modelContext.delete(board)
            }
            try modelContext.save()
        } catch {
            presentError(error)
        }
    }

    private func presentError(_ error: Error) {
        alertMessage = error.localizedDescription
        showAlert = true
    }
}

private struct BoardRowView: View {
    let board: PinBoard

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 64, height: 64)
                .overlay {
                    if let firstPin = board.pins.first {
                        StoredImageView(fileName: firstPin.imageFileName)
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        Image(systemName: "square.grid.2x2")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(board.name)
                    .font(.headline)
                Text("\(board.pins.count) фото")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
