#!/usr/bin/env python3
import uuid
import sys

# Files to add
files_to_add = [
    {
        "name": "QuoteHistoryEntry.swift",
        "path": "PageInstead/Core/Models/QuoteHistoryEntry.swift",
        "target": "PageInstead"
    },
    {
        "name": "QuoteHistoryService.swift",
        "path": "PageInstead/Core/Services/QuoteHistoryService.swift",
        "target": "PageInstead"
    },
    {
        "name": "StreakService.swift",
        "path": "PageInstead/Core/Services/StreakService.swift",
        "target": "PageInstead"
    }
]

# Read project file
with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

lines = content.split('\n')

# Find PageInstead target
target_id = None
for line in lines:
    if 'com.joakimachren.PageInstead' in line and 'PRODUCT_BUNDLE_IDENTIFIER' in line:
        # Go back to find the target
        for i, l in enumerate(lines):
            if 'PageInstead' in l and 'isa = PBXNativeTarget' in lines[i+1]:
                target_id = l.strip().split(' ')[0]
                break
        break

if not target_id:
    print("ERROR: Could not find PageInstead target")
    sys.exit(1)

print(f"Found PageInstead target: {target_id}")

# Find Sources build phase
sources_phase_id = None
in_target = False
for i, line in enumerate(lines):
    if target_id in line and 'isa = PBXNativeTarget' in lines[i+1]:
        in_target = True
    elif in_target and 'buildPhases = (' in line:
        for j in range(i+1, min(i+10, len(lines))):
            phase_id = lines[j].strip().split(' ')[0]
            for k, search_line in enumerate(lines):
                if phase_id in search_line and 'isa = PBXSourcesBuildPhase' in lines[k+1]:
                    sources_phase_id = phase_id
                    print(f"Found Sources build phase: {sources_phase_id}")
                    break
            if sources_phase_id:
                break
        break

if not sources_phase_id:
    print("ERROR: Could not find Sources build phase")
    sys.exit(1)

# Process each file
new_build_files = []
new_file_refs = []

for file_info in files_to_add:
    file_ref_uuid = uuid.uuid4().hex[:24].upper()
    build_file_uuid = uuid.uuid4().hex[:24].upper()

    # Create PBXFileReference
    file_ref = f'\t\t{file_ref_uuid} /* {file_info["name"]} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_info["name"]}; sourceTree = "<group>"; }};'
    new_file_refs.append(file_ref)

    # Create PBXBuildFile
    build_file = f'\t\t{build_file_uuid} /* {file_info["name"]} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_info["name"]} */; }};'
    new_build_files.append((build_file_uuid, build_file))

    print(f"Generated UUIDs for {file_info['name']}: ref={file_ref_uuid}, build={build_file_uuid}")

# Insert PBXFileReference entries
result_lines = []
for i, line in enumerate(lines):
    result_lines.append(line)
    if '/* Begin PBXFileReference section */' in line:
        for ref in new_file_refs:
            result_lines.append(ref)
        print("Added PBXFileReference entries")

# Insert PBXBuildFile entries
final_lines = []
for i, line in enumerate(result_lines):
    final_lines.append(line)
    if '/* Begin PBXBuildFile section */' in line:
        for _, build_file in new_build_files:
            final_lines.append(build_file)
        print("Added PBXBuildFile entries")

# Add to Sources build phase
output_lines = []
in_sources_phase = False
for i, line in enumerate(final_lines):
    if sources_phase_id in line and i+1 < len(final_lines) and 'isa = PBXSourcesBuildPhase' in final_lines[i+1]:
        in_sources_phase = True
    elif in_sources_phase and 'files = (' in line:
        output_lines.append(line)
        # Add our build file references
        for build_uuid, _ in new_build_files:
            filename = [f['name'] for f in files_to_add if build_uuid in _][0]
            output_lines.append(f'\t\t\t\t{build_uuid} /* {filename} in Sources */,')
        print(f"Added {len(new_build_files)} files to Sources build phase")
        in_sources_phase = False
        continue
    output_lines.append(line)

# Now we need to add the file references to the appropriate groups
# Find Models group
models_group_id = None
services_group_id = None

for i, line in enumerate(output_lines):
    if 'Models' in line and '/*' in line and '*/' in line and 'isa = PBXGroup' in output_lines[i+1]:
        models_group_id = line.strip().split(' ')[0]
        print(f"Found Models group: {models_group_id}")
    elif 'Services' in line and '/*' in line and '*/' in line and 'isa = PBXGroup' in output_lines[i+1]:
        services_group_id = line.strip().split(' ')[0]
        print(f"Found Services group: {services_group_id}")

# Add files to appropriate groups
final_output = []
for i, line in enumerate(output_lines):
    final_output.append(line)

    # Add QuoteHistoryEntry to Models group
    if models_group_id and models_group_id in line and 'isa = PBXGroup' in output_lines[i+1]:
        # Find children array
        for j in range(i, min(i+20, len(output_lines))):
            if 'children = (' in output_lines[j]:
                final_output.append(output_lines[j])
                # Add QuoteHistoryEntry
                for ref in new_file_refs:
                    if 'QuoteHistoryEntry' in ref:
                        ref_id = ref.split(' ')[0]
                        final_output.append(f'\t\t\t\t{ref_id} /* QuoteHistoryEntry.swift */,')
                        print("Added QuoteHistoryEntry.swift to Models group")
                # Skip the original children line since we already added it
                for k in range(i+1, j+1):
                    if k != j:
                        final_output.append(output_lines[k])
                # Continue from after children
                i = j + 1
                break
        else:
            continue

    # Add service files to Services group
    elif services_group_id and services_group_id in line and 'isa = PBXGroup' in output_lines[i+1]:
        for j in range(i, min(i+20, len(output_lines))):
            if 'children = (' in output_lines[j]:
                final_output.append(output_lines[j])
                # Add service files
                for ref in new_file_refs:
                    if 'Service' in ref:
                        ref_id = ref.split(' ')[0]
                        filename = ref.split('/* ')[1].split(' */')[0]
                        final_output.append(f'\t\t\t\t{ref_id} /* {filename} */,')
                        print(f"Added {filename} to Services group")
                # Skip original lines
                for k in range(i+1, j+1):
                    if k != j:
                        final_output.append(output_lines[k])
                i = j + 1
                break
        else:
            continue

# Write output
with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    # Need to deduplicate since we may have added lines multiple times
    seen_children_sections = {}
    clean_output = []
    skip_until_close = False

    for i, line in enumerate(final_output):
        if skip_until_close:
            clean_output.append(line)
            if ');' in line:
                skip_until_close = False
            continue

        if 'children = (' in line:
            # Collect all children until closing paren
            section_lines = [line]
            for j in range(i+1, len(final_output)):
                section_lines.append(final_output[j])
                if ');' in final_output[j]:
                    break

            # Deduplicate children
            children = []
            seen_ids = set()
            for sline in section_lines[1:-1]:  # Skip "children = (" and ");"
                if sline.strip():
                    # Extract ID
                    parts = sline.strip().split(' ')
                    if len(parts) > 0:
                        child_id = parts[0]
                        if child_id not in seen_ids:
                            seen_ids.add(child_id)
                            children.append(sline)

            # Write deduplicated section
            clean_output.append(section_lines[0])
            clean_output.extend(children)
            clean_output.append(section_lines[-1])
            skip_until_close = True
        else:
            clean_output.append(line)

    f.write('\n'.join(clean_output))

print("SUCCESS: Added all missing files to project")
