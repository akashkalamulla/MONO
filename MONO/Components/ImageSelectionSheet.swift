import SwiftUI
import UIKit
import PhotosUI

struct OCRImageSelectionSheet: View {
    @Binding var selectedImage: UIImage?
    @Binding var showingSheet: Bool
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Select Image")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                HStack(spacing: 40) {
                    VStack {
                        Button {
                            showingCamera = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .frame(width: 120, height: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(15)
                        }
                        
                        Text("Camera")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                    }
                    
                    VStack {
                        Button {
                            showingPhotoLibrary = true
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                                .frame(width: 120, height: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(15)
                        }
                        
                        Text("Photos")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                    }
                }
                
                Button {
                    showingSheet = false
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCamera) {
            OCRCameraView(selectedImage: $selectedImage, isPresented: $showingCamera, completionHandler: { success in
                if success {
                    showingSheet = false
                }
            })
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            OCRPhotoLibraryPicker(selectedImage: $selectedImage, isPresented: $showingPhotoLibrary, completionHandler: { success in
                if success {
                    showingSheet = false
                }
            })
        }
    }
}

struct OCRCameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    var completionHandler: (Bool) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: OCRCameraView
        
        init(parent: OCRCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.completionHandler(true)
            } else {
                parent.completionHandler(false)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
            parent.completionHandler(false)
        }
    }
}

struct OCRPhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    var completionHandler: (Bool) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: OCRPhotoLibraryPicker
        
        init(parent: OCRPhotoLibraryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let result = results.first else {
                parent.completionHandler(false)
                return
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                        self.parent.completionHandler(true)
                    }
                } else {
                    self.parent.completionHandler(false)
                }
            }
        }
    }
}
