#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    """Generate a 24-character hex UUID like Xcode uses"""
    return ''.join(uuid.uuid4().hex.upper()[:24])

# Known UUIDs from the project
MAIN_SOURCES_UUID = "EE28FE8977D4009BE438432F"
MONITOR_SOURCES_UUID = "7D9A8CC00B17ED9FAA4773B4"

# Generate UUIDs for StreakService.swift
streak_service_file_ref = generate_uuid()
streak_service_main_build = generate_uuid()
streak_service_monitor_build = generate_uuid()

print(f"StreakService file ref: {streak_service_file_ref}")
print(f"StreakService main build: {streak_service_main_build}")
print(f"StreakService monitor build: {streak_service_monitor_build}")

# Read the project file
with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# 1. Add PBXFileReference
file_ref_section_end = content.find('/* End PBXFileReference section */')
file_ref = f"""\t\t{streak_service_file_ref} /* StreakService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StreakService.swift; sourceTree = "<group>"; }};
"""
content = content[:file_ref_section_end] + file_ref + content[file_ref_section_end:]
print("✓ Added PBXFileReference")

# 2. Add PBXBuildFile entries (one for each target)
build_file_section_end = content.find('/* End PBXBuildFile section */')
build_files = f"""\t\t{streak_service_main_build} /* StreakService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {streak_service_file_ref} /* StreakService.swift */; }};
\t\t{streak_service_monitor_build} /* StreakService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {streak_service_file_ref} /* StreakService.swift */; }};
"""
content = content[:build_file_section_end] + build_files + content[build_file_section_end:]
print("✓ Added PBXBuildFile entries")

# 3. Add to main target Sources build phase
main_sources_pattern = rf'({MAIN_SOURCES_UUID} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)'
main_sources_match = re.search(main_sources_pattern, content, re.DOTALL)
if main_sources_match:
    insertion_point = main_sources_match.end(0)
    sources_addition = f"""\n\t\t\t\t{streak_service_main_build} /* StreakService.swift in Sources */,"""
    content = content[:insertion_point] + sources_addition + content[insertion_point:]
    print("✓ Added to main target Sources build phase")
else:
    print("ERROR: Could not find main target Sources build phase")
    exit(1)

# 4. Add to DeviceActivityMonitor target Sources build phase
monitor_sources_pattern = rf'({MONITOR_SOURCES_UUID} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)'
monitor_sources_match = re.search(monitor_sources_pattern, content, re.DOTALL)
if monitor_sources_match:
    insertion_point = monitor_sources_match.end(0)
    sources_addition = f"""\n\t\t\t\t{streak_service_monitor_build} /* StreakService.swift in Sources */,"""
    content = content[:insertion_point] + sources_addition + content[insertion_point:]
    print("✓ Added to DeviceActivityMonitor target Sources build phase")
else:
    print("ERROR: Could not find DeviceActivityMonitor target Sources build phase")
    exit(1)

# 5. Add to Services group (find Services group UUID)
# Find Services group by looking for QuoteService in a group
services_group_pattern = r'([A-F0-9]{24}) /\* Services \*/ = \{[^}]*children = \([^)]*78E67807F5F21E946046830C[^)]*\)'
services_match = re.search(services_group_pattern, content, re.DOTALL)
if services_match:
    services_group_uuid = services_match.group(1)
    print(f"Found Services group: {services_group_uuid}")

    # Add StreakService to Services group
    services_children_pattern = rf'({services_group_uuid} /\* Services \*/ = \{{[^}}]*children = \([^)]*)'
    services_children_match = re.search(services_children_pattern, content, re.DOTALL)
    if services_children_match:
        insertion_point = services_children_match.end(0)
        group_addition = f"""\n\t\t\t\t{streak_service_file_ref} /* StreakService.swift */,"""
        content = content[:insertion_point] + group_addition + content[insertion_point:]
        print("✓ Added to Services group")
    else:
        print("WARNING: Could not find Services group children")
else:
    print("WARNING: Could not find Services group")

# Write back
with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n✅ Successfully added StreakService.swift to project!")
