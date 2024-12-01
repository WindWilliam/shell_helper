<#
.SYNOPSIS
    PowerShell的别名管理工具

.DESCRIPTION
    当前用户的PowerShell配置文件中的别名管理，支持添加、删除、注释、取消注释别名。

.PARAMETER Name
    别名的名称。

.PARAMETER Value
    别名指向的命令。

.PARAMETER Mode
    模式，可选值：add、rm、cm、ucm。默认为add。
    其中，add表示添加别名，rm表示删除别名，cm表示注释别名，ucm表示取消注释别名。

.EXAMPLE
    addAlias.ps1 ll Get-ChildItem

.EXAMPLE
    addAlias.ps1 -Name ll -Value Get-ChildItem -Mode add
    
.EXAMPLE
    addAlias.ps1 -Name ll -Mode cm
    
.EXAMPLE
    addAlias.ps1 -Name ll -Mode ucm
    
.EXAMPLE
    addAlias.ps1 -Name ll -Mode rm

.NOTES
    作者: zf
    创建日期: 2022-09-18
#>

<# 参数部分 #>
param (
    [string]$Name,
    [string]$Value,
    [string]$Mode
)

<# 获取输入值 #>
function GetInput {
    param (
        [string]$prompt,
        [switch]$check
    )

    $val = Read-Host $prompt
    if ($val -eq "" -and $check) {
        Write-Host "输入不能为空，请重新输入！" -ForegroundColor Red
        return GetInput -prompt $prompt -check $check
    }
    else {
        return $val
    }
}

<# 获取当前别名的值 #>
function GetAliasNow {
    param (
        [string]$aname,
        [switch]$keep
    )
    
    # 获取当前别名配置信息
    $alias = Get-Content -Path $profile | Where-Object { $_ -match "^Set-Alias -Name $aname " }
    if (!$alias) {
        if ($keep) {
            return $false
        }
        else {
            # 直接退出
            Write-Host "`n别名 $aname 不存在！" -ForegroundColor Red
            exit(1)
        }
    }
    else {
        # 取出别名配置信息
        $avalue = $alias -replace "^Set-Alias -Name $aname ", ""
        # $val = $val -replace "`n", ""
        # 输出当前别名配置信息
        if ($keep) {
            Write-Warning "当前别名 $aname 已配置为： $avalue ！"
            return $true
        }
        else {
            Write-Host "`n当前别名 $aname 的配置信息： $avalue "
        }
    }
}

<# 检查别名是否存在 #>
function CheckAliasExists {
    param (
        [string]$aname
    )

    # 1. 直接搜索用户配置文件
    $now = GetAliasNow -aname $aname -keep
    if ($now) {
        return $true
    }
    else {
        # 2. 查找系统别名
        $alias = $(Get-Alias $aname -ErrorAction SilentlyContinue)
        if ($alias) {
            $dname = $alias.DisplayName
            Write-Warning "系统别名中已存在此别名配置： $dname ！"
            return $true
        }
        else {
            # 3. 查找系统命令
            $cmd = $(Get-Command $aname -ErrorAction SilentlyContinue)
            if ($cmd) {
                $csource = $cmd.Source
                Write-Warning "当前别名 $aname 与系统命令 $csource 冲突！"
                return $true
            }
            else {
                return $false
            }
        }
    }
}

<# 获取别名的名称 #>
function GetAliasName {
    param (
        [switch]$check
    )

    $aname = GetInput -prompt "请输入别名的名称，例如：pp" -check
    if (!$check) {
        return $aname
    }
    else {
        $exist = CheckAliasExists -aname $aname
        if ($exist) {
            return GetAliasName -check $check
        }
        else {
            return $aname
        }
    }
}

<# 添加别名 #>
function AddAlias {
    if (!$Name) {
        $Name = GetAliasName -check
    }
    else {
        # 检查别名是否存在
        $exist = CheckAliasExists -aname $Name
        if ($exist) {
            $Name = GetAliasName -check
        }
    }
    if (!$Value) {
        $Value = GetInput -prompt "请输入别名对应的值，例如：pnpm" -check
    }
    # 添加别名
    "# 添加别名 $Name $Value 于$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`nSet-Alias -Name $Name $Value`n" | Out-File -Append $profile

    Write-Host "`n别名 $Name -> $Value 添加成功！" -ForegroundColor Green
}

<# 删除别名 #>
function DeleteAlias {
    if (!$Name) {
        $Name = GetAliasName
    }

    $now = Get-Content -Path $profile
    # 获取当前别名配置信息
    GetAliasNow -aname $Name
    # 别名不存在会自动退出，故此处无需判断
    $doDelete = GetInput -prompt "是否要删除别名 $Name ？(y/n)"
    if ($doDelete.StartsWith("n") -or $doDelete.StartsWith("N")) {
        Write-Host "`n取消删除别名 $Name ！" -ForegroundColor Yellow
        return
    }

    # 注释和配置 两行一起删除
    $updated = $now | Where-Object { $_ -notmatch "^# 添加别名 $Name" -and $_ -notmatch "^Set-Alias -Name $Name " }
    # $updated = $now | Where-Object { $_ -notmatch " $name " }
    Set-Content -Path $profile -Value $updated

    Write-Host "`n别名 $Name 删除成功！" -ForegroundColor Green
}

<# 注释别名 #>
function CommentAlias {
    if (!$Name) {
        $Name = GetAliasName
    }

    $now = Get-Content -Path $profile
    # 获取当前别名配置信息
    GetAliasNow -aname $Name
    # 别名不存在会自动退出，故此处无需判断
    $doComment = GetInput -prompt "是否要注释别名 $Name ？(y/n)"
    if ($doComment.StartsWith("n") -or $doComment.StartsWith("N")) {
        Write-Host "`n取消注释别名 $Name ！" -ForegroundColor Yellow
        # 直接退出
        exit(0)
    }
    $updated = $now | ForEach-Object { 
        if ($_ -match "^Set-Alias -Name $Name ") {
            "# $_" 
        }
        else { 
            $_ 
        }
    }
    Set-Content -Path $profile -Value $updated

    Write-Host "`n别名 $Name 注释成功！" -ForegroundColor Green
}

<# 取消注释别名 #>
function UndoCommentAlias {
    if (!$Name) {
        $Name = GetAliasName
    }
    
    $reg = "^# Set-Alias -Name $Name "
    # 获取当前别名配置信息
    $now = Get-Content -Path $profile
    $alias = $now | Where-Object { $_ -match "$reg" }
    if (!$alias) {
        # 直接退出
        Write-Host "`n不存在注释的别名 $Name ！" -ForegroundColor Red
        exit(1)
    }
    else {
        # 取出别名配置信息
        $avalue = $alias -replace "$reg", ""
        # 输出当前别名配置信息
        Write-Host "`n注释的别名 $Name 的配置内容： $avalue "

        $doComment = GetInput -prompt "是否要取消注释别名 $Name ？(y/n)"
        if ($doComment.StartsWith("n") -or $doComment.StartsWith("N")) {
            Write-Host "`n保持注释别名 $Name ！" -ForegroundColor Yellow
            # 直接退出
            exit(0)
        }
        $updated = $now | ForEach-Object {
            if ($_ -match "$reg") {
                "$_" -replace "^#\s*", "" 
            }
            else { 
                $_ 
            }
        }
        Set-Content -Path $profile -Value $updated
    
        Write-Host "`n别名 $Name 取消注释成功！" -ForegroundColor Green
    }
}

<# 处理模式 #>
function ProcessMode {
    param (
        [string]$action
    )

    # 根据输入参数选择处理模式--默认为add
    switch ($action) {
        "rm" {
            Write-Host "当前为别名删除模式！" -ForegroundColor Green
            DeleteAlias
        }
        "cm" {
            Write-Host "当前为别名注释模式！" -ForegroundColor Green
            CommentAlias
        }
        "ucm" {
            Write-Host "当前为别名取消注释模式！" -ForegroundColor Green
            UndoCommentAlias
        }
        default {
            Write-Host "当前为别名添加模式！" -ForegroundColor Green
            AddAlias
        }
    }
}


<# ======开始====== #>
Write-Host "欢迎使用PowerShell别名管理工具！" -ForegroundColor Green
Write-Host "注意：别名不区分大小写。`n" -ForegroundColor Yellow

# 调用函数
ProcessMode -action $Mode

# 重载配置文件--无效
# . $profile

Write-Host "请输入 . `$profile 以手动更新环境变量，或是重启PowerShell，然后再进行验证。" -ForegroundColor Yellow
<# ======结束====== #>