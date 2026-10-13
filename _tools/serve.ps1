# Minimal static HTTP server for local testing (no dependencies).
param(
    [int]$Port = 5500,
    [string]$Root = "C:\Users\abdul\Documents\Qoder\2026-10-13\d8c49fcb"
)

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "text/javascript; charset=utf-8"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".png"  = "image/png"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain; charset=utf-8"
}

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host "Serving $Root at http://localhost:$Port/"

while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
        $stream = $client.GetStream()
        $stream.ReadTimeout = 5000

        # Read raw bytes until end of HTTP headers
        $buffer = New-Object System.Collections.Generic.List[byte]
        $one = New-Object byte[] 1
        $headerEnd = $false
        $state = 0
        while (-not $headerEnd) {
            $n = $stream.Read($one, 0, 1)
            if ($n -le 0) { break }
            $buffer.Add($one[0])
            switch ($one[0]) {
                13 { if ($state -eq 0 -or $state -eq 2) { $state++ } else { $state = 0 } }   # CR
                10 { if ($state -eq 1) { $state = 2 } elseif ($state -eq 3) { $headerEnd = $true; $state = 0 } else { $state = 0 } } # LF
                default { $state = 0 }
            }
            if ($buffer.Count -gt 65536) { break }
        }

        $headerText = [System.Text.Encoding]::ASCII.GetString($buffer.ToArray())
        $requestLine = ($headerText -split "`r`n")[0]
        $parts = $requestLine -split " "
        $urlPath = if ($parts.Count -ge 2) { $parts[1] } else { "/" }
        $urlPath = ($urlPath -split "\?")[0]
        $urlPath = [System.Uri]::UnescapeDataString($urlPath)

        if ($urlPath -eq "/" -or $urlPath -eq "") { $urlPath = "/index.html" }

        $relative = $urlPath.TrimStart("/") -replace "/", "\"
        $filePath = Join-Path $Root $relative

        $status = "404 Not Found"
        $body = $null
        $contentType = "text/plain; charset=utf-8"

        if ((Test-Path -LiteralPath $filePath -PathType Leaf) -and ($filePath.StartsWith($Root))) {
            $body = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
            $status = "200 OK"
        } else {
            $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $urlPath")
        }

        $head = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nConnection: close`r`nCache-Control: no-store`r`n`r`n"
        $headBytes = [System.Text.Encoding]::ASCII.GetBytes($head)
        $stream.Write($headBytes, 0, $headBytes.Length)
        $stream.Write($body, 0, $body.Length)
        $stream.Flush()
    } catch {
        Write-Host "Request error: $_"
    } finally {
        $client.Close()
    }
}
