#!/bin/bash
set -e

# Configuration
APP_NAME="pomodoro-timer"
MAINTAINER="JAC Hermocilla <jachermocilla@gmail.com>"
DESCRIPTION="A simple and elegant Pomodoro timer application"
ARCH="all"
HOMEPAGE="https://github.com/jachermocilla/pomodoro"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Pomodoro Timer .deb Package Builder ===${NC}"

# Version comes from the latest git tag (vX.Y.Z), unless APP_VERSION is set
if [ -z "${APP_VERSION}" ]; then
    APP_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
fi
if [ -z "${APP_VERSION}" ]; then
    echo -e "${RED}Error: no git tag found. Tag a release (git tag vX.Y.Z) or set APP_VERSION.${NC}"
    exit 1
fi
echo "Version: ${APP_VERSION}"

# Check dependencies
echo -e "${BLUE}[1/6] Checking dependencies...${NC}"
if ! command -v dpkg-deb &> /dev/null; then
    echo -e "${RED}Error: dpkg-deb is not installed${NC}"
    exit 1
fi

# Clean previous builds
echo -e "${BLUE}[2/6] Cleaning previous builds...${NC}"
rm -rf debian_package

# Create Debian package structure
echo -e "${BLUE}[3/6] Creating Debian package structure...${NC}"
PKG_DIR="debian_package/${APP_NAME}_${APP_VERSION}_${ARCH}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps"
mkdir -p "${PKG_DIR}/usr/share/doc/${APP_NAME}"

# Install the script and icon
echo -e "${BLUE}[4/6] Installing files...${NC}"
install -m 755 pomodoro.py "${PKG_DIR}/usr/bin/${APP_NAME}"
install -m 644 pomodoro-timer.svg "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps/${APP_NAME}.svg"

# Create control file
echo -e "${BLUE}[5/6] Creating control file...${NC}"
cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${APP_VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Homepage: ${HOMEPAGE}
Depends: python3, python3-tk
Description: ${DESCRIPTION}
 A Pomodoro timer application built with Python and Tkinter.
 Features work sessions, short breaks, and long breaks following
 the Pomodoro Technique for improved productivity.
EOF

# Create desktop entry
cat > "${PKG_DIR}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Pomodoro Timer
Comment=Productivity timer using the Pomodoro Technique
Exec=/usr/bin/${APP_NAME}
Icon=${APP_NAME}
Terminal=false
Categories=Utility;Office;
Keywords=timer;pomodoro;productivity;
EOF

# Create copyright file
{
    cat << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${APP_NAME}
Source: ${HOMEPAGE}

Files: *
Copyright: $(date +%Y) ${MAINTAINER}
License: MIT
EOF
    # License text from LICENSE, indented, blank lines as " ."
    tail -n +3 LICENSE | sed -e 's/^$/./' -e 's/^/ /'
} > "${PKG_DIR}/usr/share/doc/${APP_NAME}/copyright"

# Create changelog from commits since the previous tag
if git rev-parse -q --verify "v${APP_VERSION}" > /dev/null; then
    RANGE_END="v${APP_VERSION}"
    PREV_TAG=$(git describe --tags --abbrev=0 "v${APP_VERSION}^" 2>/dev/null || true)
else
    RANGE_END="HEAD"
    PREV_TAG=$(git describe --tags --abbrev=0 HEAD 2>/dev/null || true)
fi
if [ -n "${PREV_TAG}" ]; then
    CHANGES=$(git log --format='  * %s' "${PREV_TAG}..${RANGE_END}")
else
    CHANGES=$(git log --format='  * %s' "${RANGE_END}")
fi
[ -n "${CHANGES}" ] || CHANGES="  * Release ${APP_VERSION}"

cat > "${PKG_DIR}/usr/share/doc/${APP_NAME}/changelog.Debian" << EOF
${APP_NAME} (${APP_VERSION}) unstable; urgency=low

${CHANGES}

 -- ${MAINTAINER}  $(date -R)
EOF

# Compress changelog
gzip -9 -n "${PKG_DIR}/usr/share/doc/${APP_NAME}/changelog.Debian"

# Set correct permissions
find "${PKG_DIR}" -type d -exec chmod 755 {} \;
find "${PKG_DIR}/usr/share" -type f -exec chmod 644 {} \;

# Build the package
echo -e "${BLUE}[6/6] Building .deb package...${NC}"
dpkg-deb --build --root-owner-group "${PKG_DIR}"

if [ -f "${PKG_DIR}.deb" ]; then
    echo -e "${GREEN}✓ Package built successfully!${NC}"
    echo -e "${GREEN}Package location: ${PKG_DIR}.deb${NC}"
    echo ""
    echo -e "${BLUE}Package information:${NC}"
    dpkg-deb --info "${PKG_DIR}.deb"
    echo ""
    echo -e "${BLUE}Installation instructions:${NC}"
    echo "  sudo apt install ./${PKG_DIR}.deb"
    echo ""
    echo -e "${BLUE}To test without installing:${NC}"
    echo "  python3 pomodoro.py"
else
    echo -e "${RED}Error: Package build failed${NC}"
    exit 1
fi

echo -e "${GREEN}=== Build Complete ===${NC}"
