# pnpm的安装/更新命令 install/update pnpm
# 支持 本地安装包 和 在线 两种方式进行安装/更新


# 获取当前目录下最新的pnmp安装包
$name = (Get-ChildItem -Include pnpm* -Name | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1)
# 是否存在pnmp安装包
if ($null -eq $name) {
    Write-Warning "未找到pnpm的安装包，尝试在线安装"
    try {
        iwr https://get.pnpm.io/install.ps1 -useb | iex
    }
    catch {
        Write-Warning "在线安装失败，请尝试先下载pnpm的安装包，再执行此命令进行安装/更新。"
    }
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