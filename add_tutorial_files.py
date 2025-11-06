#!/usr/bin/env python3
import uuid
import re

def generate_uuid():
    """Generate a 24-character hex UUID like Xcode uses"""
    return ''.join(uuid.uuid4().hex.upper()[:24])

# Known UUIDs from the project
SOURCES_BUILD_PHASE_UUID = "EE28FE8977D4009BE438432F"
COMPONENTS_GROUP_UUID = "D98D34A3EDCFE7943A32CF42"
FEATURES_GROUP_UUID = "65E26E64BD6C5222FC1653C9"

# Generate UUIDs for new files
tooltip_arrow_file_ref = generate_uuid()
tooltip_arrow_build_file = generate_uuid()
frosted_tooltip_file_ref = generate_uuid()
frosted_tooltip_build_file = generate_uuid()
tutorial_overlay_file_ref = generate_uuid()
tutorial_overlay_build_file = generate_uuid()
tutorial_group_uuid = generate_uuid()

print(f"TooltipArrow: file={tooltip_arrow_file_ref}, build={tooltip_arrow_build_file}")
print(f"FrostedTooltip: file={frosted_tooltip_file_ref}, build={frosted_tooltip_build_file}")
print(f"QuoteTutorialOverlay: file={tutorial_overlay_file_ref}, build={tutorial_overlay_build_file}")
print(f"Tutorial Group: {tutorial_group_uuid}")

# Read the project file
with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# 1. Add PBXBuildFile entries
build_file_section_end = content.find('/* End PBXBuildFile section */')
build_files = f"""\t\t{tooltip_arrow_build_file} /* TooltipArrow.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {tooltip_arrow_file_ref} /* TooltipArrow.swift */; }};
\t\t{frosted_tooltip_build_file} /* FrostedTooltip.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {frosted_tooltip_file_ref} /* FrostedTooltip.swift */; }};
\t\t{tutorial_overlay_build_file} /* QuoteTutorialOverlay.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {tutorial_overlay_file_ref} /* QuoteTutorialOverlay.swift */; }};
"""
content = content[:build_file_section_end] + build_files + content[build_file_section_end:]

# 2. Add PBXFileReference entries
file_ref_section_end = content.find('/* End PBXFileReference section */')
file_refs = f"""\t\t{tooltip_arrow_file_ref} /* TooltipArrow.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TooltipArrow.swift; sourceTree = "<group>"; }};
\t\t{frosted_tooltip_file_ref} /* FrostedTooltip.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FrostedTooltip.swift; sourceTree = "<group>"; }};
\t\t{tutorial_overlay_file_ref} /* QuoteTutorialOverlay.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuoteTutorialOverlay.swift; sourceTree = "<group>"; }};
"""
content = content[:file_ref_section_end] + file_refs + content[file_ref_section_end:]

# 3. Add to Sources build phase
sources_pattern = rf'({SOURCES_BUILD_PHASE_UUID} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)'
sources_match = re.search(sources_pattern, content, re.DOTALL)
if sources_match:
    insertion_point = sources_match.end(0)
    sources_additions = f"""\n\t\t\t\t{tooltip_arrow_build_file} /* TooltipArrow.swift in Sources */,
\t\t\t\t{frosted_tooltip_build_file} /* FrostedTooltip.swift in Sources */,
\t\t\t\t{tutorial_overlay_build_file} /* QuoteTutorialOverlay.swift in Sources */,"""
    content = content[:insertion_point] + sources_additions + content[insertion_point:]
    print("✓ Added to Sources build phase")
else:
    print("ERROR: Could not find Sources build phase")
    exit(1)

# 4. Create Tutorial group in PBXGroup section
group_section_end = content.find('/* End PBXGroup section */')
tutorial_group = f"""\t\t{tutorial_group_uuid} /* Tutorial */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{tutorial_overlay_file_ref} /* QuoteTutorialOverlay.swift */,
\t\t\t);
\t\t\tpath = Tutorial;
\t\t\tsourceTree = "<group>";
\t\t}};
"""
content = content[:group_section_end] + tutorial_group + content[group_section_end:]

# 5. Add TooltipArrow and FrostedTooltip to Components group
components_pattern = rf'({COMPONENTS_GROUP_UUID} /\* Components \*/ = \{{[^}}]*children = \([^)]*)'
components_match = re.search(components_pattern, content, re.DOTALL)
if components_match:
    insertion_point = components_match.end(0)
    components_additions = f"""\n\t\t\t\t{tooltip_arrow_file_ref} /* TooltipArrow.swift */,
\t\t\t\t{frosted_tooltip_file_ref} /* FrostedTooltip.swift */,"""
    content = content[:insertion_point] + components_additions + content[insertion_point:]
    print("✓ Added TooltipArrow and FrostedTooltip to Components group")
else:
    print("ERROR: Could not find Components group")
    exit(1)

# 6. Add Tutorial group to Features group
features_pattern = rf'({FEATURES_GROUP_UUID} /\* Features \*/ = \{{[^}}]*children = \([^)]*)'
features_match = re.search(features_pattern, content, re.DOTALL)
if features_match:
    insertion_point = features_match.end(0)
    features_addition = f"""\n\t\t\t\t{tutorial_group_uuid} /* Tutorial */,"""
    content = content[:insertion_point] + features_addition + content[insertion_point:]
    print("✓ Added Tutorial group to Features")
else:
    print("ERROR: Could not find Features group")
    exit(1)

# Write back
with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n✅ Successfully added all tutorial files to project!")
