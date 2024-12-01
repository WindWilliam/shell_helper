<#
.SYNOPSIS
    pnpm的安装与更新

.DESCRIPTION
    pnpm的安装与更新命令，支持 本地安装包 和 在线 两种方式进行安装或者是更新。

.EXAMPLE
    iupp.ps1
    # 本地安装/更新pnpm

.EXAMPLE
    iupp.ps1 o
    # 在线安装/更新pnpm

.NOTES
    作者: zf
    创建日期: 2022-09-18
#>

<# 获取当前pnpm的版本 #>
function GetPnpmVersion {
    # 获取pnpm的版本--可能不存在
    $version = $null
    $exist = Get-Command pnpm -ErrorAction SilentlyContinue
    # 存在则获取版本号
    if ($exist) {
        $version = (pnpm -v)
        Write-Host "当前pnpm版本为 $version"
        # 检测是否正在使用pnpm--正在使用则不能安装，直接退出
        $pnpmProcess = Get-Process -Name pnpm -ErrorAction SilentlyContinue
        if ($pnpmProcess) {
            Write-Host "pnpm正在运行，请先关闭后再进行更新！" -ForegroundColor Red
            exit(1)
        }
    }
    return $version
}

<# 备份pnpm.exe #>
function BackupPnpm {
    param (
        [string]$version
    )

    # 存在则获取版本号并进行备份
    if ($version) {
        # 进行备份
        $source = (Get-Command pnpm -ErrorAction SilentlyContinue).Source
        $backupName = "pnpm-$version.exe"
        # 存在则跳过备份
        if (Test-Path $backupName) {
            Write-Host "已存在备份文件 $backupName，跳过备份！`n"
        }
        else {
            # 进行备份
            Copy-Item $source $backupName
            Write-Host "已备份原有pnpm文件为 $backupName！`n"
        }
    }
}

<# 添加pnpm的别名 #>
function AddShortAlias {
    # 是否存在addAlias.ps1？
    if ( Get-Command addAlias.ps1 -ErrorAction SilentlyContinue ) {
        # 是否需要添加别名？
        $need = Read-Host "是否需要设置pnpm的别名（建议为pp或者是pn）？(y/n)"
        if ($need -eq "y" -or $need -eq "Y") {
            addAlias.ps1 -Value pnpm
        }
    }
    else {
        Write-Host "建议添加pp或是pn的别名，来代替pnpm命令！"
    }
}

<# 安装成功后的提示 #>
function SuccessMessage {
    param (
        [string]$old
    )

    if ($old) {
        # 获取当前版本--第一次安装可能获取不到。
        $now = (pnpm -v)
        if ($now -eq $old) {
            Write-Host "pnpm版本还是 $now，未发生变化，更新失败！" -ForegroundColor Red
            return
        }
        Write-Host "`n已成功更新pnpm $old 到 $now 版本！" -ForegroundColor Green
        Write-Host "可执行 pnpm -v 验证是否安装成功！" -ForegroundColor Green
    }
    else {
        Write-Host "`n已成功安装pnpm！" -ForegroundColor Green
        AddShortAlias
        Write-Host "请重启PowerShell后执行 pnpm -v 验证是否安装成功！" -ForegroundColor Green
    }
}

<# 在线安装 #>
function InstallOnline {
    # 获取当前版本
    $old = GetPnpmVersion
    if ($old) {
        # 当前版本是否为最新版本？
        $latest = (Invoke-WebRequest https://registry.npmjs.org/pnpm/latest -UseBasicParsing | ConvertFrom-Json).version
        if ($old -eq $latest) {
            Write-Host "当前版本已是最新版本$latest，无需更新！" -ForegroundColor Green
            return
        }
        else {
            Write-Host "即将从 $old 在线更新到 $latest 版本..." -ForegroundColor Green
            # 备份原有版本
            BackupPnpm -version $old
        }
    }
    # 下载安装包
    try {
        # 此处有污染方法内部变量的风险，故最好再外封一层function
        Invoke-WebRequest https://get.pnpm.io/install.ps1 -useb | Invoke-Expression
    }
    catch {
        Write-Host "`n"
        Write-Host "$_" -ForegroundColor Red
        Write-Host "`n"
        Write-Warning "在线安装失败，请尝试先下载pnpm的安装包，再执行此命令进行安装/更新。"
        return
    }
    # 成功安装/更新后提示
    Write-Host "安装后原先版本为 $tmp ！"
    SuccessMessage -old $old
}

<# 倒计时 #>
function CountDown {
    param (
        [int]$seconds,
        [string]$prompt
    )

    for ($i = $seconds; $i -gt 0; $i--) {
        # 使用 -NoNewline 控制不换行
        Write-Host "$i 秒后将$prompt..." -NoNewline
        Start-Sleep -Seconds 1
        # 使用回车符回到行首
        Write-Host "`e[2K`r" -NoNewline
        # Write-Host "`r" -NoNewline
    }
    Write-Host "`n正在进行$prompt" -ForegroundColor Green
}

<# 本地安装 #>
function InstallLocal {
    $file = (Get-ChildItem -Include pnpm* -Name | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1)
    if ($null -eq $file) {
        Write-Warning "未找到pnpm的安装包!`n"
        CountDown -seconds 10 -prompt "在线安装pnpm"
        InstallOnline
    }
    else {
        $version = GetPnpmVersion
        if ($version) {
            # 获取当前文件的版本
            $fileVersion = (& ".\$file" -v)
            if ($version -eq $fileVersion) {
                Write-Host "`n当前版本 $version 与安装包的${file}版本 $fileVersion 一致，无需更新！" -ForegroundColor Green
                return
            }
            else {
                #  版本比较
                $sVer = [System.Version]::new("$version")
                $fVer = [System.Version]::new("$fileVersion")
                if ($sVer -gt $fVer) {
                    # Write-Host "`n"
                    Write-Warning "当前版本 $version 高于安装包的${file}版本 $fileVersion ！"
                    # 输入y则继续安装，否则退出
                    $recover = Read-Host "是否继续安装？(y/n)"
                    if ($recover -ne "y" -or $recover -ne "Y") {
                        Write-Host "`n已取消安装！" -ForegroundColor Green
                        return
                    }
                    else {
                        Write-Warning "即将通过安装包${file}回退到 $fileVersion 版本..."
                    }
                }
                else {
                    Write-Host "即将通过安装包${file}更新到 $fileVersion 版本..." -ForegroundColor Green
                }
                CountDown -seconds 10 -prompt "本地安装pnpm"
                # 备份原有版本
                BackupPnpm -version $version
            }
        }

        # 安装文件是否为pnpm.exe
        $rename = ($file -ne "pnpm.exe")
        if ($rename) {
            # 重命名，不然安装后文件名称不对
            Rename-Item -Path $file -NewName pnpm.exe
        }
        # 安装/更新 ---- pnpm.exe是全局变量，故此处需要注意使用相对路径
        Start-Process -FilePath .\pnpm.exe -ArgumentList "setup" -NoNewWindow -Wait -ErrorAction Continue
        if ($rename) {
            # 还原文件名称
            Rename-Item -Path pnpm.exe -NewName $file
        }
        # 成功安装/更新后提示
        SuccessMessage -old $version
    }
}


<# ======开始====== #>
Write-Host "欢迎使用pnpm安装/更新工具！" -ForegroundColor Green
# 根据输入参数选择处理模式--默认为本地安装/更新
switch ($args[0]) {
    "o" {
        Write-Host "将进行在线安装/更新pnpm...`n" -ForegroundColor Green
        InstallOnline
    }
    default {
        Write-Host "将进行本地安装/更新pnpm...`n" -ForegroundColor Green
        InstallLocal
    }
}
<# ======结束====== #>