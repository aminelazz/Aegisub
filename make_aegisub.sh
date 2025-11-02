sudo apt install -y libass9 libass-dev \
    libboost-all-dev libicu-dev \
    freeglut3-dev \
    libicu-dev \
    libwxgtk3.0-gtk3-dev \
    zlib1g-dev \
    libfontconfig1 libfontconfig1-dev \
    luajit \
    libasound2-dev \
    libffms2-dev \
    libfftw3-dev \
    hunspell libhunspell-dev \
    libopenal-dev \
    uchardet \
    build-essential cmake pkg-config git libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev yasm \
    libpulse-dev portaudio19-dev libuchardet-dev gettext

# Build
git clone https://github.com/wangqr/Aegisub.git
cd Aegisub
git clone https://github.com/TypesettingTools/DependencyControl.git
./build/version.sh .  # This will generate build/git_version.h
mkdir -p build-dir && cd build-dir
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
# stage installed files into AppDir
make install DESTDIR=$PWD/AppDir

# Install luarocks
sudo apt install -y luarocks

# Install Moonscript into the AppDir so it will be bundled into the AppImage
# from the build directory where AppDir is located
# this installs the rock into AppDir/usr/local so files appear under AppDir/usr/local/lib or share
luarocks --tree=AppDir/usr/local install moonscript

# list the directories where moonscript was installed
ls -l AppDir/usr/local/{lib,share}/lua/5.1 | sed -n '1,200p'

# run a quick Lua test using system luajit but with package.path pointed to AppDir
# If that prints moonscript ok= true, good.
export LUA_INIT='package.path=package.path..";'$(pwd)'/AppDir/usr/local/share/lua/5.1/?.lua;'"$(pwd)"'/AppDir/usr/local/lib/lua/5.1/?.lua;"'
luajit -e "local ok, m = pcall(require,'moonscript'); print('moonscript ok=', ok, 'type=', type(m))"

# Make AppImage file
sudo apt update
sudo apt install -y patchelf wget libfreetype6 libfontconfig1
# get linuxdeploy and appimagetool
wget -q --show-progress https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage
wget -q --show-progress https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# point to your installed binary inside AppDir
./linuxdeploy-x86_64.AppImage \
  --appdir AppDir \
  --executable AppDir/usr/local/bin/aegisub \
  --desktop-file AppDir/usr/local/share/applications/aegisub.desktop \
  --icon-file AppDir/usr/local/share/icons/hicolor/64x64/apps/aegisub.png \
  --output appimage
# result: Aegisub-*.AppImage in current dir