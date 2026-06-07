import SwiftData
import SwiftUI

struct BoardPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PinBoard.updatedAt, order: .reverse) private var boards: [PinBoard]

    @State private var selectedBoardIDs: Set<UUID>
    @State private var newBoardName = ""

    let title: String
    let onSave: ([PinBoard]) -> Void
    let onCreateBoard: (String) -> PinBoard

    init(
        title: String,
        initiallySelectedIDs: Set<UUID>,
        onSave: @escaping ([PinBoard]) -> Void,
        onCreateBoard: @escaping (String) -> PinBoard
    ) {
        self.title = title
        self._selectedBoardIDs = State(initialValue: initiallySelectedIDs)
        self.onSave = onSave
        self.onCreateBoard = onCreateBoard
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Collections") {
                    if boards.isEmpty {
                        Text("Создай первую коллекцию, чтобы раскладывать фото по доскам.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(boards, id: \.id) { board in
                        Button {
                            toggle(board)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(board.name)
                                        .foregroundStyle(.primary)
                                    Text("\(board.pins.count) фото")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: selectedBoardIDs.contains(board.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedBoardIDs.contains(board.id) ? .primary : .tertiary)
                            }
                        }
                    }
                }

                Section("New Board") {
                    TextField("Например, Путешествия", text: $newBoardName)
                        .textInputAutocapitalization(.words)

                    Button("Создать коллекцию") {
                        createBoard()
                    }
                    .disabled(newBoardName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        let selectedBoards = boards.filter { selectedBoardIDs.contains($0.id) }
                        onSave(selectedBoards)
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggle(_ board: PinBoard) {
        if selectedBoardIDs.contains(board.id) {
            selectedBoardIDs.remove(board.id)
        } else {
            selectedBoardIDs.insert(board.id)
        }
    }

    private func createBoard() {
        let trimmedName = newBoardName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let board = onCreateBoard(trimmedName)
        selectedBoardIDs.insert(board.id)
        newBoardName = ""
    }
}
