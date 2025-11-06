# Installing PageInstead on Other Devices (Before TestFlight Approval)

You can distribute PageInstead to testers **right now** without waiting for Family Controls distribution entitlement. Here are your options:

---

## Option 1: Direct Device Installation via Xcode (Recommended for Small Testing)

**Best for**: 1-5 testers who can physically meet you or be remote
**Limitations**: Up to 100 devices per year on your developer account
**Setup time**: 5-10 minutes per device
**Cost**: Free (included in Apple Developer account)

### How It Works

You can install directly to any iPhone using Xcode, just like you install to your own device.

### Requirements

**For you (developer)**:
- Xcode on your Mac
- Physical access to tester's device OR remote access via Xcode Devices window
- Apple Developer account (you have this ✅)

**For tester**:
- iPhone running iOS 16.0+
- Trust your developer certificate on their device

### Step-by-Step: Local Installation (In-Person)

1. **Add tester's device to your account**:
   - Connect their iPhone to your Mac via USB or USB-C
   - Open Xcode → **Window** → **Devices and Simulators**
   - Their device appears in left sidebar
   - Right-click → **Add to Provisioning Profile** (Xcode handles this automatically)

2. **Build and install**:
   ```bash
   # In terminal, from project directory
   xcodebuild -project PageInstead.xcodeproj -scheme PageInstead \
     -destination 'platform=iOS,id=THEIR_DEVICE_ID' \
     -allowProvisioningUpdates build
   ```

   Or in Xcode:
   - Select their device from device dropdown
   - Click **Run** (▶️) or press ⌘R
   - App installs and launches

3. **Tester trusts your developer certificate**:
   - On their iPhone: **Settings** → **General** → **VPN & Device Management**
   - Tap your developer profile (NA6936A56Q)
   - Tap **"Trust 'Joakim Achren'"**
   - App now works on their device!

### Step-by-Step: Remote Installation (Can't Meet in Person)

**Using Xcode Devices (WiFi)**:

1. **Tester enables WiFi sync**:
   - Connect their iPhone to a Mac with iTunes/Finder once
   - Enable "Sync with this iPhone over WiFi"
   - Or on iPhone: **Settings** → **General** → **Background App Refresh** → Enable

2. **Add their device remotely** (they need to give you UDID):

   **Tester gets their UDID**:
   - Install Apple Configurator 2 (free Mac app), or
   - Connect to Mac → Finder → Click iPhone → Shows "Serial Number" → Click it to reveal UDID, or
   - Use website: https://get.udid.io (they open on iPhone, shows UDID)

   **You register their UDID**:
   - Go to https://developer.apple.com/account/resources/devices/list
   - Click **"+"** button
   - **Platform**: iOS
   - **Device Name**: "Tester - John's iPhone" (descriptive name)
   - **Device ID (UDID)**: Paste their UDID
   - Click **"Continue"** → **"Register"**

3. **Build for their device**:
   - In Xcode: **Product** → **Clean Build Folder**
   - Toggle **"Automatically manage signing"** off and on (regenerates profiles with new device)
   - **Product** → **Archive**
   - **Window** → **Organizer** → Select your archive
   - Click **"Distribute App"**
   - Select **"Development"** (not App Store Connect)
   - Select **"All compatible device variants"**
   - Click **"Next"** through signing options
   - **Export** to a folder on your Mac

4. **Send IPA to tester**:
   - You'll get a `.ipa` file
   - Upload to Dropbox, Google Drive, or email (if <25MB)
   - **Important**: Expires in 7 days (free developer account) or 365 days (paid account - you have this ✅)

5. **Tester installs IPA**:

   **Option A: Using Apple Configurator 2** (Mac required):
   - Tester downloads Apple Configurator 2 (free)
   - Connects iPhone via USB
   - Drags `.ipa` file onto device in Configurator

   **Option B: Using AltStore** (no Mac required):
   - Tester installs AltStore: https://altstore.io
   - Downloads your `.ipa` file to iPhone
   - Opens in AltStore → **"Install"**
   - **Limitation**: Must refresh every 7 days

   **Option C: Using Sideloadly** (Windows/Mac):
   - Tester installs Sideloadly: https://sideloadly.io
   - Connects iPhone via USB
   - Selects `.ipa` file → Installs

6. **Tester trusts certificate**:
   - **Settings** → **General** → **VPN & Device Management**
   - Trust your developer profile

---

## Option 2: Ad Hoc Distribution (Best for Multiple Remote Testers)

**Best for**: 5-100 testers you can't meet in person
**Limitations**: 100 devices total per year, app expires after 365 days
**Setup time**: 30 minutes initial, 5 minutes per new tester
**Cost**: Free (included in Apple Developer account)

### How It Works

You create a **Distribution Profile** that includes specific device UDIDs, then build an IPA that works on those registered devices only.

### Step-by-Step

1. **Collect tester UDIDs**:
   - Send testers to: https://get.udid.io
   - Or have them find it: iPhone → **Settings** → **General** → **About** → **[Copy UDID after clicking on it]**
   - They send you their UDID (40-character hex string)

2. **Register all devices**:
   - Go to: https://developer.apple.com/account/resources/devices/list
   - Click **"+"** for each device
   - Add **Device Name** and **UDID**
   - Register all testers' devices

3. **Create Ad Hoc provisioning profile**:
   - Go to: https://developer.apple.com/account/resources/profiles/list
   - Click **"+"**
   - Select **"Ad Hoc"** distribution
   - Select **PageInstead** App ID
   - Select your **Distribution certificate** (Xcode manages this)
   - Select **all tester devices** you just registered
   - Name it: "PageInstead Ad Hoc"
   - Download the profile
   - Double-click to install in Xcode

4. **Repeat for extensions**:
   - Create Ad Hoc profiles for:
     - `com.joakimachren.PageInstead.ShieldConfiguration`
     - `com.joakimachren.PageInstead.DeviceActivityMonitor`
   - Select same devices for each

5. **Build Ad Hoc IPA**:
   ```bash
   # Clean first
   xcodebuild clean -project PageInstead.xcodeproj -scheme PageInstead

   # Archive for Ad Hoc
   xcodebuild archive \
     -project PageInstead.xcodeproj \
     -scheme PageInstead \
     -archivePath ./build/PageInstead.xcarchive \
     -configuration Release

   # Export IPA
   xcodebuild -exportArchive \
     -archivePath ./build/PageInstead.xcarchive \
     -exportPath ./build \
     -exportOptionsPlist ExportOptions.plist
   ```

   **Or in Xcode**:
   - **Product** → **Archive**
   - **Organizer** → **Distribute App**
   - Select **"Ad Hoc"**
   - Follow prompts
   - Export IPA

6. **Distribute IPA to testers**:
   - Upload to cloud storage (Dropbox, Google Drive, etc.)
   - Or use a distribution service (see Option 3)
   - Testers install using methods from Option 1, Step 5

---

## Option 3: Third-Party Distribution Services (Easiest for Testers)

**Best for**: Non-technical testers, professional beta testing
**Limitations**: Varies by service, usually free tier available
**Setup time**: 1 hour initial setup
**Cost**: Free tier available, paid plans $10-50/month

### Services That Work Without TestFlight

These services handle device registration and IPA distribution for you:

#### **Diawi** (Simplest, Free)
- **URL**: https://www.diawi.com
- **How it works**:
  1. Upload your IPA
  2. Get a download link
  3. Send link to testers
  4. They open on iPhone → Install
- **Free tier**: Unlimited uploads, expires after 30 days
- **Pros**: Dead simple, no account needed
- **Cons**: Still need to manually register UDIDs first

#### **AppCenter** (Microsoft, Professional)
- **URL**: https://appcenter.ms
- **How it works**:
  1. Create free account
  2. Create app in AppCenter
  3. Upload IPA via CLI or web
  4. Invite testers by email
  5. They get link → Install app
- **Free tier**: Unlimited apps, unlimited testers
- **Pros**: Tracks crashes, analytics, tester feedback
- **Cons**: Need to register UDIDs first

#### **Firebase App Distribution** (Google)
- **URL**: https://firebase.google.com/products/app-distribution
- **How it works**:
  1. Add Firebase to project
  2. Upload IPA via Firebase console
  3. Invite testers
  4. They install Firebase App Tester → Get your app
- **Free tier**: Yes (part of Firebase free plan)
- **Pros**: Integrated with Firebase ecosystem, good analytics
- **Cons**: Requires Firebase SDK (optional but recommended)

#### **InstallOnAir**
- **URL**: https://www.installonair.com
- **Free tier**: Up to 3 apps, 10 testers
- **Pros**: Simple, web-based
- **Cons**: Limited free tier

### Quick Setup Example: Diawi

1. **Build Ad Hoc IPA** (see Option 2)

2. **Upload to Diawi**:
   - Go to https://www.diawi.com
   - Drag IPA file
   - Wait for upload
   - Get link: `https://i.diawi.com/XXXXXX`

3. **Send to testers**:
   - Send link via email, Slack, text
   - They open on iPhone Safari
   - Tap **"Install PageInstead"**
   - Trust your certificate in Settings

4. **Repeat for updates**:
   - Build new IPA (increment build number)
   - Upload to Diawi
   - Send new link

---

## Option 4: Enterprise Distribution (NOT Recommended)

**Best for**: Large companies distributing internal apps
**Limitations**: Requires Apple Enterprise account ($299/year)
**NOT FOR YOU because**:
- Against Apple's terms for public beta testing
- Risk of account termination
- Only for internal company employees
- Not applicable for consumer apps

**Skip this option.**

---

## Comparison Table

| Method | Max Testers | Setup Time | Technical Skill | Best For |
|--------|-------------|------------|-----------------|----------|
| **Direct Xcode** | 100/year | 5 min/tester | Medium | 1-5 local testers |
| **Ad Hoc + Manual** | 100/year | 30 min setup | High | 5-20 tech-savvy testers |
| **Ad Hoc + Diawi** | 100/year | 1 hour setup | Medium | 10-50 mixed testers |
| **AppCenter** | 100/year | 1 hour setup | Medium | Professional beta testing |
| **TestFlight** | 10,000 | 2 hours setup | Low | After entitlement approval ✅ |

---

## Recommended Approach for PageInstead

**Phase 1: Now (While waiting for entitlement)**
1. Use **Direct Xcode installation** for 2-3 close friends/family
2. Test core functionality, gather feedback
3. Fix major bugs

**Phase 2: After initial testing (Week 2-3)**
1. Set up **Ad Hoc + Diawi** for 10-20 testers
2. Collect UDIDs, register devices
3. Build Ad Hoc IPA, upload to Diawi
4. Broader beta testing

**Phase 3: After entitlement approval (Week 4-6)**
1. Switch to **TestFlight** (much easier for testers)
2. Invite existing testers to TestFlight
3. Scale to 100+ testers if needed

---

## Step-by-Step: Quick Start for 5 Testers

**Today (30 minutes)**:

1. **Ask 5 friends for their UDID**:
   - Send them: "Go to https://get.udid.io on your iPhone and send me the code"
   - Or: Settings → General → About → Tap to copy UDID

2. **Register devices**:
   - https://developer.apple.com/account/resources/devices/list
   - Add all 5 devices

3. **Build Development IPA**:
   ```bash
   # In Xcode
   Product → Archive
   Distribute App → Development
   Export
   ```

4. **Upload to Diawi**:
   - https://www.diawi.com
   - Upload IPA
   - Copy link

5. **Send to testers**:
   - Text/email the Diawi link
   - Instructions: "Open on iPhone → Install → Trust certificate in Settings"

**Done!** 5 people testing PageInstead in 30 minutes.

---

## Important Notes

### Device Limits
- **100 devices per year** per developer account
- Resets annually (not rolling, but on membership renewal date)
- Once registered, a device counts toward limit even if you remove it
- Plan accordingly: Don't waste slots on test devices

### App Expiration
- **Development builds**: 7 days (free) or 365 days (paid account - you have this ✅)
- **Ad Hoc builds**: 365 days
- **TestFlight**: 90 days (but you can upload new builds)
- Testers must reinstall after expiration

### Family Controls Behavior
- **Development/Ad Hoc builds**: Family Controls works perfectly ✅
- **Distribution entitlement NOT required** for development builds
- All features work exactly as they will in production

### Trust Certificate Issue
- Testers MUST trust your developer certificate
- Path: Settings → General → VPN & Device Management
- One-time action per developer account
- Common first-time issue: "Untrusted Developer" error

---

## Troubleshooting

### "Unable to Download App"
- **Cause**: UDID not registered, or wrong provisioning profile
- **Fix**: Verify device UDID in https://developer.apple.com/account/resources/devices/list
- Rebuild IPA with updated profile

### "This app cannot be installed because its integrity could not be verified"
- **Cause**: App expired, or signature invalid
- **Fix**: Build fresh IPA, send new link

### "Untrusted Developer"
- **Cause**: Tester didn't trust your certificate
- **Fix**: Settings → General → VPN & Device Management → Trust

### Family Controls doesn't work on tester device
- **Cause**: Screen Time restrictions on their device
- **Fix**: Settings → Screen Time → Turn off restrictions temporarily

---

## Next Steps

1. **Choose your distribution method** based on number of testers
2. **Test with 2-3 people first** (use Direct Xcode method)
3. **Gather feedback and fix bugs**
4. **Scale up to 10-20 testers** (use Ad Hoc + Diawi)
5. **Wait for entitlement approval** (continue development)
6. **Switch to TestFlight** once approved (easiest for everyone)

---

## Summary

**You CAN distribute PageInstead right now!**

✅ Development/Ad Hoc builds work fully with Family Controls
✅ Up to 100 devices per year
✅ Free with your Apple Developer account
✅ Takes 30 minutes to set up for first 5 testers

**TestFlight is easier for testers, but you don't have to wait 4-6 weeks to start testing.**

Start with Direct Xcode for a few friends, then scale up with Ad Hoc + Diawi while waiting for Family Controls distribution approval.

---

**Need help setting this up? Let me know which method you want to use!** 🚀
