# 添加环境变量命令 add env

#  环境变量名
$name = "ZF"
# 当前文件夹路径
$dir = (Get-Location).path
# target 为 Machine 或 User
$target = "User"
# 当前环境变量值
$now = [Environment]::GetEnvironmentVariable($name, $target)
# 是否已经存在
if ( $null -ne $now ) {
    # 是否包含
    if ( $now.contains($dir) ) {
        Write-Host "用户环境变量 $name -- $dir 已存在！"
    } else {
        [Environment]::SetEnvironmentVariable($name, "$now;$dir", $target)
        Write-Host "用户环境变量 $name -- $dir 追加成功！" -ForegroundColor Green
    }
} else {
    # target 为 Machine 或 User
    [Environment]::SetEnvironmentVariable($name, $dir, $target)
    Write-Host "用户环境变量 $name -- $dir 添加成功！" -ForegroundColor Green
}

# Path 环境变量--若不想添加Path，置空即可
$common = "Path"
if ( ($null -ne $common) -and ($common -ne $name) ) {
    $commonNow = [Environment]::GetEnvironmentVariable($common, $target)
    $nameIn = "%$name%"
    # 是否已存在Path中
    if ( $now.contains($nameIn) ) {
        Write-Host "$name 已存在用户环境变量Path中！"
    } else {
        [Environment]::SetEnvironmentVariable($common, "$nameIn;$commonNow", $target)
        Write-Host "$name 已成功添加到用户环境变量Path中！" -ForegroundColor Green
    }
}

Write-Host "若想验证效果，请在新的会话窗口中进行。`n" -ForegroundColor Green