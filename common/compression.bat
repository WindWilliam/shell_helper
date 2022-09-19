@echo off
@REM 打包专用命令
@REM 只传一个参数，则为需要打包的文件夹名称
@REM 传两个参数，则第一个为需要打包的文件夹名称，第二个为压缩包起始名称
@REM 若要指定参数对象，-d 代表文件夹名称，-f代表压缩包名称
set dirParam=dist
set fileParam=dist
@REM echo %dirParam%

@REM if里面输出的是缓存？？，和语句外输出结果不一样
if "%1%"=="-d" (
    set dirParam=%2%
    if "%3%"=="-f" (
        set fileParam=%4%
    )^
    else  if not "%3%"=="" (
        set fileParam=%3%
    )
)^
else if "%1%"=="-f" (
    set fileParam=%2%
    if "%3%"=="-d" (
        set dirParam=%4%
    )^
    else if not "%3%"=="" (
        set dirParam=%3%
    )
)^
else if not "%1%"=="" (
    set dirParam=%1%
    if "%2%"=="-f" (
        set fileParam=%3%
    )^
    else if not "%2%"=="" (
        set fileParam=%2%
    )
)^
else (
    echo 默认参数dist
) 
echo ----------
echo 最终参数

echo dirParam:%dirParam%
echo fileParam:%fileParam%
echo ----------

set/a h=%time:~0,2%,b=h+100
@REM echo fileParam:"%~dp0%fileParam%%date:~0,4%%date:~5,2%%date:~8,2%%b:~-2%.zip"
@REM "C:\Program Files\2345Soft\HaoZip\HaoZipc.exe" a -tzip "%~dp0%fileParam%%date:~0,4%%date:~5,2%%date:~8,2%%b:~-2%.zip" "%~dp0%dirParam%"
"C:\Program Files\2345Soft\HaoZip\HaoZipc.exe" a -tzip "%cd%\%fileParam%%date:~0,4%%date:~5,2%%date:~8,2%%b:~-2%.zip" "%cd%\%dirParam%" -sn

echo 压缩%dirParam%完成
@REM 打开文件夹
start .

echo %date% %time%

@echo on
