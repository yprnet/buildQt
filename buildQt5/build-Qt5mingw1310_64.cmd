@chcp 65001
@cd /d %~dp0

:: 设置Qt版本
SET QT_VERSION=5.15.19

:: 设置MinGW版本代号
SET MinGW_VERSION=mingw1310_64

:: 设置编译器和Perl
SET PATH=D:\a\buildQt\Tools\mingw1310_64\bin;D:\a\buildQt\Strawberry\c\bin;D:\a\buildQt\Strawberry\perl\site\bin;D:\a\buildQt\Strawberry\perl\bin;%PATH%

:: 设置Qt文件夹路径
SET QT_PATH=D:\a\buildQt\Qt

:: 设置线程数
SET NUM_THRED=%NUMBER_OF_PROCESSORS%

::----------以下无需修改----------

:: 设置Qt源代码目录
SET SRC_QT="%QT_PATH%\%QT_VERSION%\qt-everywhere-src-%QT_VERSION%"

::替换qfilesystemengine_win.cpp、main.c(使其可以被高于MinGW GCC8.1.0版本编译)
copy %~dp0\patches\qfilesystemengine_win.cpp %SRC_QT%\qtbase\src\corelib\io\qfilesystemengine_win.cpp /Y
copy %~dp0\patches\main.c %SRC_QT%\qttools\src\assistant\qcollectiongenerator\main.c /Y

::替换unique_any.hpp(Clang mapboxgl 构建修复)
copy %~dp0\patches\unique_any.hpp %SRC_QT%\qtlocation\src\3rdparty\mapbox-gl-native\include\mbgl\util\unique_any.hpp /Y

::替换avfcamerautility.mm(QtMultiMedia C++17 构建修复)
copy %~dp0\patches\avfcamerautility.mm %SRC_QT%\qtmultimedia\src\plugins\avfoundation\camera\avfcamerautility.mm /Y

::替换Makefile.unix.win32(使用 _WIN32_WINNT 的默认值为 0x0A00 的新版 MinGW-w64 上 Qt 5.15 系列无法构建)
copy %~dp0\patches\Makefile.unix.win32 %SRC_QT%\qtbase\qmake\Makefile.unix.win32 /Y

::替换HandleAllocator.cpp(使用GCC11或更新的版本无法构建Qt 5.15系列上的angle)
copy %~dp0\patches\HandleAllocator.cpp %SRC_QT%\qtbase\src\3rdparty\angle\src\libANGLE\HandleAllocator.cpp /Y

::替换hlsl_bytecode_header.prf、qsgd3d12engine.cpp(Qt5.15系列的d3d12 Qt Quick Scene Graph插件无法找到fxc，并且找不 _uuidof 函数)
copy %~dp0\patches\hlsl_bytecode_header.prf %SRC_QT%\qtdeclarative\features\hlsl_bytecode_header.prf /Y
copy %~dp0\patches\qsgd3d12engine.cpp %SRC_QT%\qtdeclarative\src\plugins\scenegraph\d3d12\qsgd3d12engine.cpp /Y

:: 补充设置qtbase\bin和gnuwin32\bin
SET PATH=%SRC_QT%\qtbase\bin;%SRC_QT%\gnuwin32\bin;%PATH%

:: 设置安装文件夹目录
SET INSTALL_DIR="%QT_PATH%\%QT_VERSION%-static\%MinGW_VERSION%"

:: 设置build文件夹目录
SET BUILD_DIR="%QT_PATH%\%QT_VERSION%\build-%MinGW_VERSION%"

:: 根据需要进行全新构建
rmdir /s /q "%BUILD_DIR%"
:: 定位到构建目录：
mkdir "%BUILD_DIR%" && cd /d "%BUILD_DIR%"

:: configure
call %SRC_QT%\configure.bat -static -static-runtime -release -prefix %INSTALL_DIR% -nomake examples -nomake tests -skip qtwebengine -opensource -confirm-license -qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -qt-freetype -schannel -opengl desktop -platform win32-g++ -no-feature-d3d12 -skip qtmultimedia -skip qtlocation

:: 编译、安装
mingw32-make -j%NUM_THRED%         
mingw32-make install

::复制qt.conf
copy %~dp0\qt.conf %INSTALL_DIR%\bin

::@pause
@cmd /k cd /d %INSTALL_DIR%
