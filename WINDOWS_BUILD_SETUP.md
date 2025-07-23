# Windows Build Configuration

This document outlines the changes made to ensure the XPro Delivery Admin Desktop App can be built successfully on Windows without naming conflicts or icon issues.

## Changes Made

### 1. Fixed Binary Name in CMakeLists.txt

**File:** `windows/CMakeLists.txt`
**Issue:** Spaces in the binary name can cause build errors on Windows
**Fix:** Changed binary name from `"Xpro Delivery Admin"` to `"XproDeliveryAdmin"`

```cmake
# Before
set(BINARY_NAME "Xpro Delivery Admin")

# After
set(BINARY_NAME "XproDeliveryAdmin")
```

### 2. Updated Windows Resource Configuration

**File:** `windows/runner/Runner.rc`
**Issue:** Inconsistent naming and spaces in file descriptions
**Fix:** Updated all string values to use consistent naming without spaces

```rc
# Before
VALUE "CompanyName", "Xpro Delivery" "\0"
VALUE "FileDescription", "Xpro Delivery Admin" "\0"
VALUE "InternalName", "Xpro Delivery Admin" "\0"
VALUE "OriginalFilename", "Xpro Delivery Admin.exe" "\0"
VALUE "ProductName", "Xpro Delivery Admin" "\0"

# After
VALUE "CompanyName", "XproDelivery" "\0"
VALUE "FileDescription", "XproDeliveryAdmin" "\0"
VALUE "InternalName", "XproDeliveryAdmin" "\0"
VALUE "OriginalFilename", "XproDeliveryAdmin.exe" "\0"
VALUE "ProductName", "XproDeliveryAdmin" "\0"
```

### 3. Updated Application Icon

**Source:** `assets/images/app_icon.png`
**Target:** `windows/runner/resources/app_icon.ico`
**Process:** Converted PNG to ICO format with multiple sizes (16x16, 32x32, 48x48, 64x64, 128x128, 256x256)

The application icon has been updated to use the XPro Delivery branding with the delivery truck and location pin design.

## Build Instructions

### For Windows Development

1. **Prerequisites:**
   - Windows 10 or later
   - Visual Studio 2019 or later with C++ development tools
   - Flutter SDK with Windows support enabled

2. **Build Commands:**
   ```bash
   # Debug build
   flutter build windows --debug
   
   # Release build
   flutter build windows --release
   ```

3. **Output Location:**
   - Debug: `build/windows/x64/runner/Debug/XproDeliveryAdmin.exe`
   - Release: `build/windows/x64/runner/Release/XproDeliveryAdmin.exe`

### Platform Compatibility

- **Linux:** Uses `xpro-delivery-admin` (kebab-case, appropriate for Linux)
- **Windows:** Uses `XproDeliveryAdmin` (PascalCase, no spaces, Windows-compatible)

## Icon Requirements

The Windows build uses the converted ICO file located at:
`windows/runner/resources/app_icon.ico`

This file contains multiple icon sizes as required by Windows:
- 16x16 pixels (small taskbar)
- 32x32 pixels (medium taskbar)
- 48x48 pixels (large taskbar)
- 64x64 pixels (extra large)
- 128x128 pixels (jumbo)
- 256x256 pixels (extra jumbo)

## Troubleshooting

### Common Issues

1. **Spaces in Binary Name:**
   - Symptoms: Build errors related to file paths
   - Solution: Ensure `BINARY_NAME` in `windows/CMakeLists.txt` has no spaces

2. **Missing Icon:**
   - Symptoms: Default Flutter icon appears instead of app icon
   - Solution: Verify `app_icon.ico` exists in `windows/runner/resources/`

3. **Resource Compilation Errors:**
   - Symptoms: RC.exe errors during build
   - Solution: Check `Runner.rc` file for syntax errors and proper string formatting

### Verification Steps

1. Check that the CMakeLists.txt binary name matches the resource file names
2. Verify the ICO file exists and is properly formatted
3. Ensure all resource strings use consistent naming without spaces

## Future Maintenance

When updating the app icon:
1. Update the source PNG file in `assets/images/app_icon.png`
2. Convert to ICO format using the conversion script or ImageMagick:
   ```bash
   # Using ImageMagick (if available)
   magick assets/images/app_icon.png -resize 256x256 windows/runner/resources/app_icon.ico
   
   # Or use the Python PIL script that was used during setup
   ```

3. Test the Windows build to ensure the new icon appears correctly
