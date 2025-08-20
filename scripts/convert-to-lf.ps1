# PowerShell script to convert all TypeScript files to LF line endings
Write-Host "Converting all TypeScript and related files to LF line endings..." -ForegroundColor Green

# Function to convert file to LF
function Convert-ToLF {
    param([string]$FilePath)

    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content) {
            # Replace CRLF with LF
            $content = $content -replace "`r`n", "`n"
            # Replace CR with LF (just in case)
            $content = $content -replace "`r", "`n"
            # Write back with UTF8 encoding and LF endings
            [System.IO.File]::WriteAllText($FilePath, $content, [System.Text.UTF8Encoding]::new($false))
            Write-Host "Converted: $FilePath" -ForegroundColor Yellow
        }
    }
}

# Get all TypeScript and related files
$fileExtensions = @("*.ts", "*.tsx", "*.js", "*.jsx", "*.json", "*.md", "*.yml", "*.yaml")
$excludePaths = @("node_modules", "dist", ".git")

foreach ($extension in $fileExtensions) {
    Write-Host "Processing $extension files..." -ForegroundColor Cyan

    Get-ChildItem -Path . -Filter $extension -Recurse |
    Where-Object {
        $file = $_
        $exclude = $false
        foreach ($excludePath in $excludePaths) {
            if ($file.FullName -like "*\$excludePath\*") {
                $exclude = $true
                break
            }
        }
        -not $exclude
    } |
    ForEach-Object {
        Convert-ToLF -FilePath $_.FullName
    }
}

Write-Host "`nRunning Prettier to format all files..." -ForegroundColor Green

# Run prettier to format and ensure LF endings
try {
    & npx prettier --write "src/**/*.{ts,tsx,js,jsx,json}"
    & npx prettier --write "test/**/*.{ts,tsx,js,jsx,json}"
    & npx prettier --write "*.{ts,tsx,js,jsx,json,md}"
    Write-Host "Prettier formatting completed!" -ForegroundColor Green
} catch {
    Write-Host "Warning: Prettier formatting failed. Please run manually if needed." -ForegroundColor Yellow
}

Write-Host "`n✅ All files have been converted to LF line endings!" -ForegroundColor Green
