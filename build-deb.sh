#!/bin/bash
set -e

# Configuration
APP_NAME="pomodoro-timer"
APP_VERSION="1.0.0"
MAINTAINER="JAC Hermocilla <jachermocilla@gmail.com>"
DESCRIPTION="A simple and elegant Pomodoro timer application"
ARCH="amd64"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Pomodoro Timer .deb Package Builder ===${NC}"

# Check dependencies
echo -e "${BLUE}[1/8] Checking dependencies...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed${NC}"
    exit 1
fi

if ! python3 -c "import tkinter" &> /dev/null 2>&1; then
    echo -e "${RED}Error: python3-tk is not installed${NC}"
    echo "Install it with: sudo apt-get install python3-tk"
    exit 1
fi

if ! command -v pyinstaller &> /dev/null; then
    echo "PyInstaller not found. Installing..."
    pip3 install pyinstaller
fi

# Clean previous builds
echo -e "${BLUE}[2/8] Cleaning previous builds...${NC}"
rm -rf build dist *.spec debian_package

# Create binary with PyInstaller
echo -e "${BLUE}[3/8] Creating standalone binary with PyInstaller...${NC}"
pyinstaller --onefile \
    --windowed \
    --name="${APP_NAME}" \
    --clean \
    --noconfirm \
    pomodoro.py

if [ ! -f "dist/${APP_NAME}" ]; then
    echo -e "${RED}Error: Binary creation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Binary created successfully${NC}"

# Create Debian package structure
echo -e "${BLUE}[4/8] Creating Debian package structure...${NC}"
PKG_DIR="debian_package/${APP_NAME}_${APP_VERSION}_${ARCH}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/pixmaps"
mkdir -p "${PKG_DIR}/usr/share/doc/${APP_NAME}"

# Copy binary
echo -e "${BLUE}[5/8] Installing binary...${NC}"
cp "dist/${APP_NAME}" "${PKG_DIR}/usr/bin/"
chmod 755 "${PKG_DIR}/usr/bin/${APP_NAME}"

# Create control file
echo -e "${BLUE}[6/8] Creating control file...${NC}"
cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${APP_VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
 A Pomodoro timer application built with Python and Tkinter.
 Features work sessions, short breaks, and long breaks following
 the Pomodoro Technique for improved productivity.
Depends: libc6 (>= 2.27)
EOF

# Create desktop entry
echo -e "${BLUE}[7/8] Creating desktop entry...${NC}"
cat > "${PKG_DIR}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Pomodoro Timer
Comment=Productivity timer using the Pomodoro Technique
Exec=/usr/bin/${APP_NAME}
Icon=pomodoro-timer
Terminal=false
Categories=Utility;Office;
Keywords=timer;pomodoro;productivity;
EOF

# Create a simple icon (text-based placeholder)
echo -e "${BLUE}Creating application icon...${NC}"
cat > "${PKG_DIR}/usr/share/pixmaps/${APP_NAME}.xpm" << 'EOF'
/* XPM */
static char * pomodoro_xpm[] = {
"32 32 3 1",
" 	c None",
".	c #D32F2F",
"+	c #FFFFFF",
"                                ",
"                                ",
"           ........             ",
"         ..........  .          ",
"        ............  ..        ",
"       ..............  ..       ",
"      ................  ..      ",
"      .................. .      ",
"     ..................  ..     ",
"     ...................  .     ",
"     ...................  .     ",
"     ..........++.......  .     ",
"     .........++++......  .     ",
"     .........++++......  .     ",
"     ..........++.......  .     ",
"     ...................  .     ",
"     ...................  .     ",
"     ..................  ..     ",
"      .................. .      ",
"      ................  ..      ",
"       ..............  ..       ",
"        ............  ..        ",
"         ..........  .          ",
"           ........             ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                "};
EOF

# Create copyright file
cat > "${PKG_DIR}/usr/share/doc/${APP_NAME}/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${APP_NAME}
Source: https://github.com/yourusername/${APP_NAME}

Files: *
Copyright: $(date +%Y) ${MAINTAINER}
License: MIT
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 .
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 .
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
EOF

# Create changelog
cat > "${PKG_DIR}/usr/share/doc/${APP_NAME}/changelog.Debian" << EOF
${APP_NAME} (${APP_VERSION}) unstable; urgency=low

  * Initial release
  * Pomodoro timer with 25-minute work sessions
  * 5-minute short breaks and 15-minute long breaks
  * Visual timer display with start/pause/reset controls

 -- ${MAINTAINER}  $(date -R)
EOF

# Compress changelog
gzip -9 -n "${PKG_DIR}/usr/share/doc/${APP_NAME}/changelog.Debian"

# Create postinst script (optional)
cat > "${PKG_DIR}/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Update desktop database if available
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database -q
fi

exit 0
EOF
chmod 755 "${PKG_DIR}/DEBIAN/postinst"

# Create postrm script (optional)
cat > "${PKG_DIR}/DEBIAN/postrm" << 'EOF'
#!/bin/bash
set -e

# Update desktop database if available
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database -q
fi

exit 0
EOF
chmod 755 "${PKG_DIR}/DEBIAN/postrm"

# Set correct permissions
find "${PKG_DIR}" -type d -exec chmod 755 {} \;
find "${PKG_DIR}/usr/share/doc" -type f -exec chmod 644 {} \;

# Build the package
echo -e "${BLUE}[8/8] Building .deb package...${NC}"
dpkg-deb --build --root-owner-group "${PKG_DIR}"

if [ -f "${PKG_DIR}.deb" ]; then
    echo -e "${GREEN}✓ Package built successfully!${NC}"
    echo -e "${GREEN}Package location: ${PKG_DIR}.deb${NC}"
    echo ""
    echo -e "${BLUE}Package information:${NC}"
    dpkg-deb --info "${PKG_DIR}.deb"
    echo ""
    echo -e "${BLUE}Installation instructions:${NC}"
    echo "  sudo dpkg -i ${PKG_DIR}.deb"
    echo ""
    echo -e "${BLUE}To test without installing:${NC}"
    echo "  ./dist/${APP_NAME}"
else
    echo -e "${RED}Error: Package build failed${NC}"
    exit 1
fi

echo -e "${GREEN}=== Build Complete ===${NC}"
