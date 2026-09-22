$ErrorActionPreference = "Stop"
$gcc = "W:\mingw64\bin\gcc.exe"
$root = "C:\Users\fm3at\Documents\OpenCodeProject\png2jpg"
$obj  = "$root\obj"
New-Item -ItemType Directory -Force -Path $obj | Out-Null

Write-Host "Compiling..."
& $gcc @("-Os", "-ffunction-sections", "-fdata-sections", "-c", "$root\png2jpg.c", "-o", "$obj\png2jpg.o")
if ($LASTEXITCODE -ne 0) { Write-Error "compile failed"; exit 1 }

$lib = "$root\lib"
& "W:\mingw64\bin\dlltool.exe" --kill-at "--output-lib=$lib\libole32.a" "--input-def=$lib\ole32.def" --dllname ole32.dll | Out-Null
& "W:\mingw64\bin\dlltool.exe" --kill-at "--output-lib=$lib\libshlwapi.a" "--input-def=$lib\shlwapi.def" --dllname shlwapi.dll | Out-Null

Write-Host "Linking..."
& $gcc @("-Os", "-municode", "-mconsole", "-static", "-s",
          "-Wl,--gc-sections", "-Wl,--exclude-libs,ALL",
          "-o", "$root\png2jpg.exe") "$obj\png2jpg.o" "$lib\libole32.a" "$lib\libshlwapi.a"
if ($LASTEXITCODE -ne 0) { Write-Error "link failed"; exit 1 }
Get-Item "$root\png2jpg.exe" | Select-Object Name, Length

Write-Host "Compressing with UPX..."
& upx -9 --lzma "$root\png2jpg.exe"
if ($LASTEXITCODE -ne 0) { Write-Error "upx failed"; exit 1 }
Get-Item "$root\png2jpg.exe" | Select-Object Name, Length
