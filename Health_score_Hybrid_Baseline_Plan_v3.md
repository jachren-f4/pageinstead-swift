# PageInstead – Hybrid Baseline & Time Saved Plan (v3)

## Overview
This document defines how PageInstead establishes a **baseline of daily screen usage**, measures **time saved**, and expresses progress as a **Screen Health Score (0–100%)**.  
This version adds:  
- a default placeholder health score for the first 24 hours,  
- long-term historical storage for up to six months, and  
- a debug footer in the Settings screen showing real-time screen time and health score.

---

## Objectives
1. Estimate initial screen time baseline immediately after onboarding.  
2. Replace estimate with real usage data after calibration (3–7 days).  
3. Display a default 0.75 (75%) health score during the first 24 hours.  
4. Continuously compare daily screen time against the baseline.  
5. Store historical data for up to six months.  
6. Display real-time screen time and health score in Settings footer for debug and QA purposes.

---

## Architecture Overview
| Component | Purpose |
|------------|----------|
| **FamilyControls Framework** | Request authorization for screen usage tracking |
| **DeviceActivityMonitor** | Track app usage for selected distracting apps |
| **App Group Storage** | Persist baseline, usage, daily summaries, and health score history |
| **Main App (Flutter/SwiftUI)** | Display time saved, historical charts, and Screen Health Score |
| **Settings Screen Footer** | Show real-time screen time (hh:mm) and current health score |

---

## Flow Diagram

```
User installs app
   ↓
Onboarding → Self-estimated baseline
   ↓
Request Screen Time authorization
   ↓
Start DeviceActivityMonitor for selected apps
   ↓
During first 24 hours → use default score (0.75)
   ↓
After 24 hours → calculate real health score
   ↓
Store daily data points and build six-month history
```

---

## Step-by-Step Implementation

### 1. Onboarding: Self-Estimated Baseline
User provides a quick estimate of daily usage hours.  
Store this as `baseline_estimated` (in minutes):
```swift
let defaults = UserDefaults(suiteName: "group.com.pageinstead")
defaults?.set(estimatedMinutes, forKey: "baseline_estimated")
```

### 2. Authorization and Monitoring
Request permission and begin tracking:
```swift
try await AuthorizationCenter.shared.requestAuthorization(for: .individual)

let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 0, minute: 0),
    intervalEnd: DateComponents(hour: 23, minute: 59),
    repeats: true
)
try DeviceActivityCenter.shared.startMonitoring(.daily, during: schedule)
```

---

## 3. Default Health Score for First 24 Hours

### Behavior
- For the first 24 hours after authorization, there is not enough data to compute real usage.
- Display a **fixed default Screen Health Score of 0.75 (75%)**.
- Once 24 hours of tracking data exists, switch to computed scores.

Implementation:
```swift
let firstInstall = defaults?.object(forKey: "install_date") as? Date ?? Date()
if defaults?.object(forKey: "install_date") == nil {
    defaults?.set(Date(), forKey: "install_date")
}

let hoursSinceInstall = Date().timeIntervalSince(firstInstall) / 3600
if hoursSinceInstall < 24 {
    healthScore = 75.0
} else {
    // Compute actual score based on DeviceActivity data
}
```

---

## 4. Calculating Screen Health Score

| Term | Definition |
|------|-------------|
| **Healthy Usage Threshold (HUT)** | 1.5 hours/day (90 min) |
| **Baseline Usage (B)** | User’s measured average before blocking |
| **Daily Usage (D)** | Today’s total minutes |
| **Screen Health Score (SHS)** | Normalized scale toward HUT |

Formula:
```text
If D >= B → SHS = max(0, 100 - ((D - HUT) / (B - HUT)) * 100)
If D < HUT → SHS = 100
Clamp SHS between 0 and 100
```

---

## 5. Historical Data Storage (6-Month Retention)

### Purpose
Allow users to view historical charts for up to six months (≈180 days).

### Data Structure
Use a lightweight JSON array stored in App Group container:
```swift
struct DaySummary: Codable {
    let date: String      // "2025-10-31"
    let usageMinutes: Int
    let healthScore: Double
}
```

Append new daily entry:
```swift
var history = loadHistory() // load from JSON file
let summary = DaySummary(date: todayString, usageMinutes: todayMinutes, healthScore: todayScore)
history.append(summary)

// Keep only last 180 days
if history.count > 180 {
    history.removeFirst(history.count - 180)
}

saveHistory(history)
```

Stored in shared container path:
```
/Library/Group Containers/group.com.pageinstead/ScreenTimeHistory.json
```

Flutter can read this via platform channel for chart rendering.

---

## 6. Settings Screen Footer – Debug Information

Add a footer at the bottom of the Settings screen showing **real-time screen time and health score**.

### Format
```
v1.0.0 | Screen Time: 01:37 | Health Score: 84%
```

### Implementation Example (SwiftUI)
```swift
struct SettingsFooter: View {
    @State private var realtimeUsage = "00:00"
    @State private var currentScore = 75.0

    var body: some View {
        HStack {
            Text("v1.0.0")
            Spacer()
            Text("Screen Time: \(realtimeUsage) | Health Score: \(Int(currentScore))%")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .onAppear {
            updateRealtimeData()
        }
    }

    func updateRealtimeData() {
        // Fetch current day’s usage minutes from shared container
        // Convert to hh:mm and read currentScore from UserDefaults
    }
}
```

This footer remains visible only in **debug** or **internal testing** builds.

---

## 7. Persistence Keys
| Key | Description |
|-----|--------------|
| `install_date` | App install date for first 24h logic |
| `baseline_estimated` | Estimated screen time (minutes) |
| `baseline_measured` | Observed baseline after calibration |
| `baseline_active` | Current baseline in use |
| `screen_health_score` | Daily calculated score (0–100%) |
| `screen_time_today` | Total minutes today |
| `screen_time_history` | JSON array for 6-month data |

---

## 8. Future Enhancements
- Weekly averages and trend lines.  
- Cloud backup for multi-device continuity.  
- Option for exporting 6-month history as CSV.  
- Automatic purge of history older than 180 days.

---

**Author:** PageInstead Engineering  
**Version:** v3  
**Last Updated:** October 2025
