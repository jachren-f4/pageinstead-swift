#!/usr/bin/env python3
import sys
import uuid

# Read the project file
with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Find StreakService.swift file reference
streak_file_ref = None
for line in content.split('\n'):
    if 'StreakService.swift' in line and 'PBXFileReference' in line:
        # Extract the UUID at the start of the line
        parts = line.strip().split(' ')
        if len(parts) > 0:
            streak_file_ref = parts[0]
            print(f"Found StreakService.swift file reference: {streak_file_ref}")
            break

if not streak_file_ref:
    print("ERROR: Could not find StreakService.swift file reference")
    sys.exit(1)

# Find DeviceActivityMonitor target's PBXSourcesBuildPhase
monitor_target_id = None
for line in content.split('\n'):
    if 'DeviceActivityMonitor' in line and 'PBXNativeTarget' in line:
        parts = line.strip().split(' ')
        if len(parts) > 0:
            monitor_target_id = parts[0]
            print(f"Found DeviceActivityMonitor target: {monitor_target_id}")
            break

if not monitor_target_id:
    print("ERROR: Could not find DeviceActivityMonitor target")
    sys.exit(1)

# Find the Sources build phase for DeviceActivityMonitor
lines = content.split('\n')
in_target = False
sources_phase_id = None

for i, line in enumerate(lines):
    if monitor_target_id in line and 'isa = PBXNativeTarget' in lines[i+1]:
        in_target = True
    elif in_target and 'buildPhases = (' in line:
        # Look for PBXSourcesBuildPhase in the next few lines
        for j in range(i+1, min(i+10, len(lines))):
            phase_id = lines[j].strip().split(' ')[0]
            # Now find this phase in the file to confirm it's a Sources phase
            for k, search_line in enumerate(lines):
                if phase_id in search_line and 'isa = PBXSourcesBuildPhase' in lines[k+1]:
                    sources_phase_id = phase_id
                    print(f"Found Sources build phase: {sources_phase_id}")
                    break
            if sources_phase_id:
                break
        break

if not sources_phase_id:
    print("ERROR: Could not find Sources build phase for DeviceActivityMonitor")
    sys.exit(1)

# Generate new UUID for build file
new_build_file_uuid = uuid.uuid4().hex[:24].upper()
print(f"Generated new build file UUID: {new_build_file_uuid}")

# Check if StreakService is already in the build phase
already_added = False
in_sources_phase = False
for i, line in enumerate(lines):
    if sources_phase_id in line and 'isa = PBXSourcesBuildPhase' in lines[i+1]:
        in_sources_phase = True
    elif in_sources_phase and 'files = (' in line:
        # Check the next lines until we hit closing paren
        for j in range(i+1, len(lines)):
            if ')' in lines[j]:
                break
            if streak_file_ref in lines[j]:
                already_added = True
                print("StreakService.swift is already in DeviceActivityMonitor target")
                break
        break

if already_added:
    print("Nothing to do - file is already in target")
    sys.exit(0)

# Create PBXBuildFile entry
build_file_entry = f"\t\t{new_build_file_uuid} /* StreakService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {streak_file_ref} /* StreakService.swift */; }};\n"

# Find where to insert the build file (in PBXBuildFile section)
new_lines = []
for i, line in enumerate(lines):
    new_lines.append(line)
    if '/* Begin PBXBuildFile section */' in line:
        new_lines.append(build_file_entry.rstrip())
        print(f"Added PBXBuildFile entry")

# Now add to the sources build phase files array
final_lines = []
in_sources_phase = False
for i, line in enumerate(new_lines):
    if sources_phase_id in line and i+1 < len(new_lines) and 'isa = PBXSourcesBuildPhase' in new_lines[i+1]:
        in_sources_phase = True
    elif in_sources_phase and 'files = (' in line:
        final_lines.append(line)
        # Add our build file reference
        final_lines.append(f"\t\t\t\t{new_build_file_uuid} /* StreakService.swift in Sources */,")
        print(f"Added file to Sources build phase")
        in_sources_phase = False
        continue
    final_lines.append(line)

# Write back
with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write('\n'.join(final_lines))

print("SUCCESS: Added StreakService.swift to DeviceActivityMonitor target")
