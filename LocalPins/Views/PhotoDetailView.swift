import SwiftData
import SwiftUI

struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let pins: [PhotoPin]
    let onDelete: (PhotoPin) -> Void

    @State private var selectedPinID: UUID
    @State private var showBoardPicker = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    init(pins: [PhotoPin], selectedPinID: UUID, onDelete: @escaping (PhotoPin) -> Void) {
        self.pins = pins
        self.onDelete = onDelete
        self._selectedPinID = State(initialValue: selectedPinID)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedPinID) {
                ForEach(pins, id: \.id) { pin in
                    ZoomablePinView(pin: pin)
                        .tag(pin.id)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Назад", systemImage: "chevron.backward")
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showBoardPicker = true
                    } label: {
                        Image(systemName: "square.grid.2x2")
                    }

                    Button(role: .destructive) {
                        deleteCurrentPin()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .sheet(isPresented: $showBoardPicker) {
                if let currentPin {
                    BoardPickerSheet(
                        title: "Коллекции",
                        initiallySelectedIDs: Set(currentPin.boards.map(\.id)),
                        onSave: { boards in
                            do {
                                try PinBoardOrganizer.updateBoards(for: currentPin, selectedBoards: boards, in: modelContext)
                            } catch {
                                presentError(error)
                            }
                        },
                        onCreateBoard: { name in
                            createBoard(named: name)
                        }
                    )
                }
            }
            .alert("Ошибка", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var currentPin: PhotoPin? {
        pins.first(where: { $0.id == selectedPinID })
    }

    private func deleteCurrentPin() {
        guard let currentPin else { return }
        let nextPinID = nextPinIdentifier(afterRemoving: currentPin.id)
        onDelete(currentPin)

        if pins.count <= 1 {
            dismiss()
            return
        }

        if let nextPinID {
            selectedPinID = nextPinID
        }
    }

    @discardableResult
    private func createBoard(named name: String) -> PinBoard {
        let board = PinBoard(name: name)
        modelContext.insert(board)
        do {
            try modelContext.save()
        } catch {
            presentError(error)
        }
        return board
    }

    private func presentError(_ error: Error) {
        alertMessage = error.localizedDescription
        showAlert = true
    }

    private func nextPinIdentifier(afterRemoving removedID: UUID) -> UUID? {
        guard let currentIndex = pins.firstIndex(where: { $0.id == removedID }) else {
            return pins.first?.id
        }

        let remainingPins = pins.filter { $0.id != removedID }
        guard !remainingPins.isEmpty else { return nil }

        if currentIndex < remainingPins.count {
            return remainingPins[currentIndex].id
        }

        return remainingPins.last?.id
    }
}

private struct ZoomablePinView: View {
    let pin: PhotoPin

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        GeometryReader { proxy in
            StoredImageView(fileName: pin.imageFileName)
                .scaledToFit()
                .scaleEffect(scale)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = max(1, min(lastScale * value, 4))
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .onTapGesture(count: 2) {
                    if scale > 1 {
                        scale = 1
                        lastScale = 1
                    } else {
                        scale = 2
                        lastScale = 2
                    }
                }
        }
    }
}
