# pnpm的安装/更新命令
# 单纯安装，需提前下载pnpm的安装包，才能进行安装/更新

# 获取当前目录下最新的pnmp安装包
$name = (ls * |where {$_.Name -like "pnpm*"} | sort LastWriteTime -desc | select -f 1).name
# 是否存在pnmp安装包
if ($null -eq $name) {
    Write-Error "未找到pnpm的安装包，尝试在线安装"

    iwr https://get.pnpm.io/install.ps1 -useb | iex
} else {
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
}