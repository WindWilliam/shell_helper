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
    }
    else {
        return $val
    }
}

<# 检查别名是否存在 #>
function CheckAliasExists {
    param (
        [string]$name
    )

    if ( Get-Command $name -ErrorAction SilentlyContinue ) {
        Write-Warning "命令 $name 已存在！"
        return $false
    } 
    elseif ( Get-Alias -Name $name -ErrorAction SilentlyContinue ) {
        Write-Warning "别名 $name 已存在！"
        return $false
    }
    else {
        return $true
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
            return $name
        }
        else {
            return GetAliasName
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
    # 别名注释行以及set-alias行
    $updated = $now | Where-Object { $_ -notmatch "^# 添加别名 $name" -and $_ -notmatch "^Set-Alias -Name $name " }
    # $updated = $now | Where-Object { $_ -notmatch " $name " }
    Set-Content -Path $profile -Value $updated

    Write-Host "`n全局别名 $name 删除成功！" -ForegroundColor Green
}
<# 注释别名 #>
function CommentAlias {
    $name = GetAliasName

    $now = Get-Content -Path $profile
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