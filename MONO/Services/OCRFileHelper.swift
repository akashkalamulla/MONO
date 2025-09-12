import Foundation
import UIKit

struct OCRFileHelper {
    /// Save UIImage to a temporary file inside the app sandbox and return the file URL.
    /// Returns nil on failure.
    static func saveImageToAppTemp(_ image: UIImage, compressionQuality: CGFloat = 0.9) -> URL? {
        let fileName = "ocr_\(UUID().uuidString).jpg"
        let tmp = FileManager.default.temporaryDirectory
        let url = tmp.appendingPathComponent(fileName)

        // Prefer jpeg data for broad compatibility
        guard let data = image.jpegData(compressionQuality: compressionQuality) else { return nil }

        do {
            try data.write(to: url, options: .atomic)
            // Optionally set file protection to avoid leaking to backups
            try FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUnlessOpen], ofItemAtPath: url.path)
            return url
        } catch {
            print("OCRFileHelper: failed to write image to temp: \(error)")
            return nil
        }
    }

    /// Load a UIImage from a file URL inside the app sandbox.
    static func loadImageFromAppURL(_ url: URL) -> UIImage? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Convert UIImage to CGImage; fall back to rendering if needed.
    static func cgImageFrom(_ image: UIImage) -> CGImage? {
        if let cg = image.cgImage { return cg }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let rendered = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: image.size)) }
        return rendered.cgImage
    }

    /// Remove the temporary file (best-effort)
    static func removeTempFile(_ url: URL) {
        do { try FileManager.default.removeItem(at: url) } catch { /* ignore */ }
    }
}
