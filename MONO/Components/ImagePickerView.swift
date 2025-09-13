//
//  ImagePickerView.swift
//  MONO
//
//  Created by Akash01 on 2025-08-29.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                if let temp = OCRFileHelper.saveImageToAppTemp(editedImage), let loaded = OCRFileHelper.loadImageFromAppURL(temp) {
                    parent.selectedImage = loaded
                    OCRFileHelper.removeTempFile(temp)
                } else {
                    parent.selectedImage = editedImage
                }
            } else if let originalImage = info[.originalImage] as? UIImage {
                if let temp = OCRFileHelper.saveImageToAppTemp(originalImage), let loaded = OCRFileHelper.loadImageFromAppURL(temp) {
                    parent.selectedImage = loaded
                    OCRFileHelper.removeTempFile(temp)
                } else {
                    parent.selectedImage = originalImage
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        if let temp = OCRFileHelper.saveImageToAppTemp(image), let loaded = OCRFileHelper.loadImageFromAppURL(temp) {
                            DispatchQueue.main.async {
                                self.parent.selectedImage = loaded
                            }
                            OCRFileHelper.removeTempFile(temp)
                        } else {
                            DispatchQueue.main.async {
                                self.parent.selectedImage = image
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ImageSelectionSheet: View {
    @Binding var selectedImage: UIImage?
    @Binding var showingSheet: Bool
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Add Bill Photo")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Take a photo or select from your library to automatically extract expense details")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                VStack(spacing: 12) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Take Photo")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.monoPrimary)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingPhotoLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Choose from Library")
                                .font(.headline)
                        }
                        .foregroundColor(Color.monoPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.monoPrimary.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.monoPrimary, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Add Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingSheet = false
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            ImagePickerView(selectedImage: $selectedImage, sourceType: .camera)
                .onDisappear {
                    if selectedImage != nil {
                        showingSheet = false
                    }
                }
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoPickerView(selectedImage: $selectedImage)
                .onDisappear {
                    if selectedImage != nil {
                        showingSheet = false
                    }
                }
        }
    }
}

#Preview {
    ImageSelectionSheet(selectedImage: .constant(nil), showingSheet: .constant(true))
}
