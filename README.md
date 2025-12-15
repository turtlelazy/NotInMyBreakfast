# NotInMyBreakfast

A SwiftUI-based iOS app that helps users scan food products and check for blacklisted ingredients. Simply input a barcode number, and the app fetches product details from OpenFoodFacts API to identify any ingredients you want to avoid. The barcode scanning feature didn't work for some reason and was unable to debug in the moment.

## Features

### Core Functionality
- **Barcode Scanning**: Scan product barcodes using the camera, upload images, or enter codes manually (was not able to finish/complete, but did try to incorporate with requirements)
- **Ingredient Checking**: Automatically checks scanned products against your personal blacklist
- **Product Database**: Fetches real-time product information from OpenFoodFacts API
- **Scan History**: Persists all scanned products with CoreData for future reference
- **Blacklist Management**: Maintain a customizable list of ingredients to avoid

### Technical Implementation
In addition to the four project requirements, I also tackled the additional requirements. And detail that here.

#### 1. Custom UI Components (ViewModifiers)
- **ModernCardModifier**: Glass morphism card design used throughout the app (13 uses across 6 files)
- **GradientButtonModifier**: Gradient-styled buttons with theme support (6 uses across 3 files)
- Both are proper ViewModifier structs with Swift extension wrappers
- Reusable and theme-aware, extensively used in multiple views

#### 2. REST API Integration
- Skipped

#### 3. UIKit Integration
- **BarcodeScannerView**: UIViewRepresentable wrapper for AVFoundation camera capture
- **ImagePicker**: UIViewControllerRepresentable for PHPickerViewController
- **ModernProgressView**: Custom animated progress indicator using CABasicAnimation

#### 4. Data Persistence
- **CoreData**: Stores scan history with HistoryEntity (barcode, product name, timestamp, flagged ingredients)
- **@AppStorage**: Persists user preferences (dark mode, blacklisted ingredients)
- PersistenceController manages Core Data stack with in-memory support for testing

#### 5. iOS 26 APIs
- Skipped

#### 6. Local Swift Package
- **BreakfastUIKit**: Modular package containing reusable UI components
  - Theme management system
  - Custom view modifiers
  - Shared UI components (headers, progress views)
  - Imported and used throughout the main app

#### 7. Unit Testing
- **HistoryStoreTests**: Validates CoreData persistence and CRUD operations
- **ProductViewModelTests**: Tests API response handling with mocked network requests
- Uses XCTest framework with custom URLProtocolMock for network testing

#### 8. Deep Linking
- **URL Scheme**: `notinmybreakfast://`
- **Supported Routes**:
  - `notinmybreakfast://home` - Navigate to home screen
  - `notinmybreakfast://scan?barcode={code}` - Deep link to specific product scan
  - `notinmybreakfast://blacklist` - Open blacklist management
  - `notinmybreakfast://history` - View scan history
- Typed parser with validation (rejects invalid/missing parameters)
- Handles cold-start scenarios when app is not running

#### 9. SwiftUI API Animations
- Skipped

#### 10. AppStorage
- **ThemeManager**: Observable theme manager with @AppStorage persistence
- Supports light and dark modes with custom color palettes
- Dynamic gradients and color schemes
- Theme toggle accessible from app header

## Project Structure

```
NotInMyBreakfast/
├── NotInMyBreakfast/           # Main app target
│   ├── Views/                  # SwiftUI views (Scan, Results, History, Blacklist)
│   ├── ViewModels/             # Observable view models and stores
│   ├── Models/                 # Data models and CoreData entities
│   ├── Services/               # Service layer (BarcodeDetector)
│   ├── Helpers/                # Helper classes (ImagePicker)
│   └── CoreData/               # CoreData model files
├── Packages/
│   └── BreakfastUIKit/         # Local Swift package for reusable UI components
└── NotInMyBreakfastTests/      # Unit tests

```
