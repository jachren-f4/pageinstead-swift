# TestFlight Deployment Guide for PageInstead

Complete step-by-step guide to deploy PageInstead to TestFlight for internal testing.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Active Apple Developer Account** ($99/year subscription)
- [ ] **Xcode 26.1** (you have this ✅)
- [ ] **Physical iOS device** for testing (you have: Joakim's iPhone 14 ✅)
- [ ] **Development Team**: NA6936A56Q (configured ✅)
- [ ] **Bundle ID**: `com.joakimachren.PageInstead` (set ✅)
- [ ] **Version**: 1.0 (Build 1) (current ✅)
- [ ] **Access to App Store Connect** at https://appstoreconnect.apple.com

---

## Part 1: App Store Connect Setup

### Step 1.1: Create App Record in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **"My Apps"**
3. Click the **"+"** button → **"New App"**
4. Fill in the form:
   - **Platform**: iOS
   - **Name**: PageInstead
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `com.joakimachren.PageInstead` (should appear in dropdown)
   - **SKU**: `pageinstead-001` (unique identifier for your records)
   - **User Access**: Full Access
5. Click **"Create"**

**Note**: The app name "PageInstead" must be unique in the App Store. If taken, you'll need to choose a different name for the public listing (you can keep your display name as "PageInstead" on the device).

### Step 1.2: Fill Required App Information

Even for internal testing, you need minimal information:

1. In your new app, go to **"App Information"** (left sidebar)
2. Set **"Privacy Policy URL"** (required):
   - Use a placeholder if needed: `https://pageinstead.app/privacy` (create later)
3. Go to **"Pricing and Availability"**
   - Set to **"Free"**
   - Select availability regions

---

## Part 2: Prepare Xcode Project for Distribution

### Step 2.1: Verify Bundle Identifiers

Check that all targets have correct bundle IDs:

1. Open `PageInstead.xcodeproj` in Xcode
2. Select project in navigator → **"PageInstead"** target
3. **General** tab → verify:
   - **Bundle Identifier**: `com.joakimachren.PageInstead`
   - **Version**: 1.0
   - **Build**: 1 (increment this for each TestFlight upload)
4. Repeat for extension targets:
   - **ShieldConfiguration**: `com.joakimachren.PageInstead.ShieldConfiguration`
   - **DeviceActivityMonitor**: `com.joakimachren.PageInstead.DeviceActivityMonitor`

### Step 2.2: Verify Signing & Capabilities

For **PageInstead** (main target):

1. **Signing & Capabilities** tab
2. **Automatically manage signing**: ✅ Checked (recommended)
3. **Team**: NA6936A56Q
4. **Signing Certificate**: Apple Distribution (will auto-generate)
5. **Provisioning Profile**: Xcode Managed Profile
6. **Capabilities** should show:
   - ✅ App Groups (`group.com.pageinstead`)
   - ✅ Family Controls

For **ShieldConfiguration** target:

1. Same team and auto-signing
2. **Capabilities**:
   - ✅ App Groups (`group.com.pageinstead`)
   - ❌ **NO Family Controls** (critical!)

For **DeviceActivityMonitor** target:

1. Same team and auto-signing
2. **Capabilities**:
   - ✅ App Groups (`group.com.pageinstead`)
   - ✅ Family Controls

### Step 2.3: Set Build Configuration to Release

1. **Product** menu → **Scheme** → **Edit Scheme**
2. Select **"Archive"** in left sidebar
3. **Build Configuration**: Set to **"Release"**
4. Click **"Close"**

---

## Part 3: Create Archive and Upload to TestFlight

### Step 3.1: Clean Build

1. **Product** → **Clean Build Folder** (or Shift+⌘+K)
2. Wait for "Clean Finished" message

### Step 3.2: Create Archive

1. In Xcode toolbar, select target device:
   - Change from "Joakim's iPhone 14" to **"Any iOS Device (arm64)"**
   - This ensures the build works on all devices

2. **Product** menu → **Archive**
   - This will take 2-5 minutes
   - You'll see build progress in the toolbar
   - Wait for "Archive succeeded" notification

3. **Organizer** window will open automatically
   - If not, go to **Window** → **Organizer** (or Option+⌘+Shift+O)
   - Your new archive should appear with version "1.0 (1)"

### Step 3.3: Distribute to App Store Connect

1. In Organizer, select your new archive
2. Click **"Distribute App"** (blue button on right)

3. **Select distribution method**:
   - Choose **"App Store Connect"**
   - Click **"Next"**

4. **Select destination**:
   - Choose **"Upload"** (not Export)
   - Click **"Next"**

5. **App Store Connect distribution options**:
   - ✅ **"Upload your app's symbols"** (recommended for crash reports)
   - ✅ **"Manage Version and Build Number"** (Xcode auto-increments)
   - Click **"Next"**

6. **Signing options**:
   - Choose **"Automatically manage signing"**
   - Click **"Next"**

7. **Review summary**:
   - Verify all targets are signed correctly
   - Verify entitlements match expectations:
     - Main app: App Groups + Family Controls
     - ShieldConfiguration: App Groups only
     - DeviceActivityMonitor: App Groups + Family Controls
   - Click **"Upload"**

8. **Upload progress**:
   - Takes 2-10 minutes depending on app size and connection
   - You'll see progress bar
   - Don't close Xcode during upload

9. **Success confirmation**:
   - "Upload Successful" message
   - Click **"Done"**

---

## Part 4: Wait for Processing

### Step 4.1: Check App Store Connect Processing Status

1. Go to https://appstoreconnect.apple.com
2. **My Apps** → **PageInstead**
3. **TestFlight** tab (top navigation)
4. **iOS** section → you should see your build with status:
   - **"Processing"** (yellow dot) - Apple is processing your build
   - **Time**: Can take 5 minutes to 2 hours (usually ~15-30 minutes)

### Step 4.2: Monitor Processing

You'll receive email notifications:
- "Your app is now processing" (immediate)
- "Your build has finished processing" (when ready)

Common processing steps:
1. **Processing** (5-30 min) - Apple analyzes your build
2. **Missing Compliance** - Export compliance question (see Step 5.1)
3. **Ready to Submit** - Available for internal testing ✅

**Troubleshooting**: If processing fails:
- Check email for rejection reason
- Common issues: Missing icons, invalid entitlements, API usage issues
- Fix in Xcode, increment build number, re-archive and upload

---

## Part 5: Configure Build for Testing

### Step 5.1: Provide Export Compliance Information

**Required for all builds** (even internal testing):

1. In App Store Connect → **TestFlight** → **iOS** → Click your build number
2. You'll see **"Export Compliance"** warning
3. Click **"Provide Export Compliance Information"**
4. Answer questions:
   - **"Is your app designed to use cryptography or does it contain or incorporate cryptography?"**
     - Answer: **NO** (PageInstead uses only standard iOS encryption)
   - If you use HTTPS/TLS only, answer NO
5. Click **"Start Internal Testing"**

### Step 5.2: Add Test Information (Optional but Recommended)

While viewing your build:
1. **What to Test** section → Click **"Add What to Test"**
2. Write notes for testers (example below)
3. Click **"Save"**

**Example test notes**:
```
PageInstead v1.0 (Build 1)

Test Focus:
- Complete onboarding flow (11 screens)
- Select apps to block and verify shields appear with quotes
- Test pause timer functionality
- Check unlock flow and streak tracking
- Verify health score calibration starts
- Test bookmarking quotes
- Check Books and History tabs

Known Issues:
- Health Score shows 75% during 3-day calibration period
- Screen Time simulator doesn't work (physical device required)

Please report bugs or feedback via [your preferred method]
```

---

## Part 6: Add Internal Testers

### Step 6.1: Understand Internal vs External Testing

**Internal Testing** (what you want now):
- ✅ Up to 100 testers
- ✅ Must be App Store Connect team members
- ✅ Builds available **immediately** (no Apple review)
- ✅ Perfect for development team testing
- ⚠️ Testers must have Apple ID associated with your team

**External Testing** (later, for broader beta):
- Up to 10,000 testers
- Anyone can test (don't need team access)
- ⚠️ Requires Apple review (1-2 days per build)
- ⚠️ Needs more complete app metadata

### Step 6.2: Add Team Members as Internal Testers

**Option A: Add existing team members**

1. **TestFlight** tab → **Internal Testing** (left sidebar)
2. Click **"App Store Connect Users"** section
3. You'll see list of team members
4. Toggle ON users you want as testers
5. They'll receive email invite automatically

**Option B: Invite new team members**

If testers aren't in your team yet:

1. Go to **Users and Access** (top navigation in App Store Connect)
2. Click **"+"** button
3. Enter tester's information:
   - **First Name**: Their first name
   - **Last Name**: Their last name
   - **Email**: Their Apple ID email (must be Apple ID)
   - **Role**: Developer, Marketing, or App Manager (all can test)
   - **Apps**: Select "PageInstead"
4. Click **"Invite"**
5. They'll receive email to accept invitation
6. Once accepted, go back to **TestFlight** → **Internal Testing**
7. Toggle them ON as tester

### Step 6.3: Create Internal Testing Group (Recommended)

Organize testers into groups:

1. **TestFlight** → **Internal Testing** → Click **"+"** next to "Internal Testing"
2. Create group:
   - **Group Name**: "Core Team" or "Development"
   - **Enable automatic distribution**: ✅ (new builds auto-sent to this group)
3. Click **"Create"**
4. **Add testers** to group:
   - Select App Store Connect users
   - Click **"Add"**
5. **Add build** to group:
   - Click **"+"** next to Builds
   - Select your "1.0 (1)" build
   - Click **"Add"**

---

## Part 7: Testers Install TestFlight

### Step 7.1: Tester Instructions

Send these instructions to your internal testers:

---

**Welcome to PageInstead Beta Testing!**

1. **Install TestFlight** (if you haven't already):
   - Open App Store on your iPhone
   - Search for "TestFlight"
   - Install the official Apple TestFlight app

2. **Accept Invitation**:
   - Check your email for "You're Invited to Test PageInstead"
   - Click **"View in TestFlight"** or **"Start Testing"**
   - This opens TestFlight app

3. **Install PageInstead**:
   - In TestFlight app, you'll see "PageInstead"
   - Tap **"Install"** or **"Update"** (if you had previous version)
   - Wait for installation to complete

4. **Launch and Test**:
   - Open PageInstead from home screen (not TestFlight)
   - Complete onboarding
   - **Important**: You need to grant Screen Time permissions when prompted
   - Test all features and report issues

5. **Send Feedback**:
   - Open TestFlight app
   - Tap "PageInstead" → "Send Beta Feedback"
   - Attach screenshots if needed
   - Or use [your preferred feedback method]

---

### Step 7.2: Monitor Tester Activity

In App Store Connect → **TestFlight** → **Internal Testing**:
- See who has **"Installed"** the app
- See who has **"Accepted"** invite but not installed
- See who has **"Invited"** status (pending)
- **Sessions**: Number of times testers opened the app
- **Crashes**: If any crashes occur

---

## Part 8: Uploading New Builds

After making changes and want to push new build:

### Step 8.1: Increment Build Number

1. In Xcode, select project → **PageInstead** target
2. **General** tab → **Build** field
3. Change from "1" to "2" (or next number)
4. **Important**: Update all extension targets too:
   - ShieldConfiguration
   - DeviceActivityMonitor
   - All must have same build number

**Quick command** to update all targets:
```bash
# Run this in terminal from project directory
agvtool next-version -all
```

Or in Xcode:
- Go to each target
- Manually increment Build number
- Keep Version (1.0) the same until major release

### Step 8.2: Repeat Archive & Upload Process

1. **Product** → **Clean Build Folder**
2. **Product** → **Archive**
3. **Distribute App** → Follow steps from Part 3
4. Wait for processing
5. Provide export compliance again
6. If you enabled **"Automatic distribution"** in your Internal Testing group:
   - Testers get notified automatically
   - Build installs automatically (if they enabled auto-updates)
7. If not automatic:
   - Manually add new build to testing group

### Step 8.3: Version vs Build Numbers

**Best practices**:
- **Version (MARKETING_VERSION)**: Customer-facing (1.0, 1.1, 2.0)
  - Change for feature releases
  - Example: 1.0 → 1.1 when adding major feature
- **Build (CURRENT_PROJECT_VERSION)**: Internal tracking (1, 2, 3, 4...)
  - Increment for every TestFlight upload
  - Example: 1.0 (1), 1.0 (2), 1.0 (3) during beta testing
  - Resets when version changes: 1.1 (1), 1.1 (2), etc.

---

## Part 9: TestFlight Best Practices

### Notifications
- **Testers receive notifications** when new builds available
- Configure in **TestFlight** → **Test Information** → **Notifications**

### Feedback Collection
- Use TestFlight's built-in feedback mechanism
- Or set up your own: Discord, Slack, email, bug tracker
- Include feedback instructions in "What to Test" notes

### Build Expiration
- TestFlight builds expire after **90 days**
- Upload new build before expiration
- Testers can't open app after expiration

### Testing Tips for PageInstead Specifically

**Critical tests**:
1. ✅ Onboarding completes successfully
2. ✅ Screen Time permission granted
3. ✅ Family Activity Picker shows apps
4. ✅ Shields appear when opening blocked apps
5. ✅ Quotes change every 5 minutes
6. ✅ Unlock flow works (30-second window)
7. ✅ Streak tracks correctly overnight
8. ✅ Health score calibrates after 3 days
9. ✅ Bookmarks persist across app launches
10. ✅ All tabs navigate correctly

**Test on various iOS versions**:
- iOS 16.0 (minimum supported)
- iOS 17.x
- iOS 18.x (recommended)

**Test on various devices**:
- iPhone SE (small screen)
- iPhone 14/15 (standard)
- iPhone 14/15 Pro Max (large screen)

---

## Part 10: Common Issues & Troubleshooting

### Issue: "No accounts with App Store Connect access"

**Solution**:
- Add team members in **Users and Access** first
- Assign them App Manager, Developer, or Marketing role
- Wait 5-10 minutes for system to update
- Then add as TestFlight testers

### Issue: Archive button grayed out

**Solutions**:
- Ensure you selected **"Any iOS Device (arm64)"** as target (not simulator)
- Check that scheme is set to release mode
- Verify all targets have valid signing

### Issue: "Failed to create provisioning profile"

**Solutions**:
- Check Bundle IDs are registered in Developer Portal
- Verify App Group is registered: `group.com.pageinstead`
- Try **manually** managing signing temporarily:
  1. Uncheck "Automatically manage signing"
  2. Generate provisioning profiles manually in Developer Portal
  3. Download and select in Xcode

### Issue: Upload fails with entitlements error

**Solutions**:
- Verify **ShieldConfiguration** has ONLY App Groups (no Family Controls)
- Check that App Group ID matches exactly: `group.com.pageinstead`
- Ensure all targets have matching team

### Issue: Build stuck in "Processing" for hours

**Solutions**:
- Usually resolves within 2 hours
- Check email for rejection notification
- If >4 hours, contact Apple Developer Support
- Try uploading again with incremented build number

### Issue: Testers can't find app in TestFlight

**Solutions**:
- Verify tester accepted email invitation
- Check tester is using correct Apple ID
- Ensure build is added to their testing group
- Build must finish processing first

### Issue: App crashes on tester devices but not yours

**Solutions**:
- Check **Crashes** section in TestFlight
- Enable **"Upload your app's symbols"** during distribution
- Review crash logs in App Store Connect → **TestFlight** → **Crashes**
- Test on same iOS version as tester

---

## Quick Reference Commands

```bash
# Check current version/build
grep -E "(MARKETING_VERSION|CURRENT_PROJECT_VERSION)" PageInstead.xcodeproj/project.pbxproj

# Increment build number (all targets)
agvtool next-version -all

# Check Xcode version
xcodebuild -version

# List available devices
xcrun devicectl list devices

# Clean derived data (if build issues)
rm -rf ~/Library/Developer/Xcode/DerivedData/PageInstead-*
```

---

## Timeline Summary

**First Upload** (one-time setup):
- Part 1 (App Store Connect setup): 10-15 minutes
- Part 2 (Prepare Xcode): 5-10 minutes
- Part 3 (Archive & Upload): 10-15 minutes
- Part 4 (Processing): 15-60 minutes
- Part 5 (Export compliance): 2 minutes
- Part 6 (Add testers): 5 minutes
- **Total**: ~1-2 hours

**Subsequent Uploads**:
- Increment build: 1 minute
- Archive & Upload: 10-15 minutes
- Processing: 15-60 minutes
- **Total**: ~30-75 minutes

---

## Next Steps After TestFlight

Once internal testing is stable:

1. **External Beta Testing**: Expand to more testers (no team membership required)
2. **App Review**: Submit for App Store review
3. **Production Release**: Launch to public
4. **Phased Release**: Gradual rollout to users
5. **Monitor Metrics**: Analytics, crashes, reviews

---

## Support Resources

- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer Portal**: https://developer.apple.com/account
- **TestFlight Documentation**: https://developer.apple.com/testflight/
- **Contact Apple Support**: https://developer.apple.com/contact/

---

## Checklist: Ready for First Upload?

Before starting Part 3 (Archive & Upload), verify:

- [ ] App record created in App Store Connect
- [ ] Bundle IDs match exactly in Xcode and App Store Connect
- [ ] Version: 1.0, Build: 1 (or higher)
- [ ] All targets signed with Team NA6936A56Q
- [ ] Entitlements correct (especially ShieldConfiguration = App Groups only)
- [ ] Build configuration set to Release
- [ ] Selected "Any iOS Device (arm64)" as target
- [ ] App tested on physical device successfully
- [ ] Privacy Policy URL added (or placeholder)
- [ ] At least one team member ready to test

**You're ready to upload!** Start with Part 3: Create Archive.

---

**Good luck with your TestFlight deployment! 🚀**
