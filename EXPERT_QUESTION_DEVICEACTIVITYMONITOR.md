# Question for Swift Expert: DeviceActivityMonitor Event Tracking Issue

## Context from Previous Discussion

You previously helped us identify that **Shield Configuration Extensions cannot write to App Group storage** due to iOS platform restrictions. Based on your recommendation, we implemented a **DeviceActivityMonitor extension** to track when apps are blocked.

## What We've Implemented

### Architecture
```
User blocks apps
    ↓
ScreenTimeService applies shields + starts DeviceActivityCenter monitoring
    ↓
Shield Extension displays quote (can only read, not write)
    ↓
DeviceActivityMonitor detects usage → saves event to App Group ✅
    ↓
Main app reads events and displays history
```

### DeviceActivityMonitor Setup

**In ScreenTimeService.swift:**
```swift
func startMonitoring(for selection: FamilyActivitySelection) {
    let schedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: 0, minute: 0),
        intervalEnd: DateComponents(hour: 23, minute: 59),
        repeats: true
    )

    var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

    if !selection.applicationTokens.isEmpty {
        let eventName = DeviceActivityEvent.Name("blockedAppUsage")
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            threshold: DateComponents(second: 1)  // Trigger after 1 second
        )
        events[eventName] = event
    }

    try activityCenter.startMonitoring(monitoringActivityName, during: schedule, events: events)
}
```

**In DeviceActivityMonitorExtension.swift:**
```swift
override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    print("📊 DeviceActivityMonitor: Interval started")

    // Save a test event to verify monitor is working
    saveBlockingEvent(eventName: "intervalStart", activityName: activity.rawValue)
}

override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    print("🚨 DeviceActivityMonitor: Event threshold reached!")

    // Save the blocking event to App Group
    saveBlockingEvent(eventName: event.rawValue, activityName: activity.rawValue)
}

private func saveBlockingEvent(eventName: String, activityName: String) {
    let quote = // ... get quote
    let event = ShieldEvent(
        quoteId: quote.id,
        timestamp: Date().timeIntervalSince1970,
        blockedApp: "Blocked App"
    )
    ShieldDataStore.shared.saveShieldEvent(event)  // ✅ This works!
}
```

## Current Behavior (Problem)

### What Works ✅
1. DeviceActivityMonitor extension builds and embeds successfully
2. Main app can write/read from App Group (verified)
3. `intervalDidStart` fires once per day and saves an event
4. Events saved from DeviceActivityMonitor appear in Quote History

### What Doesn't Work ❌
1. User opens blocked app 10+ times
2. Shield displays quotes correctly each time
3. User waits 2-5 seconds after each app open
4. **Only 1-2 events appear in history** (the intervalStart event + maybe one threshold event)
5. `eventDidReachThreshold` rarely fires (maybe once per monitoring interval?)

### Observations
- The 1-second threshold event seems to track **cumulative usage time** across the entire monitoring interval (24 hours)
- Once the threshold is reached, the event doesn't fire again until the next monitoring interval
- This means we only get one event per day, not one per app open attempt

## Our Questions

### 1. Is `DeviceActivityEvent` with thresholds the wrong approach for tracking app blocks?

We want to track **every time a user tries to open a blocked app**, not cumulative usage time. It seems like `DeviceActivityEvent` thresholds are designed for parental controls (e.g., "alert when child has used TikTok for 1 hour today"), not for detecting individual blocking attempts.

**Question:** What's the correct API to detect when a shielded app is accessed/blocked?

### 2. Alternative Approaches?

Since DeviceActivityMonitor callbacks don't seem suited for tracking individual shield displays, what should we do?

**Option A: Is there a different DeviceActivityMonitor callback we should use?**
- Maybe there's a callback that fires on app launch attempts?
- Or a way to detect when shields are shown?

**Option B: Can Shield Extensions communicate with the main app?**
- Darwin Notifications?
- XPC Services?
- Any IPC mechanism that would allow Shield to notify the main app when displayed?

**Option C: Background Tasks in main app?**
- Can the main app run background tasks to check Screen Time logs?
- Is there an API to query "when was my shield last displayed"?

**Option D: Accept the limitation?**
- Maybe iOS intentionally doesn't provide APIs to track shield displays for privacy reasons?
- Should we accept that we can only track "intervals" not individual blocks?

### 3. DeviceActivityMonitor Best Practices?

**Current implementation:**
- 24-hour monitoring interval
- 1-second threshold on blocked app usage
- Save event when threshold reached

**Questions:**
- Should we use multiple shorter intervals instead of 24 hours?
- Are thresholds even applicable to shielded apps (since they're blocked immediately)?
- Is there a better way to configure DeviceActivityEvent for our use case?

### 4. What are DeviceActivityMonitor extensions actually designed for?

From Apple's documentation, it's not clear:
- Are they meant for parental control time limits?
- Can they detect individual app launches?
- Do they work with shielded apps at all?

## What We Need

We want to show users a history of quotes they've seen when trying to access blocked apps. Ideally:
- User opens blocked app → sees quote → event saved with that quote
- History shows: "2:30 PM - You tried to open Instagram and saw a quote from Maya Angelou"

Currently we can only save 1 event per monitoring interval, which means the history is mostly empty.

**Is there a way to achieve per-block tracking with iOS Screen Time APIs, or is this a fundamental limitation?**

## Files for Reference

- **ScreenTimeService.swift** - Lines 77-111 (monitoring setup)
- **DeviceActivityMonitorExtension.swift** - Full implementation
- **ShieldConfigurationExtension.swift** - Shield display (cannot write)
- **ISSUE_SUMMARY.md** - Complete documentation of Shield Extension write restriction issue

## Previous Expert Guidance That Worked

Your previous advice to use file-based storage in DeviceActivityMonitor was correct! The monitor CAN write to App Group successfully. The issue is just getting it to fire frequently enough.

## Summary

**Working:** DeviceActivityMonitor can save events to App Group ✅
**Not Working:** Events only fire 1-2 times per day, not per app block ❌
**Question:** What's the correct way to track individual shield displays with iOS APIs?

Thank you for your expertise! 🙏
