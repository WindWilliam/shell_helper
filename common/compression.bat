@echo off

@REM folder name
set dirParam=dist
@REM todo is file exist

@REM file name
set fileParam=dist

@REM file suffix
set/a h=%time:~0,2%,b=h+100
@REM how to keep date format ??
set suffix=%fileParam%%date:~0,4%%date:~5,2%%date:~8,2%%b:~-2%

tar -zcf %suffix%.tar.gz %dirParam%

echo compress %dirParam% to %suffix% completely!

start .

echo %date% %time%

@echo on
