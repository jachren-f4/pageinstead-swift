#!/usr/bin/env python3
import uuid, re

def gen_uuid():
    return ''.join(uuid.uuid4().hex.upper()[:24])

MAIN_SOURCES = "EE28FE8977D4009BE438432F"
files = [("HealthScoreDetailSheet.swift", "Features"), ("StreakDetailSheet.swift", "Features")]

with open('PageInstead.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

for fn, grp in files:
    fr, bf = gen_uuid(), gen_uuid()
    content = content.replace('/* End PBXFileReference section */', f"\t\t{fr} /* {fn} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {fn}; sourceTree = \"<group>\"; }};\n/* End PBXFileReference section */")
    content = content.replace('/* End PBXBuildFile section */', f"\t\t{bf} /* {fn} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr} /* {fn} */; }};\n/* End PBXBuildFile section */")
    m = re.search(rf'({MAIN_SOURCES} /\* Sources \*/ = \{{[^}}]*files = \([^)]*)', content, re.DOTALL)
    if m: content = content[:m.end()] + f"\n\t\t\t\t{bf} /* {fn} in Sources */," + content[m.end():]
    m = re.search(r'([A-F0-9]{24}) /\* Features \*/ = \{[^}]*children = \([^)]*', content, re.DOTALL)
    if m: content = content[:m.end()] + f"\n\t\t\t\t{fr} /* {fn} */," + content[m.end():]
    print(f"✓ Added {fn}")

with open('PageInstead.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)
print("✅ Done!")
