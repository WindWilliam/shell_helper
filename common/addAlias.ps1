# 当前用户的PowerShell配置文件中的别名管理

<# 获取输入值 #>
function GetInput {
    param (
        [string]$prompt
    )

    $val = Read-Host $prompt
    if ($val -eq "") {
        Write-Host "输入不能为空，请重新输入！" -ForegroundColor Red
        return GetInput -prompt $prompt
    } else {
        return $val
    }
}

<# 获取当前别名的值 #>
function GetAliasNow {
    param (
        [string]$name,
        [boolean]$keep = $false
    )
    
    # 获取当前别名配置信息
    $alias = Get-Content -Path $profile | Where-Object { $_ -match "^Set-Alias -Name $name " }
    if (!$alias) {
        if($keep) {
            return $false
        } else {
            # 直接退出
            Write-Host "`n全局别名 $name 不存在！" -ForegroundColor Red
            exit(1)
        }
    } else {
        # 取出别名配置信息
        $val = $alias -replace "^Set-Alias -Name $name ", ""
        # $val = $val -replace "`n", ""
        # 输出当前别名配置信息
        if($keep) {
            Write-Warning "当前别名 $name 已配置为： $val ！"
        } else {
            Write-Host "`n当前别名 $name 的配置信息： $val "
        }
        return $alias
    }
}

<# 检查别名是否存在 #>
function CheckAliasExists {
    param (
        [string]$name
    )

    # 检测是否已存在此别名
    $alias = $(Get-Alias $name -ErrorAction SilentlyContinue)
    if ($alias) {
        # 此处分两种情况--在配置文件中注册，或者是其他地方注册了别名
        $now = GetAliasNow -name $name -keep $true
        if (!$now) {
            $kv = $alias.DisplayName
            Write-Warning "$kv 已存在系统默认配置中！"
        }
        return $true
    } else {
        $cmd = $(Get-Command $name -ErrorAction SilentlyContinue)
        if ($cmd) {
            $kv = $cmd.Definition
            Write-Warning "当前别名 $name 与系统命令 $kv 冲突！"
            return $true
        } else {
            return $false
        }
    }
}

<# 获取别名的名称 #>
function GetAliasName {
    param (
        [boolean]$check = $false
    )

    $name = GetInput -prompt "请输入别名的名称，例如：pp"
    if(!$check) {
        return $name
    } else {
        $ck = CheckAliasExists -name $name
        if ($ck) {
            return GetAliasName -check $true
        } else {
            return $name
        }
    }
}

<# 获取别名的值 #>
function GetAliasValue {
    $val = GetInput -prompt "请输入别名对应的值，例如：pnpm"
    return $val
}

<# 添加别名 #>
function AddAlias {
    $name = GetAliasName -check $true
    $val = GetInput -prompt "请输入别名对应的值，例如：pnpm"
    # 添加别名
    "# 添加别名 $name $val 于$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`nSet-Alias -Name $name $val`n" | Out-File -Append $profile

    Write-Host "`n全局别名 $name 添加成功！" -ForegroundColor Green
}

<# 删除别名 #>
function DeleteAlias {
    $name = GetAliasName

    $now = Get-Content -Path $profile
    # 获取当前别名配置信息
    GetAliasNow -name $name
    # 别名不存在会自动退出，故此处无需判断
    $doDelete =  GetInput -prompt "是否要删除别名 $name ？(y/n)"
    if ($doDelete.StartsWith("n") -or $doDelete.StartsWith("N")) {
        Write-Host "`n取消删除别名 $name ！" -ForegroundColor Yellow
        # 直接退出
        exit(0)
    }

    # 注释和配置 两行一起删除
    $updated = $now | Where-Object { $_ -notmatch "^# 添加别名 $name" -and $_ -notmatch "^Set-Alias -Name $name " }
    # $updated = $now | Where-Object { $_ -notmatch " $name " }
    Set-Content -Path $profile -Value $updated

    Write-Host "`n全局别名 $name 删除成功！" -ForegroundColor Green
}

<# 注释别名 #>
function CommentAlias {
    $name = GetAliasName

    $now = Get-Content -Path $profile
    # 获取当前别名配置信息
    GetAliasNow -name $name
    # 别名不存在会自动退出，故此处无需判断
    $doComment =  GetInput -prompt "是否要注释别名 $name ？(y/n)"
    if ($doComment.StartsWith("n") -or $doComment.StartsWith("N")) {
        Write-Host "`n取消注释别名 $name ！" -ForegroundColor Yellow
        # 直接退出
        exit(0)
    }
    $updated = $now | ForEach-Object { if ($_ -match "^Set-Alias -Name $name ") { "# $_" } else { $_ } }
    Set-Content -Path $profile -Value $updated

    Write-Host "`n全局别名 $name 注释成功！" -ForegroundColor Green
}


<# ======开始====== #>
Write-Host "欢迎使用PowerShell全局别名管理工具！" -ForegroundColor Green
Write-Host "注意：别名不区分大小写。`n" -ForegroundColor Yellow

# 根据输入参数选择处理模式--默认为add
switch ($args[0]) {
    "d" {
        DeleteAlias
    }
    "c" {
        CommentAlias
    }
    default {
        AddAlias
    }
}

# 重载配置文件--无效
# . $profile

Write-Host "请输入 . `$profile 以手动更新环境变量，或是重启PowerShell，然后再进行验证。" -ForegroundColor Yellow
<# ======结束====== #>