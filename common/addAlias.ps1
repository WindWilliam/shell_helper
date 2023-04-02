# 增加全局别名命令  add-alias


$aliasName = "pp"
$aliasValue = "pnpm"

# 别名是否存在
if ( Get-Command $aliasName -ErrorAction SilentlyContinue ) {
    Write-Warning "别名 $aliasName 已存在！"
    exit 1
} else {
    # 确认是不是配置未生效
    if ( Test-Path $profile ) {
        # 是否已有内容
        $now = Get-Content -Path $profile
        if ( ($null -ne $now) -and ($now.contains("Set-Alias -Name $aliasName")) ) {
            Write-Warning "别名 $aliasName 已存在别名配置中！"
            exit 1
        }
    }
}

# 添加别名
"Set-Alias -Name $aliasName $aliasValue" | Out-File -Append $profile

Write-Host "添加全局别名 $aliasName 成功！" -ForegroundColor Green
Write-Host "若想验证效果，请在新的会话窗口中进行。`n" -ForegroundColor Green