@echo off

@REM Author: zf
@REM Date: 2022-09-18 23:28:55
@REM LastEditTime: 2023-03-24 23:53:08
@REM LastEditors: zf
@REM Description: compress folder with special name

@REM folder name
set dirParam=dist

@REM check folder
IF NOT EXIST %dirParam% (
    echo no %dirParam%
    exit 1
)

@REM file name prefix
set fileParam=dist

@REM file suffix
set/a h=%time:~0,2%,b=h+100
@REM how to keep date format ??
set suffix=%fileParam%%date:~0,4%%date:~5,2%%date:~8,2%%b:~-2%

@REM compress folder by tar and gz
tar -zcf %suffix%.tar.gz %dirParam%

echo compress %dirParam% to %suffix% completely!

@REM open folder now 
start .
@REM date and time now
echo %date% %time%

@echo on
