import Foundation
import UIKit

enum ImageStorageError: LocalizedError {
    case invalidImageData
    case unableToAccessStorage
    case fileMissing

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Не удалось обработать выбранное изображение."
        case .unableToAccessStorage:
            return "Не удалось получить доступ к локальному хранилищу."
        case .fileMissing:
            return "Файл изображения не найден."
        }
    }
}

struct StoredImagePayload {
    let fileName: String
    let width: Double
    let height: Double
}

final class ImageStorageService {
    static let shared = ImageStorageService()

    private let fileManager = FileManager.default
    private let imagesFolderName = "StoredPins"

    private init() {}

    func saveImageData(_ data: Data) throws -> StoredImagePayload {
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.invalidImageData
        }

        return try saveImage(image)
    }

    func saveImage(_ image: UIImage) throws -> StoredImagePayload {
        guard let jpegData = image.jpegData(compressionQuality: 0.92) else {
            throw ImageStorageError.invalidImageData
        }

        let fileName = "\(UUID().uuidString).jpg"
        let destinationURL = try imagesDirectoryURL().appendingPathComponent(fileName)

        do {
            try jpegData.write(to: destinationURL, options: [.atomic])
        } catch {
            throw ImageStorageError.unableToAccessStorage
        }

        let size = image.size
        return StoredImagePayload(
            fileName: fileName,
            width: max(size.width, 1),
            height: max(size.height, 1)
        )
    }

    func imageURL(for fileName: String) throws -> URL {
        let url = try imagesDirectoryURL().appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            throw ImageStorageError.fileMissing
        }
        return url
    }

    func deleteImage(named fileName: String) {
        guard let directoryURL = try? imagesDirectoryURL() else { return }
        let url = directoryURL.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: url)
    }

    private func imagesDirectoryURL() throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ImageStorageError.unableToAccessStorage
        }

        let directoryURL = documentsDirectory.appendingPathComponent(imagesFolderName, isDirectory: true)

        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                throw ImageStorageError.unableToAccessStorage
            }
        }

        return directoryURL
    }
}
