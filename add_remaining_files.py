#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    return ''.join(uuid.uuid4().hex.upper()[:24])

MAIN_SOURCES_UUID = "EE28FE8977D4009BE438432F"

files_to_add = [
    ("QuoteDetailSheet.swift", "History"),
    ("QuoteHistoryService.swift", "Services"),
]

with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

for filename, group_type in files_to_add:
    file_ref = generate_uuid()
    build_file = generate_uuid()
    print(f"{filename}: ref={file_ref}, build={build_file}")

    # Add PBXFileReference
    file_ref_section_end = content.find('/* End PBXFileReference section */')
    file_ref_entry = f"\t\t{file_ref} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};\n"
    content = content[:file_ref_section_end] + file_ref_entry + content[file_ref_section_end:]

    # Add PBXBuildFile
    build_file_section_end = content.find('/* End PBXBuildFile section */')
    build_file_entry = f"\t\t{build_file} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {filename} */; }};\n"
    content = content[:build_file_section_end] + build_file_entry + content[build_file_section_end:]

    # Add to Sources build phase
    sources_pattern = rf'({MAIN_SOURCES_UUID} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)
    if sources_match:
        insertion_point = sources_match.end(0)
        sources_addition = f"\n\t\t\t\t{build_file} /* {filename} in Sources */,"
        content = content[:insertion_point] + sources_addition + content[insertion_point:]

    # Add to appropriate group
    if group_type == "History":
        group_pattern = r'([A-F0-9]{24}) /\* History \*/ = \{[^}]*children = \([^)]*'
    elif group_type == "Services":
        group_pattern = r'([A-F0-9]{24}) /\* Services \*/ = \{[^}]*children = \([^)]*'

    group_match = re.search(group_pattern, content, re.DOTALL)
    if group_match:
        insertion_point = group_match.end(0)
        group_addition = f"\n\t\t\t\t{file_ref} /* {filename} */,"
        content = content[:insertion_point] + group_addition + content[insertion_point:]
        print(f"✓ Added {filename} to {group_type} group")

with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n✅ Successfully added all missing files!")
