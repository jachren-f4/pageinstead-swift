#!/usr/bin/env python3
import uuid
import re
import sys

def generate_uuid():
    """Generate a 24-character hex UUID like Xcode uses"""
    return ''.join(uuid.uuid4().hex.upper()[:24])

def add_files_to_pbxproj(pbxproj_path, files_to_add):
    """
    Add files to Xcode project.pbxproj

    files_to_add: list of tuples (file_path, group_name, target_name)
    """
    with open(pbxproj_path, 'r') as f:
        content = f.read()

    # Find the main target UUID
    target_match = re.search(r'(/\* PageInstead \*/\s*=\s*\{[^}]*isa\s*=\s*PBXNativeTarget;[^}]*buildPhases\s*=\s*\([^)]*([A-F0-9]{24})[^)]*\))', content, re.DOTALL)
    if not target_match:
        print("ERROR: Could not find PageInstead target")
        return False

    sources_build_phase_uuid = target_match.group(2)
    print(f"Found sources build phase UUID: {sources_build_phase_uuid}")

    # Prepare new entries
    file_references = []
    build_files = []
    build_file_refs = []

    for file_path, group_name in files_to_add:
        file_name = file_path.split('/')[-1]
        file_ref_uuid = generate_uuid()
        build_file_uuid = generate_uuid()

        # Create file reference entry
        file_ref = f"\t\t{file_ref_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = \"<group>\"; }};"
        file_references.append((file_ref_uuid, file_name, file_ref))

        # Create build file entry
        build_file = f"\t\t{build_file_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} */; }};"
        build_files.append(build_file)
        build_file_refs.append((build_file_uuid, file_name))

        print(f"Created UUIDs for {file_name}: file={file_ref_uuid}, build={build_file_uuid}")

    # 1. Add PBXBuildFile entries
    build_file_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if build_file_section:
        insertion_point = build_file_section.end(0) - len('/* End PBXBuildFile section */')
        for build_file in build_files:
            content = content[:insertion_point] + build_file + '\n' + content[insertion_point:]
            insertion_point += len(build_file) + 1
        print("✓ Added PBXBuildFile entries")
    else:
        print("ERROR: Could not find PBXBuildFile section")
        return False

    # 2. Add PBXFileReference entries
    file_ref_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)', content, re.DOTALL)
    if file_ref_section:
        insertion_point = file_ref_section.end(0) - len('/* End PBXFileReference section */')
        for _, _, file_ref in file_references:
            content = content[:insertion_point] + file_ref + '\n' + content[insertion_point:]
            insertion_point += len(file_ref) + 1
        print("✓ Added PBXFileReference entries")
    else:
        print("ERROR: Could not find PBXFileReference section")
        return False

    # 3. Add to Sources build phase
    sources_phase_pattern = rf'({sources_build_phase_uuid} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)'
    sources_match = re.search(sources_phase_pattern, content, re.DOTALL)
    if sources_match:
        insertion_point = sources_match.end(0)
        for build_uuid, file_name in build_file_refs:
            ref_line = f'\n\t\t\t\t{build_uuid} /* {file_name} in Sources */,'
            content = content[:insertion_point] + ref_line + content[insertion_point:]
            insertion_point += len(ref_line)
        print("✓ Added files to Sources build phase")
    else:
        print("ERROR: Could not find Sources build phase")
        return False

    # 4. Add to appropriate groups
    for (file_ref_uuid, file_name, _), (file_path, group_name) in zip(file_references, files_to_add):
        # Find the group
        if group_name == "Components":
            group_pattern = r'([A-F0-9]{24} /\* Components \*/ = \{[^}]*children = \([^)]*)'
        elif group_name == "Tutorial":
            group_pattern = r'([A-F0-9]{24} /\* Tutorial \*/ = \{[^}]*children = \([^)]*)'
        else:
            print(f"WARNING: Unknown group {group_name}")
            continue

        group_match = re.search(group_pattern, content, re.DOTALL)
        if group_match:
            insertion_point = group_match.end(0)
            ref_line = f'\n\t\t\t\t{file_ref_uuid} /* {file_name} */,'
            content = content[:insertion_point] + ref_line + content[insertion_point:]
            print(f"✓ Added {file_name} to {group_name} group")
        else:
            print(f"WARNING: Could not find {group_name} group")

    # Write back
    with open(pbxproj_path, 'w') as f:
        f.write(content)

    print("\n✅ Successfully added all files to project")
    return True

if __name__ == '__main__':
    pbxproj_path = '/Users/joakimachren/pageinstead-swift/PageInstead.xcodeproj/project.pbxproj'

    files_to_add = [
        ('PageInstead/Core/DesignSystem/Components/TooltipArrow.swift', 'Components'),
        ('PageInstead/Core/DesignSystem/Components/FrostedTooltip.swift', 'Components'),
        ('PageInstead/Features/Tutorial/QuoteTutorialOverlay.swift', 'Tutorial'),
    ]

    success = add_files_to_pbxproj(pbxproj_path, files_to_add)
    sys.exit(0 if success else 1)
