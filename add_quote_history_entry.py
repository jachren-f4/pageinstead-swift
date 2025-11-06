#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    return ''.join(uuid.uuid4().hex.upper()[:24])

# Known UUIDs
MAIN_SOURCES_UUID = "EE28FE8977D4009BE438432F"

# Generate UUIDs
file_ref = generate_uuid()
build_file = generate_uuid()

print(f"QuoteHistoryEntry file ref: {file_ref}")
print(f"QuoteHistoryEntry build: {build_file}")

with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Add PBXFileReference
file_ref_section_end = content.find('/* End PBXFileReference section */')
file_ref_entry = f"\t\t{file_ref} /* QuoteHistoryEntry.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuoteHistoryEntry.swift; sourceTree = \"<group>\"; }};\n"
content = content[:file_ref_section_end] + file_ref_entry + content[file_ref_section_end:]

# Add PBXBuildFile
build_file_section_end = content.find('/* End PBXBuildFile section */')
build_file_entry = f"\t\t{build_file} /* QuoteHistoryEntry.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* QuoteHistoryEntry.swift */; }};\n"
content = content[:build_file_section_end] + build_file_entry + content[build_file_section_end:]

# Add to Sources build phase
sources_pattern = rf'({MAIN_SOURCES_UUID} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)'
sources_match = re.search(sources_pattern, content, re.DOTALL)
if sources_match:
    insertion_point = sources_match.end(0)
    sources_addition = f"\n\t\t\t\t{build_file} /* QuoteHistoryEntry.swift in Sources */,"
    content = content[:insertion_point] + sources_addition + content[insertion_point:]
    print("✓ Added to Sources build phase")

# Add to Models group (find it by looking for AppGroup.swift)
models_pattern = r'([A-F0-9]{24}) /\* Models \*/ = \{[^}]*children = \([^)]*'
models_match = re.search(models_pattern, content, re.DOTALL)
if models_match:
    insertion_point = models_match.end(0)
    group_addition = f"\n\t\t\t\t{file_ref} /* QuoteHistoryEntry.swift */,"
    content = content[:insertion_point] + group_addition + content[insertion_point:]
    print("✓ Added to Models group")

with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n✅ Successfully added QuoteHistoryEntry.swift!")
