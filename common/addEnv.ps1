# 添加环境变量命令 add env

#  环境变量名
$dftName = "ZF"
# 当前文件夹路径
$dtfValue = (Get-Location).path
# 环境变量类型，"Machine" 或者是 "User"
$dftTarget = "User"

<# 获取输入值 #>
function GetInput {
    param (
        [string]$prompt,
        [string]$dft
    )
    $userInput = Read-Host "$prompt，默认为 $dft "
    if ($userInput -eq "") {
        $userInput = $dft
    }
    return $userInput
}

<# 获取环境变量名 #>
function GetEnvName {
    $val = GetInput -prompt "请输入环境变量的名称" -dft $dftName
    # 将字符串转换为大写
    $val = $val.ToUpper()
    return $val
}

<# 检查环境变量值是否已存在 #>
function CheckEnvValue {
    param (
        [string]$key,
        [string]$val
    )
    $envPaths = [Environment]::GetEnvironmentVariable($key, $dftTarget) -split ';'
    # 判断路径是否在环境变量中
    if ($envPaths -contains $val) {
        # todo 置顶此环境变量
        Write-Host "环境变量中已存在 $val !" -ForegroundColor Green
        return $false
    }
    else {
        return $true
    }
}

<# 获取环境变量值 #>
function GetEnvValue {
    param (
        [string]$key
    )
    $val = GetInput -prompt "请输入环境变量的值（支持相对路径和其他环境变量的名称）" -dft $dtfValue
    # 判断是否是环境变量名
    if ( $val.StartsWith("%") -and $val.EndsWith("%") ) {
        # 非path变量名，不支持添加变量名
        if ($key -ne "PATH") {
            Write-Host "不支持在非PATH变量名中添加变量名！" -ForegroundColor Red
            return GetEnvValue
        }
        else {
            # 直接返回
            return $val
        }
    }
    else {
        # 转换为绝对路径
        try {
            $val = Convert-Path $val
        }
        catch {
            Write-Warning "路径 $val 转换发生异常: $_"
            Write-Host "`n请检查并重新输入！`n" -ForegroundColor Red
            return GetEnvValue
        }
    }
    # 判断环境变量值是否已存在
    if ( !(Test-Path $val) ) {
        Write-Warning "路径 $val 不存在，请检查并重新输入！`n"
        return GetEnvValue
    }
    # 判断环境变量值是否已存在
    $ck = CheckEnvValue -key $key -val $val
    if ( $ck ) {
        return $val
    }
    else {
        return GetEnvValue
    }
}

<# 将环境变量名添加到PATH中 #>
function AddEnvNameToPath {
    param (
        [string]$key
    )
    $pathName = "PATH"
    $now = [Environment]::GetEnvironmentVariable($pathName, $dftTarget)
    # 判断环境变量是否存在  Test-Path "Env:$key"
    if (!($now -match "%$key%")) {
        # 环境变量名称不存在，添加到PATH中
        [Environment]::SetEnvironmentVariable($pathName, "%$key%;$now;", $dftTarget)
    }
}

<# 添加环境变量 #>
function AddEnv {
    param (
        [string]$key,
        [string]$value
    )
    # 判断是否已存在
    $now = [Environment]::GetEnvironmentVariable($key, $dftTarget)
    if ( $null -ne $now ) {
        # $now.EndsWith(";")
        [Environment]::SetEnvironmentVariable($key, "$value;$now", $dftTarget)
    }
    else {
        [Environment]::SetEnvironmentVariable($key, "$value", $dftTarget)
    }
    # 在PATH中置顶注册
    AddEnvNameToPath -key $key
}


<# ======开始====== #>
Write-Host "欢迎使用环境变量添加工具！" -ForegroundColor Green
Write-Host "请依次输入环境变量的名称与值，实现添加环境变量功能。" -ForegroundColor Green
Write-Host "注意：环境变量名称不区分大小写。`n" -ForegroundColor Yellow

$envName = GetEnvName
$envValue = GetEnvValue -key $envName
# 添加环境变量
AddEnv -key $envName -value $envValue

# 重载环境变量--无效
# [System.Environment]::GetEnvironmentVariables()

Write-Host "`n用户环境变量 $envName -- $envValue 设置成功！" -ForegroundColor Green
Write-Host "可以通过输入 `$env:$envName -split ';'|grep $envValue 检查是否成功添加。" -ForegroundColor Green
Write-Host "若未见设置的环境变量，请重启PowerShell之后再查看确认。" -ForegroundColor Yellow
<# ======结束====== #>