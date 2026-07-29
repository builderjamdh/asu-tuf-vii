$ErrorActionPreference = 'Stop'

$src = 'C:\Users\Dahi\Downloads\official_src\asuswrt\release\src-rt-5.04behnd.4916'
$dst = 'C:\Users\Dahi\Documents\GitHub\asus-tuf-v2-dahi\asu-tuf-vii\release\src-rt-5.04behnd.4916'

$synced = 0
$skipped = 0

$dirs = @(
    # Broadcom HND 驱动源码
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
    # Broadcom 预编译对象文件 (prebuilt .o / .h / 二进制)
    'router-sysdep\hnd_extra\prebuilt'
    'router-sysdep\wlan\nvram\prebuilt'
    'bcmdrivers\opensource\phy\prebuilt'
    'router-sysdep\archerctl\prebuilt'
    'router-sysdep\archer_lib\prebuilt'
    'router-sysdep\bcmmcast\prebuilt'
    'router-sysdep\bcmmcastctl\prebuilt'
    'router-sysdep\bcm_boardctl\prebuilt'
    'router-sysdep\bcm_bootstate\prebuilt'
    'router-sysdep\bcm_boot_launcher\prebuilt'
    'router-sysdep\bcm_flasher\prebuilt'
    'router-sysdep\bcm_flashutil\prebuilt'
    'router-sysdep\bcm_util\prebuilt'
    'router-sysdep\blogctl\prebuilt'
    'router-sysdep\blogctl_lib\prebuilt'
    'router-sysdep\bp3\prebuilt'
    'router-sysdep\bp3hal\prebuilt'
    'router-sysdep\bpmctl\prebuilt'
    'router-sysdep\bridgeutil\prebuilt'
    'router-sysdep\dhd_monitor\prebuilt'
    'router-sysdep\eapd\linux\prebuilt'
    'router-sysdep\emf\emfconf\prebuilt'
    'router-sysdep\emf\igsconf\prebuilt'
    'router-sysdep\ethctl\prebuilt'
    'router-sysdep\ethctl_lib\prebuilt'
    'router-sysdep\ethswctl\prebuilt'
    'router-sysdep\ethswctl_lib\prebuilt'
    'router-sysdep\fcctl\prebuilt'
    'router-sysdep\fcctl_lib\prebuilt'
    'router-sysdep\gen_util\prebuilt'
    'router-sysdep\httpdshared\prebuilt'
    'router-sysdep\iqctl\prebuilt'
    'router-sysdep\iqctl_lib\prebuilt'
    'router-sysdep\mcpctl\prebuilt'
    'router-sysdep\mcpd\prebuilt'
    'router-sysdep\pwrctl\prebuilt'
    'router-sysdep\pwrctl_lib\prebuilt'
    'router-sysdep\scratchpadctl\prebuilt'
    'router-sysdep\stress\prebuilt'
    'router-sysdep\tmctl\prebuilt'
    'router-sysdep\tmctl_lib\prebuilt'
    'router-sysdep\vlanctl\prebuilt'
    'router-sysdep\vlanctl_lib\prebuilt'
    'router-sysdep\wdtctl\prebuilt'
    'router-sysdep\wlan\epittcp\prebuilt'
    'router-sysdep\wlconf\prebuilt'
    'router-sysdep\wlcsm\prebuilt'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\apps\acsdv2\prebuilt'
    'bcmdrivers\broadcom\net\wl\impl105\main\components\apps\cevent_app\prebuilt'
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
