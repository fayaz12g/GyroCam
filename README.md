# GyroCam
*Spoilers: I let DeepSeek AI write the markdown cause its so much faster, I just gave him my code and said to write it*

<div align="center">
  <img src="favicon/web-app-manifest-512x512.png" width="200" height="200" alt="GyroCam Logo">
</div>

**The Smart Orientation-Conscious Camera App**  
*Never suffer from sideways videos again!*

<a id="download-latest" href="#" class="button" style="padding: 10px 15px; background-color: #007bff; color: white; border-radius: 5px; text-decoration: none;">Download Latest Release</a>

---

## Demo Video 🎥

<iframe width="560" height="315" src="https://www.youtube.com/embed/q6XoJlkMB5Q" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

---

## About GyroCam 🧭

GyroCam revolutionizes mobile videography by automatically handling device orientation changes. Our unique **Auto-Orientation System** stops and restarts recording every time you rotate your device, ensuring perfect portrait/landscape alignment in every clip.

Key Innovation:  
✅ **Orientation Lock** - Maintains natural perspective during complex movements  
✅ **Seamless Restart** - Instant recording continuation after rotation  

---

### ✂️ New Seamless Stitching Mode

Introducing the **Seamless Stitching** feature! This advanced mode eliminates gaps between clips, outputting a single continuous video where every device flip is pre-edited for you. The result? A perfectly smooth, uninterrupted final clip that automatically handles your orientation changes without missing a beat.

This revolutionary update combines every clip into one length-perfect recording, so you no longer need to manually edit or align clips. Just capture and let **GyroCam** handle the rest!


---

## Features 🚀

### 📐 Orientation Intelligence
- Real-time gyroscopic monitoring
- Orientation badge overlay
- Landscape lock override
- Face up/down detection

### 🎥 Professional Capture
- **Resolutions**: 4K UHD | 1080p | 720p  
- **Frame Rates**: 240fps | 120fps | 60fps | 30fps  
- HDR10+ Support  
- Multi-lens switching (Wide/Ultra Wide/Tele)  
- Pro Mode: Manual ISO & Shutter Speed

### ⚙️ Customization
- Dynamic theme colors  
- Customizable UI elements:
  - Zoom/Focus bars  
  - Quick Settings panel  
  - Preview maximization  
- Smart aspect ratio preservation

### 📱 Device Optimization
- iPhone & iPad support  
- iOS 18 ready  
- Background processing  
- Low-light enhancements

---

## Installation 📲

### Sideloading Instructions:
1. If you are on GitHub, download latest IPA from [here](https://github.com/fayaz12g/GyroCam/releases/latest)
   Alternativly, if you are on the site, click the button below:
   <a id="download-latest" href="#" class="button" style="padding: 10px 15px; background-color: #007bff; color: white; border-radius: 5px; text-decoration: none;">Download Latest IPA</a>
2. Install [Sideloadly](https://sideloadly.io/)
3. Connect iOS device & trust computer
4. Drag IPA into Sideloadly
5. Enter Apple ID (app-specific password recommended)
6. Click Start!

*Note: Requires free developer account (7-day signing) or paid account for year-long install*

---

## Changelog 📜

- [View Full Changelog](CHANGELOG.md)

---

## Contributing 🤝

We welcome issues and PRs! Please review our:
- [Contribution Guidelines](CONTRIBUTING.md)
- [Roadmap](ROADMAP.md)
- [Privacy Policy](PRIVACY.md)

---

<div align="center">
  *An app by Fayaz*
</div>

<script>
  // Ignore this section if you are viewing on GitHub (but you should go to fayaz.one/GyroCam)
  fetch('https://api.github.com/repos/fayaz12g/GyroCam/releases/latest')
    .then(response => response.json())
    .then(data => {
      const ipaAsset = data.assets.find(asset => asset.name.endsWith('.ipa'));
      if (ipaAsset) {
        document.getElementById('download-latest').href = ipaAsset.browser_download_url;
      }
    })
    .catch(error => console.error('Error fetching latest release:', error));
</script>

---
