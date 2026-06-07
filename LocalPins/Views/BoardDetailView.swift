import SwiftUI

struct BoardDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let board: PinBoard

    @State private var selectedPinID: UUID?
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        Group {
            if board.pins.isEmpty {
                ContentUnavailableView(
                    "В этой коллекции пока пусто",
                    systemImage: "photo.stack",
                    description: Text("Добавь фотографии с главного экрана и прикрепи их к этой доске.")
                )
            } else {
                MasonryGridView(pins: orderedPins) { pin in
                    selectedPinID = pin.id
                }
            }
        }
        .navigationTitle(board.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: selectedPinBinding) { selectedPin in
            PhotoDetailView(
                pins: orderedPins,
                selectedPinID: selectedPin.id,
                onDelete: { pin in
                    delete(pin)
                }
            )
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private var orderedPins: [PhotoPin] {
        board.pins.sorted { $0.createdAt > $1.createdAt }
    }

    private var selectedPinBinding: Binding<PhotoPin?> {
        Binding<PhotoPin?>(
            get: { orderedPins.first(where: { $0.id == selectedPinID }) },
            set: { newValue in
                selectedPinID = newValue?.id
            }
        )
    }

    private func delete(_ pin: PhotoPin) {
        ImageStorageService.shared.deleteImage(named: pin.imageFileName)
        modelContext.delete(pin)
        do {
            try modelContext.save()
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
