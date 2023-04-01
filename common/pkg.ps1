# 打包命令 package
# 通过tar来归档压缩


# 待压缩文件夹
$folder = "dist"
# 文件夹是否存在
if (Test-Path -Path $folder) {
    # 压缩后名称
    $fileName = "result" + (Get-Date -Format "yyyyMMddHH") + ".tar.gz"

    tar -zcf $fileName $folder

    Write-Host $(Get-Date) " 压缩完成！`n" -ForegroundColor Green
    start .
} else {
    Write-Error "$folder 文件夹不存在，压缩失败！"
}