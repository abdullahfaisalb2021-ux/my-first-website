Add-Type -AssemblyName System.Drawing

$srcDir = "C:\Users\abdul\Documents\Qoder\2026-10-13\d8c49fcb\vibe_images"
$dstDir = "C:\Users\abdul\Documents\Qoder\2026-10-13\d8c49fcb\assets\images"
New-Item -ItemType Directory -Force -Path $dstDir | Out-Null

function Convert-Image {
    param($SrcPath, $DstPath, [int]$MaxWidth, [int]$Quality)
    $img = [System.Drawing.Image]::FromFile($SrcPath)
    $ratio = [Math]::Min(1.0, $MaxWidth / $img.Width)
    $newW = [int]($img.Width * $ratio)
    $newH = [int]($img.Height * $ratio)
    $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($img, 0, 0, $newW, $newH)
    $g.Dispose()
    $enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)
    $bmp.Save($DstPath, $enc, $ep)
    $bmp.Dispose()
    $img.Dispose()
    Write-Host ("OK  {0}  ->  {1}" -f (Split-Path $SrcPath -Leaf), (Split-Path $DstPath -Leaf))
}

$jobs = @(
    @{ in = "hero-chrono-surge_1791898190750_ad990d0f.png"; out = "hero-chrono-surge.jpg"; w = 1792; q = 85 },
    @{ in = "tournament-arena_1791898287414_85482c2d.png";  out = "tournament-arena.jpg";   w = 1792; q = 82 },
    @{ in = "arcade-neon_1791898300415_4d2d399e.png";        out = "arcade-neon.jpg";        w = 1400; q = 82 },
    @{ in = "about-team-stage_1791898313004_0fe7bdf4.png";   out = "about-team-stage.jpg";   w = 1400; q = 82 },
    @{ in = "game-syndicate-wars_1791898202535_e7d8459f.png"; out = "game-syndicate-wars-2099.jpg"; w = 1024; q = 82 },
    @{ in = "game-astral-revenant_1791898217686_afe44fec.png"; out = "game-astral-revenant.jpg"; w = 1024; q = 82 },
    @{ in = "game-quantum-drift_1791898231869_646ff92a.png";  out = "game-quantum-drift.jpg"; w = 1024; q = 82 },
    @{ in = "game-nexus-legion_1791898243254_dc25304b.png";   out = "game-nexus-legion-reforged.jpg"; w = 1024; q = 82 },
    @{ in = "game-hypersteel-mecha_1791898262238_62f690d7.png"; out = "game-hypersteel-mecha-combat.jpg"; w = 1024; q = 82 },
    @{ in = "game-hexa-blade_1791898275469_d0fe0974.png";     out = "game-hexa-blade.jpg";    w = 1024; q = 82 },
    @{ in = "avatar-vort3x_1791898329399_cd6f4034.png";       out = "avatar-vort3x.jpg";      w = 256;  q = 85 },
    @{ in = "avatar-valkyrie_1791898343668_a500d4ef.png";     out = "avatar-valkyrie.jpg";    w = 256;  q = 85 },
    @{ in = "avatar-shadowkiller_1791898355091_db266803.png"; out = "avatar-shadowkiller.jpg"; w = 256; q = 85 }
)

foreach ($j in $jobs) {
    Convert-Image -SrcPath (Join-Path $srcDir $j.in) -DstPath (Join-Path $dstDir $j.out) -MaxWidth $j.w -Quality $j.q
}

Write-Host "DONE"
Get-ChildItem $dstDir | Select-Object Name, @{N = 'KB'; E = { [math]::Round($_.Length / 1KB) } } | Format-Table -AutoSize
