#!/usr/bin/env python3
import uuid, re, sys

def gen_uuid():
    return ''.join(uuid.uuid4().hex.upper()[:24])

if len(sys.argv) < 2:
    print("Usage: python3 add_tutorial_example.py <filename>")
    print("Example: python3 add_tutorial_example.py Option5_HybridSimplified.swift")
    sys.exit(1)

filename = sys.argv[1]
source_path = f"tutorial_examples/{filename}"

MAIN_SOURCES = "EE28FE8977D4009BE438432F"

with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Generate UUIDs
file_ref = gen_uuid()
build_file = gen_uuid()

# Add file reference
content = content.replace(
    '/* End PBXFileReference section */',
    f'\t\t{file_ref} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};\n/* End PBXFileReference section */'
)

# Add build file
content = content.replace(
    '/* End PBXBuildFile section */',
    f'\t\t{build_file} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {filename} */; }};\n/* End PBXBuildFile section */'
)

# Add to Sources build phase
m = re.search(rf'({MAIN_SOURCES} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)', content, re.DOTALL)
if m:
    content = content[:m.end()] + f"\n\t\t\t\t{build_file} /* {filename} in Sources */," + content[m.end():]

# Find Tutorial group (or Features group if Tutorial doesn't exist)
m = re.search(r'([A-F0-9]{24}) /\* Tutorial \*/ = \{[^}]*children = \([^)]*', content, re.DOTALL)
if not m:
    # Try Features group instead
    m = re.search(r'([A-F0-9]{24}) /\* Features \*/ = \{[^}]*children = \([^)]*', content, re.DOTALL)

if m:
    content = content[:m.end()] + f"\n\t\t\t\t{file_ref} /* {filename} */," + content[m.end():]
    print(f"✓ Added {filename} to project")
else:
    print(f"⚠️  Could not find Tutorial or Features group")

with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Done! Now copy the file:")
print(f"cp tutorial_examples/{filename} PageInstead/Features/Tutorial/")
