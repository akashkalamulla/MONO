# iOS Permissions Required for OCR Feature

Add the following permissions to your iOS app's Info.plist file:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to capture receipt photos for automatic expense tracking.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select receipt images for automatic expense tracking.</string>
```

## How to Add Permissions:

1. Open your project in Xcode
2. Select your app target
3. Go to the "Info" tab
4. Click the "+" button to add new entries
5. Add the keys above with appropriate descriptions

## Alternative Method:

1. Right-click on your project in Xcode
2. Select "Add Files to [ProjectName]"
3. Create a new Info.plist file if it doesn't exist
4. Add the camera and photo library usage descriptions

These permissions are required for:
- Camera access to take photos of receipts
- Photo library access to select existing receipt images
- OCR processing of bill images
