import SwiftUI
import Vision

struct OCRDebugView: View {
    @StateObject private var ocrService = OCRService.shared
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isProcessingOCR = false
    @State private var ocrResult: OCRResult?
    @State private var debugMessages: [String] = []
    @State private var useFixedMethod = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image selection section
                    VStack(spacing: 10) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Select Image")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Processing controls
                    Toggle("Use Fixed Method", isOn: $useFixedMethod)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button(action: {
                        processImage()
                    }) {
                        Text("Process Image")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(selectedImage == nil || isProcessingOCR)
                    
                    if isProcessingOCR {
                        ProgressView("Processing...")
                    }
                    
                    // Results display
                    if let result = ocrResult {
                        resultView(result)
                    }
                    
                    // Debug messages
                    debugMessagesView
                }
                .padding()
            }
            .navigationTitle("OCR Debug")
            .sheet(isPresented: $showingImagePicker) {
                OCRImageSelectionSheet(selectedImage: $selectedImage, showingSheet: $showingImagePicker)
            }
        }
    }
    
    private func processImage() {
        guard let image = selectedImage else { return }
        
        isProcessingOCR = true
        debugMessages = []
        ocrResult = nil
        
        if useFixedMethod {
            // Use the enhanced method from OCRService+Fixes.swift
            addDebugMessage("Using enhanced OCR method")
            
            ocrService.enhancedOCRProcessing(image) { result in
                DispatchQueue.main.async {
                    isProcessingOCR = false
                    
                    switch result {
                    case .success(let ocrResult):
                        self.ocrResult = ocrResult
                        self.addDebugMessage("Successfully processed with enhanced method")
                        self.addDebugMessage("Amount: \(ocrResult.amount?.description ?? "None")")
                        self.addDebugMessage("Confidence: \(Int(ocrResult.confidence * 100))%")
                        
                    case .failure(let error):
                        self.addDebugMessage("Error with enhanced method: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Use the original method
            addDebugMessage("Using original OCR method")
            
            ocrService.processImage(image) { result in
                DispatchQueue.main.async {
                    isProcessingOCR = false
                    
                    switch result {
                    case .success(let ocrResult):
                        self.ocrResult = ocrResult
                        self.addDebugMessage("Successfully processed with original method")
                        self.addDebugMessage("Amount: \(ocrResult.amount?.description ?? "None")")
                        self.addDebugMessage("Confidence: \(Int(ocrResult.confidence * 100))%")
                        
                    case .failure(let error):
                        self.addDebugMessage("Error with original method: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func resultView(_ result: OCRResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                Text("OCR Result")
                    .font(.headline)
                
                if let amount = result.amount {
                    Text("Amount: Rs. \(String(format: "%.2f", amount))")
                } else {
                    Text("Amount: Not detected")
                }
                
                if let category = result.suggestedCategory {
                    Text("Category: \(category)")
                } else {
                    Text("Category: Not detected")
                }
                
                if let merchant = result.merchant {
                    Text("Merchant: \(merchant)")
                } else {
                    Text("Merchant: Not detected")
                }
                
                Text("Confidence: \(Int(result.confidence * 100))%")
            }
            
            Divider()
            
            Text("Extracted Text:")
                .font(.headline)
            
            ScrollView {
                Text(result.text)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 150)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var debugMessagesView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug Log:")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(debugMessages, id: \.self) { message in
                        Text(message)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 150)
            .padding(8)
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func addDebugMessage(_ message: String) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        debugMessages.append("[\(formatter.string(from: timestamp))] \(message)")
    }
}

struct OCRDebugView_Previews: PreviewProvider {
    static var previews: some View {
        OCRDebugView()
    }
}
