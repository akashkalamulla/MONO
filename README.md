# MONO iOS App

A SwiftUI-based iOS application with a clean, modern design featuring a custom splash screen and main interface.

## Project Structure

```
MONO/
├── Views/
│   ├── Splash/
│   │   └── SplashView.swift          # Main splash screen with loading animation
│   └── Main/
│       └── MainView.swift            # Main app interface after splash
├── Components/
│   └── LoadingIndicator.swift        # Reusable loading animation component
├── Utils/
│   ├── Color+Extensions.swift        # Custom color palette and extensions
├── Assets.xcassets/                  # App icons, images, and other assets
├── MONOApp.swift                     # Main app entry point
├── ContentView.swift                 # Legacy view (kept for reference)
└── new.swift                         # App constants and configuration
```

## Features

### Splash Screen
- Clean white background with "mono" branding
- Custom teal color scheme
- Animated loading indicator with three dots
- Automatic transition to main view after 2.5 seconds
- Smooth animations and transitions

### Main Interface
- Welcome screen with consistent branding
- Clean, minimal design
- Custom button styling
- Extensible structure for adding more features

### Design System
- **Primary Color**: Teal (#336666)
- **Typography**: System fonts with custom sizing
- **Animations**: Smooth transitions and loading states
- **Layout**: Responsive design using SwiftUI

## Color Palette

- `monoPrimary`: Teal (#336666) - Main brand color
- `monoSecondary`: Darker teal (#2D4D4D) - Secondary actions
- `monoBackground`: Light gray (#FAFAFA) - Background color
- `monoText`: Dark gray (#333333) - Primary text
- `monoTextLight`: Light gray (#999999) - Secondary text

## Usage

The app starts with a splash screen displaying the "mono" logo and loading animation. After the loading completes, it transitions to the main interface where you can add your app's primary functionality.

## Customization

- Modify colors in `Color+Extensions.swift`
- Adjust timing and animations in `AppConstants.swift`
- Add new views in the appropriate folders under `Views/`
- Create reusable components in the `Components/` folder

## Development

This project uses SwiftUI and follows iOS development best practices with a clean, organized file structure that's easy to maintain and extend.
