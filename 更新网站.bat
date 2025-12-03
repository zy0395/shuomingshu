@echo off
chcp 65001 >nul
echo ========================================
echo    NwServer 说明书 - 一键更新网站
echo ========================================
echo.

set /p msg="请输入更新说明: "

echo.
echo 正在提交修改...
git add -A
git commit -m "%msg%"

echo.
echo 正在推送到 GitHub...
git push github main

echo.
echo 正在推送到 Gitee...
git push origin main

echo.
echo ========================================
echo 更新完成！网站将在1-2分钟后生效
echo 访问地址: https://zy0395.github.io/shuomingshu
echo ========================================
pause
