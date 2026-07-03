#!/usr/bin/env python3
from pathlib import Path
import os
import subprocess

ROOT = Path(__file__).resolve().parents[1]
APP_NAME = "إدارة الشغل"
PACKAGE_ID = "com.edaretelshoghl.edaret_el_shoghl"
STORE_PASS = "EdaretElShoghl123"
KEY_PASS = "EdaretElShoghl123"
KEY_ALIAS = "release"


def patch_manifest():
    for manifest in [ROOT / "android/app/src/main/AndroidManifest.xml"]:
        if not manifest.exists():
            continue
        s = manifest.read_text(encoding="utf-8")
        import re
        s = re.sub(r'android:label="[^"]*"', f'android:label="{APP_NAME}"', s)
        if "android:usesCleartextTraffic" not in s:
            s = s.replace("<application\n", "<application\n        android:usesCleartextTraffic=\"false\"\n", 1)
        manifest.write_text(s, encoding="utf-8")


def generate_keystore():
    keystore = ROOT / "android/app/release-keystore.jks"
    if keystore.exists():
        return
    keystore.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "keytool", "-genkeypair", "-v",
        "-keystore", str(keystore),
        "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000",
        "-alias", KEY_ALIAS,
        "-storepass", STORE_PASS,
        "-keypass", KEY_PASS,
        "-dname", "CN=EdaretElShoghl, OU=Mobile, O=Work, L=Cairo, S=Cairo, C=EG",
    ]
    subprocess.run(cmd, check=True)


def patch_groovy(path: Path):
    s = path.read_text(encoding="utf-8")
    s = s.replace('namespace = "com.example.edaret_el_shoghl"', f'namespace = "{PACKAGE_ID}"')
    s = s.replace('namespace "com.example.edaret_el_shoghl"', f'namespace "{PACKAGE_ID}"')
    import re
    s = re.sub(r'applicationId\s+["\'][^"\']+["\']', f'applicationId "{PACKAGE_ID}"', s)
    s = re.sub(r'applicationId\s*=\s*["\'][^"\']+["\']', f'applicationId = "{PACKAGE_ID}"', s)
    if 'signingConfigs {' not in s or 'release-keystore.jks' not in s:
        s = s.replace('    buildTypes {', f'''    signingConfigs {{\n        release {{\n            storeFile file("release-keystore.jks")\n            storePassword "{STORE_PASS}"\n            keyAlias "{KEY_ALIAS}"\n            keyPassword "{KEY_PASS}"\n        }}\n    }}\n\n    buildTypes {{''')
    s = s.replace('signingConfig signingConfigs.debug', 'signingConfig signingConfigs.release')
    s = s.replace('signingConfig = signingConfigs.debug', 'signingConfig = signingConfigs.release')
    path.write_text(s, encoding="utf-8")


def patch_kts(path: Path):
    s = path.read_text(encoding="utf-8")
    import re
    s = re.sub(r'namespace\s*=\s*"[^"]+"', f'namespace = "{PACKAGE_ID}"', s)
    s = re.sub(r'applicationId\s*=\s*"[^"]+"', f'applicationId = "{PACKAGE_ID}"', s)
    if 'release-keystore.jks' not in s:
        s = s.replace('    buildTypes {', f'''    signingConfigs {{\n        create("release") {{\n            storeFile = file("release-keystore.jks")\n            storePassword = "{STORE_PASS}"\n            keyAlias = "{KEY_ALIAS}"\n            keyPassword = "{KEY_PASS}"\n        }}\n    }}\n\n    buildTypes {{''')
    s = s.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
    path.write_text(s, encoding="utf-8")


def patch_gradle():
    app_groovy = ROOT / "android/app/build.gradle"
    app_kts = ROOT / "android/app/build.gradle.kts"
    if app_groovy.exists():
        patch_groovy(app_groovy)
    if app_kts.exists():
        patch_kts(app_kts)


def main():
    patch_manifest()
    generate_keystore()
    patch_gradle()
    print("Android release settings patched.")


if __name__ == "__main__":
    main()
