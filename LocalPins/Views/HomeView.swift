import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PhotoPin.createdAt, order: .reverse) private var pins: [PhotoPin]

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPinID: UUID?
    @State private var showAddOptions = false
    @State private var showCamera = false
    @State private var showBoardPicker = false
    @State private var selectedBoardsForImport: [PinBoard] = []
    @State private var cameraImage: UIImage?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var pendingImportSource: PendingImportSource?

    private let importer = PhotoLibraryImporter()

    var body: some View {
        NavigationStack {
            Group {
                if pins.isEmpty {
                    emptyState
                } else {
                    MasonryGridView(pins: pins) { pin in
                        selectedPinID = pin.id
                    }
                }
            }
            .navigationTitle("LocalPins")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddOptions = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .confirmationDialog("Добавить фото", isPresented: $showAddOptions) {
                Button("Выбрать из галереи") {
                    pendingImportSource = .library
                    showBoardPicker = true
                }

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Сделать фото") {
                        pendingImportSource = .camera
                        showBoardPicker = true
                    }
                }
            }
            .photosPicker(
                isPresented: Binding(
                    get: { pendingImportSource == .library && !showBoardPicker },
                    set: { isPresented in
                        if !isPresented && pendingImportSource == .library {
                            pendingImportSource = nil
                        }
                    }
                ),
                selection: $selectedItems,
                maxSelectionCount: nil,
                matching: .images
            )
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    cameraImage = image
                    importCameraImage()
                }
                .ignoresSafeArea()
            }
            .sheet(item: selectedPinBinding) { selectedPin in
                PhotoDetailView(
                    pins: pins,
                    selectedPinID: selectedPin.id,
                    onDelete: { pin in
                        delete(pin)
                    }
                )
            }
            .sheet(isPresented: $showBoardPicker) {
                BoardPickerSheet(
                    title: "Куда добавить",
                    initiallySelectedIDs: Set(selectedBoardsForImport.map(\.id)),
                    onSave: { boards in
                        selectedBoardsForImport = boards
                        continueImportFlow()
                    },
                    onCreateBoard: { name in
                        createBoard(named: name)
                    }
                )
            }
            .onChange(of: selectedItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                importPickerItems(newItems)
            }
            .alert("Ошибка", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "photo.stack")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Личная доска для фото")
                    .font(.title2.weight(.semibold))

                Text("Добавляй снимки из галереи или камеры. Все сохраняется локально и работает офлайн.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Button("Добавить фото") {
                showAddOptions = true
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var selectedPinBinding: Binding<PhotoPin?> {
        Binding<PhotoPin?>(
            get: { pins.first(where: { $0.id == selectedPinID }) },
            set: { newValue in
                selectedPinID = newValue?.id
            }
        )
    }

    private func continueImportFlow() {
        switch pendingImportSource {
        case .library:
            pendingImportSource = .library
        case .camera:
            showCamera = true
        case .none:
            break
        }
    }

    private func importPickerItems(_ items: [PhotosPickerItem]) {
        Task {
            do {
                try await importer.importPickerItems(items, to: selectedBoardsForImport, in: modelContext)
                selectedItems = []
                selectedBoardsForImport = []
                pendingImportSource = nil
            } catch {
                presentError(error)
            }
        }
    }

    private func importCameraImage() {
        guard let cameraImage else { return }

        do {
            try importer.importCameraImage(cameraImage, to: selectedBoardsForImport, in: modelContext)
            self.cameraImage = nil
            selectedBoardsForImport = []
            pendingImportSource = nil
        } catch {
            presentError(error)
        }
    }

    private func delete(_ pin: PhotoPin) {
        ImageStorageService.shared.deleteImage(named: pin.imageFileName)
        modelContext.delete(pin)
        do {
            try modelContext.save()
        } catch {
            presentError(error)
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
        selectedItems = []
        cameraImage = nil
        selectedBoardsForImport = []
        pendingImportSource = nil
    }
}

private enum PendingImportSource {
    case library
    case camera
}
