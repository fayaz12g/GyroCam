# GyroCam Version History

## Beta Releases

### Beta 12 (0.1.12)

- **What's New**
  - Updated the app icon.

- **Fixed GitHub Issues**
  - *(None)*

### Beta 11 (0.1.11)

- **What's New**
  - Added WishKit integration for a custom feature wish list.
  - New profile view to manage a set name and email to be shared with WishKit.
  - Adjusted naming of "Upcoming Features" to "GitHub Roadmap" to better differentiate the new Wish List View.
  - Fixed haptics not working on rotation after accessing a sheet.
  - Fixed changelog entries all saying beta 4.
  - Removed the motion manager.
  - The app no longer crashes on startup due to async calls.
  - Camera, motion, and haptics are now killed when the app is not in focus (and restarted when back in focus).
  - Added an option to disable real orientation display of UI.
  - Segmented picker now uses correct text color.
  - Lock landscape no longer starts with portrait.
  - Fixed non-stitched clips saving in the incorrect orientation.
  - Added triggering for stopping and starting recording with volume up or down (optional).
  - The entire permissions row is now clickable and has a background to match other UI elements.
  - The GitHub roadmap page has been revamped.

- **Fixed GitHub Issues**
  - [46](https://github.com/fayaz12g/GyroCam/issues/46)
  - [49](https://github.com/fayaz12g/GyroCam/issues/49)
  - [50](https://github.com/fayaz12g/GyroCam/issues/50)
  - [51](https://github.com/fayaz12g/GyroCam/issues/51)
  - [53](https://github.com/fayaz12g/GyroCam/issues/53)
  - [55](https://github.com/fayaz12g/GyroCam/issues/55)
  - [56](https://github.com/fayaz12g/GyroCam/issues/56)

### Beta 10 (0.1.10)

- **What's New**
  - The camera and microphone no longer remain in use with the settings menu and photo library views open.
  - Addressed a bug where the new permissions page in settings used the wrong user color.
  - Adjusted badges in the privacy policy view to use the primary color.
  - Added notification usage descriptions to the privacy policy.
  - Settings Contrast renamed to Settings Backgrounds.
  - Settings can now be toggled between a sheet and full screen cover.
  - Added a new developer mode, which shows more settings.
  - Moved the settings sheet toggle, hide export sheet duration, and allow recording while saving options behind developer mode.
  - Updated the saving dots view to use an accurate export percentage.
  - Reordered the pulsing recording effect to be behind the stop button (now that they're different colors).
  - Added an option to disable the recording pulse.
  - Removed old code for focal adjustments.
  - The quick lens switcher now orients properly based on real orientation.
  - The ISO bar has been updated to have the new UI of the focus bar, including tap to switch to auto exposure, and moving the ISO thumb with value changes.
  - Manual ISO in settings is now more obvious with a header and uses the new GyroScroll.
  - Removed all warnings (again).
  - Renamed hardcoded 3x in quick lens switcher to "tele". May change to real number later.
  - Fixed an issue where returning from onboarding made the background show the camera.
  - Having settings backgrounds off now results in a whiter white or blacker black regardless of sheet or full screen cover.

- **Fixed GitHub Issues**
  - [32](https://github.com/fayaz12g/GyroCam/issues/32)
  - [33](https://github.com/fayaz12g/GyroCam/issues/33)
  - [38](https://github.com/fayaz12g/GyroCam/issues/38)
  - [44](https://github.com/fayaz12g/GyroCam/issues/44)
  - [48](https://github.com/fayaz12g/GyroCam/issues/48)

### Beta 9 (0.1.9)

- **What's New**
  - Concurrent exports now support the proper orientation handling.
  - Failed exports can now be restarted.
  - Junk from failed exports can now be purged.
  - The exports sheet now remains showing exports across force quitting the app.
  - Many internal overhauls to the system that handles mapping orientation changes to URLs.
  - Notifications are now delivered upon successful exports.
  - Notifications can be allowed or skipped in onboarding, and configured later in settings.
  - Animations have been added to the export sheet, with a pulsing progress bar and spinning hourglass.
  - Slightly updated the about view to have more conformant sizing.
  - Location privileges are now optional.
  - Background colors across navigation views are now consistent and conform to in-app contrast settings.
  - A new misc navigation page for permissions is visible. Accent color only appears when navigated to from settings, with the correct background too.
  - The background gradient is now a single custom view extension that can be used anywhere. This background indicates subsections of settings.
  - Fixed an incorrect SF Symbol in the Privacy Policy.
  - Introduced a new color option: Primary Color.
  - The focus bar updates position correctly in auto focus now, and has a better ring.
  - Privacy policy now conforms to accent color.
  - Settings backgrounds now conform to primary color.

- **Fixed GitHub Issues**
  - [45](https://github.com/fayaz12g/GyroCam/issues/45)
  - [47](https://github.com/fayaz12g/GyroCam/issues/47)

### Beta 8 (0.1.8)

- **What's New**
  - Implemented a customizable haptic on orientation change.
  - Fixed an issue in the capture tab causing the reset defaults button to become inaccessible.
  - The duration badge now matches the new glassy UI.
  - The duration badge is now split into sections with subheadings.
  - New double dictating how long to close the export sheet after queueing.
  - The export sheet now animates in and out properly.

- **Fixed GitHub Issues**
  - *(Add any relevant issues if needed)*

## Version 0.1.7 (Beta 7) — March 31, 2025

**Changed**
- Restored badge fonts and settings circle
- Updated bars to have the new glassy circles
- Restored settings button shape, bigger bolder icon
- Made the badges have rounded rectangular edges
- Updated the bars to fit the number better and have descriptors in line with ISO bar
- Updated the bars to all be the same length
- Revamped the privacy policy view to match the new about view
- Updated the gyrocam icon in the about view to match onboarding
- Reduced animation timings in settings

---

## Version 0.1.6 (Beta 6) — March 31, 2025

**Added**
- Added a motion manager to create depth with badges
- New toggle type replacing the old one
- New control bars category in settings
- New custom segmented pickers with headings

**Changed**
- Made the export stack button more modern and moved to a better place
- Updated the UI of the badges and settings button to have symmetry and match the visionOS-like iOS 19 leaks
- Update the belt to match this new UI
- Adjusted the sizing of the clip badge to match the orientation badge
- Reordered some settings to better fit the new system
- Reinvented the accent color picker with default presets included
- Updated the background in the About and Privacy Policy Views
- Completely revamped the about view to closely resemble the readme
- Internal name for pickers and toggles are prefixed with `Gyro`

**Fixed**
- Restored accent color customization
- Fixed a bug where the last clip is always upside down
- Fixed a bug making the new QuickSettingsView subtext hard to read
- Fixed a light mode issue of inconsistent backgrounds in settings
- Fixed the clipping of toggles on the far right (build 319)
- Adjusted font color of toggles based on accent color darkness
- Fixed lock landscape duration badge being blocked by orientation badge in portrait

**Fixed Issues**
- #41
- #42



### Beta 5 (0.1.5)

- **What's New**
  - Redesigned settings interface with modern floating tab bar
  - New belt-style navigation with animated tab transitions
  - Fixed orientation issues with final video segment after flipping
  - Enhanced settings organization with expandable sections
  - Added settings contrast toggle for better visibility
  - Moved export progress back to recording button
  - Modernized version history and information views
  - Improved the upcoming features view to pull directly from GitHub issues
  - Enhanced visual feedback for settings interactions

- **Fixed GitHub Issues**
  - [36](https://github.com/fayaz12g/GyroCam/issues/36)
  - [11](https://github.com/fayaz12g/GyroCam/issues/11)
  - [10](https://github.com/fayaz12g/GyroCam/issues/10)
  - [1](https://github.com/fayaz12g/GyroCam/issues/1)
  - [34](https://github.com/fayaz12g/GyroCam/issues/34)
  - [30](https://github.com/fayaz12g/GyroCam/issues/30)
  - [26](https://github.com/fayaz12g/GyroCam/issues/26)
  - [27](https://github.com/fayaz12g/GyroCam/issues/27)
  - [19](https://github.com/fayaz12g/GyroCam/issues/19)
  - [9](https://github.com/fayaz12g/GyroCam/issues/9)
  - [37](https://github.com/fayaz12g/GyroCam/issues/37)

### Beta 4 (0.1.4)

- **Badges**
  - A new **"Duration" badge** shows how long you've been recording for.
  - The duration badge changes the text color based on the backing accent color brightness.
  - Orientation Header renamed to **"orientation badge"** in the code.

- **Stitching**
  - The record saving button shows clip duration as a percentage increasing.
  - It hangs at 100% until complete.


### Beta 3 (0.1.3)

- **Settings**
  - New feature selection for export quality, though I always recommend the highest for HDR or 60FPS. This significantly increases export speed though.
  - Updated versioning naming conventions to match the new one throughout the changelog.
  - Added ISO control, and toggling auto exposure off works now.

- **Stitching**
  - Stitching can now take place in the background, including if you lock your phone!

- **Orientation Handling**
  - In Lock Landscape, badges now rotate to show you everything upright.
  - The above change also applies to the photo thumbnail and bar circles.

- **ISO Control**
  - A new ISO bar exists that works when auto exposure is off.
  
### Beta 2 (0.1.2)

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
