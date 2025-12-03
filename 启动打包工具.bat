@echo off
chcp 65001 >nul
title NwServer使用说明书 - Electron打包工具
color 0B

echo.
echo ========================================
echo   NwServer使用说明书 - Electron打包工具
echo ========================================
echo.

cd /d "%~dp0"

:start_check
echo [1/4] 检查 Node.js 安装...
where node >nul 2>nul
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo X 未检测到 Node.js
    echo.
    echo 请先安装 Node.js
    echo https://nodejs.org/
    echo.
    pause
    exit
)

for /f "delims=" %%i in ('node --version') do set NODE_VERSION=%%i
echo OK Node.js 已安装: %NODE_VERSION%

echo [2/4] 检查 npm...
where npm >nul 2>nul
if %errorlevel% neq 0 (
    color 0C
    echo X npm 不可用
    pause
    exit
)

for /f "delims=" %%i in ('npm --version') do set NPM_VERSION=%%i
echo OK npm 已安装: %NPM_VERSION%
echo.
echo [3/4] 检查依赖状态...
if exist "node_modules\electron" (
    echo OK 依赖已安装
    set DEPS_STATUS=已安装
    set DEPS_INSTALLED=1
) else (
    if exist "node_modules" (
        echo ! 依赖不完整 需要重新安装
        set DEPS_STATUS=不完整
    ) else (
        echo ! 依赖未安装
        set DEPS_STATUS=未安装
    )
    set DEPS_INSTALLED=0
)

:menu
cls
echo.
echo ========================================
echo   NwServer使用说明书 - Electron打包工具
echo ========================================
echo.
echo   Node.js: %NODE_VERSION%
echo   npm: %NPM_VERSION%
echo   依赖状态: %DEPS_STATUS%
echo.
echo ========================================
echo.
if "%DEPS_INSTALLED%"=="1" (
    echo   [1] 安装依赖 - 已安装
) else (
    echo   [1] 安装依赖 - 必选
)
echo.
if "%DEPS_INSTALLED%"=="1" (
    echo   [2] 修复 Electron 安装
) else (
    echo   [2] 修复 Electron 安装 - 需先安装依赖
)
echo.
if "%DEPS_INSTALLED%"=="1" (
    echo   [3] 测试运行
) else (
    echo   [3] 测试运行 - 需先安装依赖
)
echo.
if "%DEPS_INSTALLED%"=="1" (
    echo   [4] 打包绿色版
) else (
    echo   [4] 打包绿色版 - 需先安装依赖
)
echo.
echo   [5] 退出
echo.
echo ========================================
if "%DEPS_INSTALLED%"=="0" (
    echo 提示 首次使用请选择 1 安装依赖 (已自动使用国内镜像)
) else (
    echo 提示 依赖已就绪 可以测试运行或打包
)
echo ========================================
echo.
set choice=
set /p "choice=> 请输入选项 (1-5): " 

if "%choice%"=="1" (
    if "%DEPS_INSTALLED%"=="1" (
        echo.
        echo 依赖已经安装 无需重复安装
        echo.
        choice /C YN /M "是否重新安装"
        if errorlevel 2 goto menu
        if errorlevel 1 (
            echo.
            echo 正在删除旧依赖...
            echo 请稍候...
            rmdir /s /q "node_modules" 2>nul
            if exist "node_modules" (
                echo.
                echo 警告 无法删除旧依赖
                echo 请手动删除 node_modules 文件夹后重试
                echo.
                pause
                goto menu
            )
            goto install
        )
    ) else (
        goto install
    )
)
if "%choice%"=="2" (
    if "%DEPS_INSTALLED%"=="0" (
        echo.
        echo 错误 请先安装依赖 选项 1
        timeout /t 3 >nul
        goto menu
    ) else (
        goto fix_electron
    )
)
if "%choice%"=="3" (
    if "%DEPS_INSTALLED%"=="0" (
        echo.
        echo 错误 请先安装依赖 选项 1
        timeout /t 3 >nul
        goto menu
    ) else (
        goto start
    )
)
if "%choice%"=="4" (
    if "%DEPS_INSTALLED%"=="0" (
        echo.
        echo 错误 请先安装依赖 选项 1
        timeout /t 3 >nul
        goto menu
    ) else (
        goto build_portable
    )
)
if "%choice%"=="5" goto exit_app
echo.
echo 无效选项 请输入 1-5
timeout /t 2 >nul
goto menu

:install
cls
echo.
echo ========================================
echo 安装依赖包
echo ========================================
echo.
if exist "node_modules" (
    echo 检测到已有 node_modules 文件夹
    echo.
    echo 正在清理旧依赖...
    echo 请稍候 正在删除文件...
    echo.
    
    REM 尝试使用多种方式删除
    rmdir /s /q "node_modules" 2>nul
    
    REM 再次检查是否删除成功
    if exist "node_modules" (
        echo 第一次删除未完成 尝试强制删除...
        timeout /t 2 >nul
        rd /s /q "node_modules" 2>nul
    )
    
    REM 最终检查
    if exist "node_modules" (
        color 0E
        echo.
        echo ========================================
        echo 警告 无法自动删除 node_modules 文件夹
        echo ========================================
        echo.
        echo 可能原因:
        echo 1. 文件夹正在被其他程序占用
        echo 2. 没有足够的权限
        echo 3. 文件路径过长
        echo.
        echo 请手动操作:
        echo 1. 关闭所有 Node.js 相关程序
        echo 2. 手动删除 node_modules 文件夹
        echo 3. 重新运行此工具
        echo.
        echo 或者按任意键强制继续安装 可能会失败
        echo ========================================
        pause
        echo.
        echo 强制继续安装...
        echo.
    ) else (
        echo 清理完成
        echo.
    )
)
echo 正在安装 Electron 和打包工具...
echo.
echo ========================================
echo   重要提示
echo ========================================
echo.
echo 1. 首次安装需要下载 Electron 约 100-150MB
echo 2. 下载速度取决于网络 可能需要 5-15 分钟
echo 3. 下面会显示下载进度和安装进度
echo 4. 请不要关闭窗口 也不要按 Ctrl+C
echo.
echo ========================================
echo 正在执行 npm install...
echo ========================================
echo.
REM 自动使用国内镜像加速下载
echo 提示: 自动使用国内镜像加速下载...
echo.
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
set ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/
call npm install --foreground-scripts --loglevel=verbose --registry=https://registry.npmmirror.com
set INSTALL_RESULT=%errorlevel%
echo.
echo.
echo ========================================
echo npm install 执行完毕
echo ========================================
echo.
if %INSTALL_RESULT% equ 0 (
    color 0A
    echo.
    echo =========================================
    echo OK 依赖安装成功
    echo =========================================
    echo.
    echo 提示 现在可以选择测试运行或打包应用
) else (
    color 0C
    echo.
    echo =========================================
    echo X 依赖安装失败
    echo =========================================
    echo.
    echo 可能原因:
    echo 1. 网络连接问题
    echo 2. npm 源速度慢 建议使用国内镜像
    echo 3. node_modules 未完全清理
    echo.
    echo 建议:
    echo 1. 检查网络连接
    echo 2. 手动删除 node_modules 后重试
    echo 3. 或使用淘宝镜像: npm config set registry https://registry.npmmirror.com
    echo.
)
echo.
echo 按任意键返回主菜单...
pause >nul
cls
color 0B
goto :start_check

:setup_mirror
cls
echo.
echo ========================================
echo 配置国内镜像
echo ========================================
echo.
echo 国内从 GitHub 下载 Electron 非常慢，配置国内镜像后:
echo - npm 包下载速度提升 10-20 倍
echo - Electron 下载速度提升 5-10 倍
echo - 安装和打包时间大大缩短
echo.
echo 将配置以下镜像:
echo 1. npm 源: https://registry.npmmirror.com
echo 2. Electron 镜像: https://npmmirror.com/mirrors/electron/
echo.
echo ========================================
echo.
choice /C YN /M "确认配置国内镜像"
if errorlevel 2 (
    echo.
    echo 已取消配置
    timeout /t 2 >nul
    goto menu
)
if errorlevel 1 (
    echo.
    echo 正在配置 npm 源...
    call npm config set registry https://registry.npmmirror.com
    if %errorlevel% equ 0 (
        echo OK npm 源配置成功
    ) else (
        echo X npm 源配置失败
    )
    
    echo.
    echo 正在配置 Electron 镜像...
    call npm config set electron_mirror https://npmmirror.com/mirrors/electron/
    if %errorlevel% equ 0 (
        echo OK Electron 镜像配置成功
    ) else (
        echo X Electron 镜像配置失败
    )
    
    echo.
    echo 正在配置其他镜像...
    call npm config set disturl https://npmmirror.com/mirrors/node/
    call npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/
    call npm config set phantomjs_cdnurl https://npmmirror.com/mirrors/phantomjs/
    call npm config set chromedriver_cdnurl https://npmmirror.com/mirrors/chromedriver/
    
    echo.
    echo ========================================
    echo 配置完成
    echo ========================================
    echo.
    echo 当前 npm 配置:
    call npm config get registry
    call npm config get electron_mirror
    echo.
    color 0A
    echo 提示: 现在可以选择 1 安装依赖，速度会快很多！
    echo.
)
echo 按任意键返回主菜单...
pause >nul
cls
color 0B
goto menu

:fix_electron
cls
echo.
echo ========================================
echo 修复 Electron 安装
echo ========================================
echo.
echo 正在修复 Electron 安装问题...
echo.
echo 步骤 1: 删除损坏的 Electron 文件
echo.
if exist "node_modules\electron" (
    echo 正在删除 node_modules\electron...
    rmdir /s /q "node_modules\electron" 2>nul
    timeout /t 2 >nul
    
    if exist "node_modules\electron" (
        echo 删除失败 尝试强制删除...
        rd /s /q "node_modules\electron" 2>nul
        timeout /t 2 >nul
    )
    
    if exist "node_modules\electron" (
        color 0E
        echo.
        echo 警告 无法删除 Electron 文件夹
        echo 请手动删除 node_modules\electron 后重试
        echo.
        pause
        goto menu
    ) else (
        echo 删除成功
    )
) else (
    echo Electron 文件夹不存在
)
echo.
echo 步骤 2: 重新下载并安装 Electron
echo.
echo ========================================
echo 正在执行 npm install electron...
echo ========================================
echo.
echo 请耐心等待 Electron 约 100-150MB
echo 下面会显示下载和安装进度
echo.
REM 自动使用国内镜像加速下载
echo 提示: 自动使用国内镜像加速下载...
echo.
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
set ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/
call npm install electron --foreground-scripts --loglevel=verbose --registry=https://registry.npmmirror.com
set FIX_RESULT=%errorlevel%
echo.
echo.
echo ========================================
echo 修复完毕
echo ========================================
echo.
if %FIX_RESULT% equ 0 (
    color 0A
    echo OK Electron 修复成功
    echo.
    echo 现在可以尝试测试运行了
) else (
    color 0C
    echo X Electron 修复失败
    echo.
    echo 建议:
    echo 1. 检查网络连接
    echo 2. 使用国内镜像: npm config set registry https://registry.npmmirror.com
    echo 3. 或手动删除整个 node_modules 后重新安装全部依赖
)
echo.
echo 按任意键返回主菜单...
pause >nul
cls
color 0B
goto :start_check

:start
cls
echo.
echo ========================================
echo 启动测试运行
echo ========================================
echo.
echo 正在启动 Electron 应用...
echo.
echo 提示:
echo - 关闭 Electron 窗口后将自动返回菜单
echo - 或者在此窗口按 Ctrl+C 强制停止
echo.
echo ========================================
echo.
call npm start
echo.
echo.
echo ========================================
echo Electron 应用已退出
echo ========================================
echo.
echo 按任意键返回主菜单...
pause >nul
cls
goto menu

:build_portable
cls
echo.
echo ========================================
echo 打包绿色版
echo ========================================
echo.
echo 打包过程包括以下步骤:
echo 1. 创建带时间戳的输出目录
echo 2. 下载 Electron 运行时 (约 100MB)
echo 3. 打包应用文件
echo 4. 生成可执行程序
echo.
echo 预计时间: 3-10 分钟 (取决于网络和电脑性能)
echo 最终文件大小: 约 150MB
echo.
echo ========================================
echo 正在准备打包环境...
echo ========================================
echo.
REM 生成时间戳格式: YYYYMMDD_HHMMSS
for /f "tokens=1-6 delims=/: " %%a in ("%date% %time%") do (
    set "TIMESTAMP=%%a%%b%%c_%%d%%e%%f"
)
REM 去除时间戳中的空格
set "TIMESTAMP=%TIMESTAMP: =0%"
REM 设置输出目录
set "BUILD_OUTPUT=打包输出\%TIMESTAMP%"
echo 输出目录: %BUILD_OUTPUT%
echo.
REM 创建输出目录
if not exist "打包输出" mkdir "打包输出"
if not exist "%BUILD_OUTPUT%" mkdir "%BUILD_OUTPUT%"
echo.
echo ========================================
echo 正在执行打包...
echo ========================================
echo.
echo [步骤 1/3] 检查配置和依赖...
echo [步骤 2/3] 下载 Electron 运行时 (这个步骤较慢，请耐心等待)...
echo [步骤 3/3] 生成应用程序...
echo.
echo 提示: 下面会显示详细的技术日志
echo.
echo   关键信息说明:
echo   -------------------------------------------
echo   downloading  正在下载
echo   download part  分段下载 (8线程并行)
echo   downloaded  下载完成
echo   packaging  打包中
echo   building  构建中
echo   writing  写入文件
echo   -------------------------------------------
echo.
echo   当看到 8 个 download part 时，说明正在全速下载
echo   请耐心等待，直到出现 downloaded 字样
echo.
echo   重要提示:
echo   - 下载过程中不会显示百分比，这是正常现象
echo   - 看到 download part 后需等待 3-10 分钟
echo   - 如果下载太慢，可按 Ctrl+C 中断，使用国内镜像
echo.
echo ========================================
echo.
REM 使用 DEBUG 环境变量显示详细信息
REM 自动使用国内镜像加速下载
set ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/
set ELECTRON_BUILDER_BINARIES_MIRROR=https://npmmirror.com/mirrors/electron-builder-binaries/
set DEBUG=electron-builder
REM 设置输出目录环境变量
set "ELECTRON_BUILDER_OUTPUT_DIR=%BUILD_OUTPUT%"
call npm run build:win -- --config.directories.output="%BUILD_OUTPUT%"
set BUILD_RESULT=%errorlevel%
set DEBUG=
set ELECTRON_MIRROR=
set ELECTRON_BUILDER_BINARIES_MIRROR=
set ELECTRON_BUILDER_OUTPUT_DIR=
echo.
echo.
echo ========================================
echo 打包完毕
echo ========================================
echo.
if %BUILD_RESULT% equ 0 (
    echo.
    echo 正在清理不需要的文件，只保留绿色版...
    echo.
    REM 删除不需要的文件和文件夹
    
    REM 删除所有 Setup 安装包（使用通配符匹配）
    for %%F in ("%BUILD_OUTPUT%\*Setup*.exe") do (
        if exist "%%F" (
            del /q "%%F" 2>nul
            echo 已删除: %%~nxF
        )
    )
    
    REM 删除 win-unpacked 文件夹（所有架构）
    REM 首先删除不带架构后缀的 win-unpacked
    if exist "%BUILD_OUTPUT%\win-unpacked" (
        rmdir /s /q "%BUILD_OUTPUT%\win-unpacked" 2>nul
        if exist "%BUILD_OUTPUT%\win-unpacked" (
            echo 警告: 无法删除 win-unpacked 文件夹
        ) else (
            echo 已删除: win-unpacked 文件夹
        )
    )
    REM 然后删除带架构后缀的文件夹（如 win-x64-unpacked, win-ia32-unpacked）
    for /d %%D in ("%BUILD_OUTPUT%\win-*-unpacked") do (
        if exist "%%D" (
            rmdir /s /q "%%D" 2>nul
            if exist "%%D" (
                echo 警告: 无法删除 %%~nxD 文件夹
            ) else (
                echo 已删除: %%~nxD 文件夹
            )
        )
    )
    
    REM 删除 builder 配置文件
    if exist "%BUILD_OUTPUT%\builder-effective-config.yaml" (
        del /q "%BUILD_OUTPUT%\builder-effective-config.yaml" 2>nul
        echo 已删除: builder-effective-config.yaml
    )
    if exist "%BUILD_OUTPUT%\builder-debug.yml" (
        del /q "%BUILD_OUTPUT%\builder-debug.yml" 2>nul
        echo 已删除: builder-debug.yml
    )
    
    REM 删除所有 .blockmap 文件
    for %%F in ("%BUILD_OUTPUT%\*.blockmap") do (
        if exist "%%F" (
            del /q "%%F" 2>nul
            echo 已删除: %%~nxF
        )
    )
    
    REM 删除 latest.yml（更新配置文件）
    if exist "%BUILD_OUTPUT%\latest.yml" (
        del /q "%BUILD_OUTPUT%\latest.yml" 2>nul
        echo 已删除: latest.yml
    )
    echo.
    echo 清理完成！
    echo.
    color 0A
    cls
    echo.
    echo ╔═══════════════════════════════════════════════════════════════╗
    echo ║                                                               ║
    echo ║                    ✓  打 包 成 功 完 成  ✓                    ║
    echo ║                                                               ║
    echo ╚═══════════════════════════════════════════════════════════════╝
    echo.
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo   生成报告
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo.
    echo   项目名称: NwServer使用说明书
    echo   打包类型: 绿色版 (便携版)
    echo   目标平台: Windows x64
    echo.
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo   输出文件
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo.
    if exist "%BUILD_OUTPUT%\NwServer使用说明书-绿色版-x64.exe" (
        for %%F in ("%BUILD_OUTPUT%\NwServer使用说明书-绿色版-x64.exe") do (
            set /a "FILE_SIZE_MB=%%~zF / 1048576"
            echo   ✓ NwServer使用说明书-绿色版-x64.exe
            echo     文件大小: %%~zF 字节 ^(约 !FILE_SIZE_MB! MB^)
            echo.
        )
    ) else (
        echo   ✗ 未找到绿色版程序文件
        echo.
    )
    echo   输出目录: %~dp0%BUILD_OUTPUT%\
    echo.
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo   使用说明
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo.
    echo   1. 绿色版程序可直接双击运行，无需安装
    echo   2. 可将程序复制到任意位置使用
    echo   3. 首次运行可能需要 Windows 防火墙授权
    echo.
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo.
    echo.
    choice /C YN /M "是否打开打包输出文件夹"
    if errorlevel 2 goto :skip_open_portable
    if errorlevel 1 start "" "%~dp0%BUILD_OUTPUT%"
    :skip_open_portable
) else (
    color 0C
    echo.
    echo X 打包失败 请检查错误信息
)
echo.
echo 按任意键返回主菜单...
pause >nul
cls
color 0B
goto menu

:exit_app
cls
echo.
echo 感谢使用
echo.
timeout /t 1 >nul
exit
