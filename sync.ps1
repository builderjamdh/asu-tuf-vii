$ErrorActionPreference = 'Stop'

$src = 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916'
$dst = 'C:\Users\Dahi\Documents\GitHub\asus-tuf-v2-dahi\asu-tuf-vii\release\src-rt-5.04behnd.4916'

$synced = 0
$skipped = 0

$dirs = @(
    'router-sysdep\nas'
    'bcmdrivers\broadcom\char\bcmprocfs'
    'bcmdrivers\broadcom\char\gpon'
    'bcmdrivers\broadcom\char\sata_test'
    'bcmdrivers\broadcom\char\tms'
    'bcmdrivers\broadcom\char\xtmcfg'
    'bcmdrivers\broadcom\net\eapfwd'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\phy\ac'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\phy\cmn'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\avs'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\clm-api'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\pasn'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\shared'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\apps\escand'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\apps\visualization'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\apps\wldm'
)

foreach ($d in $dirs) {
    $s = Join-Path $src $d
    $t = Join-Path $dst $d
    if (Test-Path $s) {
        if (-not (Test-Path $t)) {
            New-Item $t -ItemType Directory -Force | Out-Null
        }
        Copy-Item (Join-Path $s '*') $t -Recurse -Force
        $synced++
        Write-Host "SYNC: $d"
    } else {
        $skipped++
        Write-Host "SKIP: $d (not found)"
    }
}

Write-Host ""
Write-Host "Done: synced=$synced skipped=$skipped"
