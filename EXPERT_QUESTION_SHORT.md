# DeviceActivityMonitor Event Tracking Question

## Quick Summary

Following your advice about Shield Extensions not being able to write, we implemented a **DeviceActivityMonitor extension** to track when users try to access blocked apps. The monitor CAN write to App Group successfully ✅, but events only fire once per day instead of per app block ❌.

## The Problem

**Setup:**
- 24-hour monitoring schedule
- DeviceActivityEvent with 1-second threshold on blocked apps
- User opens blocked app 10+ times → Shield shows quotes correctly
- **Only 1 event saved in history**

**Code:**
```swift
let event = DeviceActivityEvent(
    applications: selection.applicationTokens,
    threshold: DateComponents(second: 1)
)
try activityCenter.startMonitoring(activityName, during: schedule, events: events)
```

**Behavior:**
- `eventDidReachThreshold()` fires once when cumulative usage reaches 1 second
- Doesn't fire again until next monitoring interval (24 hours later)
- We need per-block tracking, not cumulative time tracking

## The Question

**Is DeviceActivityEvent the wrong API for tracking individual shield displays?**

It seems designed for parental controls ("alert after 1 hour of TikTok"), not for detecting each time a blocked app is opened.

**What's the correct way to track every time a user encounters a shield?**

Options we're considering:
- A: Different DeviceActivityMonitor callback?
- B: IPC from Shield Extension to main app? (Darwin notifications, XPC?)
- C: Background task to query Screen Time logs?
- D: Accept it's not possible (privacy by design)?

## What We Want

History showing: "2:30 PM - You tried to open Instagram and saw a Maya Angelou quote"

Currently only possible to track once per day.

---

**Is per-shield-display tracking achievable with iOS Screen Time APIs?**

Files: `DeviceActivityMonitorExtension.swift`, `ScreenTimeService.swift` (lines 77-111)
