# GyroCam Version History

## Beta Releases

### Beta 2 (0.1.2 - Current)

- **Haptics**:
  - Fixed an issue where haptics were tied to the record button.

- **Optical Zoom**:
  - Optical zoom now shows the correct multiplier based on device.

- **Photo Library**:
  - The video display now displays as a sheet.
  - The photo library has a partially done button to settings.
  - The grid view now shows library date sorting akin to masonry view.
  - The grid view now shows badges, pro mode info, and duration for landscape videos.

- **Internal Structure**:
  - Stitched and normal clips now use the same saving function.
  - Removed more redundant code such as error logging.
  - Separated enumerators to AppSettings.
  - Added folders for PhotoLibrary and Bars.
  - Separated structs from within `PhotoLibraryView` into their own files.

- **More Info Views**:
  - About view now pulls versioning info directly from the app.
  - Header bars positioning were fixed for the About view and Privacy Policy.
  - The changelog button was renamed to fit the header (version history).
  - Roadmap renamed back to upcoming features.
  - Upcoming features edited to reflect the GitHub issues closer, along with new section titles.
  - Minor verbiage changed in settings views for stitching navigation menu.
 
- **Other Fixes**:
  - Fixed an issue where the reset defaults confirmation displays continuously.



### Beta 1

**Sounds**
- Added a new looping sound when saving stitched video.

**Save Button**
- A new double timer counts down while saving to show progress.

**Haptics**
- Added haptics to record button, settings button, toggles, photo library button, and saving loop.
- For now haptics require you to interact with the record button first. A better solution will be implemented later.

**Settings**
- Added a setting to turn haptics off.
- Added a setting to turn sounds off.

**Versioning**
- Brought the app into Beta releases.

## Alpha Releases

### Alpha 016

**Video Saving**
- Videos now save with appropriate GRC filenames.
- Saved videos now contain location metadata.

**Onboarding**
- "Tweaked text in onboarding

**Other**
- "Adjusted badge locations

### Alpha 015 

### Onboarding
- Restructure with titles, sub bullets, and more symbols.
- Improved the clutter of page three as well as verbiage in other pages.
- Fixed an issue where the finish button did not work after reinstating privileges.

### Settings
- The settings view has changed from a sheet to a full-screen page.

### Stitching
- Stitching now works with SEAMLESS integration.
- Stitching is now on by default and no longer says beta.

### Recording Button
- A new saving indicator displays on the recording button.


### Alpha 014 

**Focus**
- The focus bar now has a tappable circle handle that turns on auto focus

**Stabilization**
- Stabilization added to settings
- Switch between no stabilization, standard, cinematic, and extreme, or auto

**Bug Fixes**
- Fixed more warnings for deprecated syntax

**Other**
- Onboarding gyro cam logo now has matching color scheme
- Light mode background reverted to white
- Moved some settings around
- Onboarding button shows next until the last page
- Centered onboarding button
- Updated permissions handling to navigate to settings and open onboarding on revoke

  
### Alpha 013

**Changelog**
- Renamed headers to be more aligned with proper descriptions

**Settings**
- Added new 'About' submenu containing the version number and a brief description
- Major restructure of the settings view
- An alert now pops up to display when default settings have been restored

**App Icon**
- Further changes have been made, reintroducing the color from previous iterations
- The app icon now incorporates the color against a rainbow background, with a consistent shadow in dark mode

**Onboarding**
- Centered the permissions page
- Change the color of the permissions page to accent color if seen before
- Fixed a clipping issue with the lock icon

**Bug Fixes**
- Removed a plethora of on change warnings to conform to iOS 17+
- Fixed issues involving location manager
- Load Latest thumbnail is now called on Photo Library Button after recording is saved


### Alpha 012
**Added new camera gestures**
- Drag across the screen to adjust focus while auto focus is off
- Hold down to switch lenses in a new picker, now in a square format with rotation and device theme conformity

**Recording Pulse Effect**
- Changed the pulse effect to only display while recording
- Updated the pulse effect to be faster and start from the center

**Other**
- Added a new toggle to show/hide quick settings
- The zoom bar now moves at an exponentially increasing rate (such that 1x to 2x is the same as 5x to 10x)
- Added a new torch option to the quick settings bar and settings page. This toggles the camera flash
- Removed experimental shutter speed due to crashing on some devices
- Updated the photo library button to refer to camera manager directly to handle rotation
- Updated the changelog view to handle titles and sub bullets, including a full revamp of all previous entries
- Added animations for the focal bar, zoom bar, and quick settings menu disappearing


### Alpha 011
- **Logo Update:** Updated the app logo, removing the camera icon for a cleaner look.
- **Orientation Badge:** Added context menu parity to hide the orientation badge for better UI customization.
- **Onboarding View:** Refined the onboarding experience with new content describing camera controls to help users understand their functionality.
- **Zoom Bar:** The zoom bar is now fully functional and has been brought out of beta.
- **Pinch-to-Zoom Gestures:** Implemented pinch-to-zoom gestures for intuitive zoom control, working seamlessly with the zoom bar.
- **Focus Bar:** Introduced a new Focus Bar, enabling manual focus controls for advanced users.
- **Focus and Auto Focus Logic:** Added logic to make manual focus and auto focus mutually exclusive, ensuring a smoother experience when adjusting focus.
- **Tap-to-Focus:** Added a tap-to-focus system, allowing users to tap the screen to set focus when auto focus is off.
- **Continuous Auto Focus:** Introduced a continuous auto focus system that tracks and adjusts focus automatically.
- **Auto Exposure Controls:** Added auto exposure control, with manual shutter speed and ISO options available for future functionality (shells only, no active functionality yet).

### Alpha 010
**Onboarding**  
- Unified permissions screen  
- Adaptive color theming  
- Camera control tutorials  

**Orientation**  
- Landscape lock feature  
- Enhanced face up/down detection  

**Compatibility**  
- iOS 18 minimum requirement  
- New device-specific app icons  

### Alpha 009
**Beta Features**  
- Zoom Bar (beta release)  
- Auto-stitch clips (experimental)  

**Policy Updates**  
- Added privacy policy section  
- Consolidated camera options  

### Alpha 008
**UI Customization**  
- Preserve Aspect Ratio toggle  
- Clip/Orientation badge controls  
- Minimal orientation header option  

**Workflow Improvements**  
- Re-centered Quick Settings panel  
- Settings button direct access  
- Face up/down orientation support  

### Alpha 007
**Audio/Visual**  
- Added recording sound effects  
- New rainbow app icon  

**Photo Library**  
- Aspect ratio preservation  
- Pro mode information badges  

### Alpha 006
**Device Support**  
- Full iPad compatibility  
- Added 120/240 FPS modes  

**Technical Updates**  
- iOS 17 support baseline  
- Device-based lens detection  

### Alpha 005
**Customization**  
- Dynamic accent color theming  
- Preview size toggle  

**Performance**  
- Background video processing  
- Redesigned record button  

### Alpha 004
**Feature Foundation**  
- Complete Quick Settings panel  
- Photo library integration  
- Basic geotagging support  

**Framework**  
- Initial changelog implementation  
- Orientation header fixes  

## Internal Builds

### Alpha 003
- Double-tap lens switching  
- Dynamic UI color schemes  
- Recording status indicators  

### Alpha 002
- Animated iOS-style record button  
- System-wide dark/light mode  
- Persistent orientation headers  

### Alpha 001
- 4K/1080p resolution support  
- Front camera implementation  
- 60FPS default recording  

### Alpha 00 (Foundation)
- Gyroscopic clip splitting  
- 720p HDR recording  
- Basic orientation detection

---

*Full version history available in-app. Earlier internal builds (Pre-004) contain experimental features not intended for public use.*
