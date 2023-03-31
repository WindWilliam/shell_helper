# pnpm的安装/更新命令
# 单纯安装，需提前下载pnpm的安装包，才能进行安装/更新

# 获取最新pnmp的安装包名称
$name = (ls * |where {$_.Name -like "pnpm*"} | sort LastWriteTime -desc | select -f 1).name

if ($null -eq $name) {
    Write-Error "未找到pnpm的安装包！"
    exit 1
}

if ("pnpm.exe" -eq $name) {
    # 安装/更新 ---- pnpm.exe是全局变量，故此处需要注意使用相对路径
    Start-Process -FilePath .\pnpm.exe -ArgumentList "setup" -NoNewWindow -Wait -ErrorAction Continue
    
    Write-Host "安装/升级完成...`n" -ForegroundColor Green
}else {
    # 重命名，不然安装后文件名称不对
    Rename-Item -Path $name -NewName pnpm.exe

    # 安装/更新 ---- pnpm.exe是全局变量，故此处需要注意使用相对路径
    Start-Process -FilePath .\pnpm.exe -ArgumentList "setup" -NoNewWindow -Wait -ErrorAction Continue

    # 还原重命名
    Rename-Item -Path pnpm.exe -NewName $name
    
    Write-Host "安装/升级完成...`n" -ForegroundColor Green
}