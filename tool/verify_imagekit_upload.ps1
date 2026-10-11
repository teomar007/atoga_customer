# verify_imagekit_upload.ps1
#
# End-to-end check for the ImageKit upload flow:
#   1) Sign in as an active staff member (super_admin / manager / marketer).
#   2) Request an upload signature from the `imagekit-auth` Edge Function.
#   3) Upload a sample image straight to ImageKit.
#   4) Save the CDN URL (with transformations) into products, read it back.
#   5) Delete the test row.
#
# Requirements:
#   - Secret IMAGEKIT_PRIVATE_KEY set in Supabase -> Edge Functions -> Secrets.
#   - An active staff account on the same project.
#
# Example:
#   .\tool\verify_imagekit_upload.ps1 -Email admin@example.com -Password 'secret' -ImagePath .\sample.jpg

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Email,
  [Parameter(Mandatory = $true)][string]$Password,
  [Parameter(Mandatory = $true)][string]$ImagePath,
  [string]$ProductId
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath $ImagePath)) { throw "Image not found: $ImagePath" }
if (-not $ProductId) { $ProductId = 'imagekit-test-' + (Get-Date -Format 'yyyyMMddHHmmss') }

# Publish/anon key: from the environment, else parsed from the app config (not duplicated).
function Get-AnonKey {
  if ($env:SUPABASE_ANON_KEY) { return $env:SUPABASE_ANON_KEY }
  $config = Join-Path $root 'lib\core\config\supabase_config.dart'
  $match = Select-String -LiteralPath $config -Pattern "defaultValue:\s*'((?:eyJ|sb_publishable_)[^']+)'" | Select-Object -First 1
  if (-not $match) { throw 'Could not read anon key; set $env:SUPABASE_ANON_KEY' }
  return $match.Matches[0].Groups[1].Value
}

$base = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { 'https://qwiaxkrwyhdjrucnknhm.supabase.co' }
$anon = Get-AnonKey
$tr = 'w-800,f-webp,q-80'

Write-Host '1) Staff sign-in...' -ForegroundColor Cyan
try {
  $tokenResp = Invoke-RestMethod -Method Post -Uri "$base/auth/v1/token?grant_type=password" `
    -Headers @{ apikey = $anon; 'Content-Type' = 'application/json' } `
    -Body (@{ email = $Email; password = $Password } | ConvertTo-Json)
} catch {
  throw "Sign-in failed: $($_.ErrorDetails.Message)"
}
$access = $tokenResp.access_token
if (-not $access) { throw 'Sign-in failed (check email/password).' }

Write-Host '2) Requesting ImageKit token from Edge Function...' -ForegroundColor Cyan
try {
  $auth = Invoke-RestMethod -Method Post -Uri "$base/functions/v1/imagekit-auth" `
    -Headers @{ apikey = $anon; Authorization = "Bearer $access"; 'Content-Type' = 'application/json' } `
    -Body '{}'
} catch {
  $detail = $_.ErrorDetails.Message
  if ($detail -match 'imagekit_not_configured') {
    throw 'Secret IMAGEKIT_PRIVATE_KEY is not set (Supabase -> Edge Functions -> Secrets).'
  }
  throw "imagekit-auth call failed: $detail"
}

Write-Host '3) Uploading image to ImageKit...' -ForegroundColor Cyan
$uploadJson = & curl.exe -s -X POST 'https://upload.imagekit.io/api/v1/files/upload' `
  -F "file=@$ImagePath" `
  -F "publicKey=$($auth.publicKey)" `
  -F "signature=$($auth.signature)" `
  -F "token=$($auth.token)" `
  -F "expire=$($auth.expire)" `
  -F "fileName=$ProductId.jpg" `
  -F 'folder=/verification' `
  -F 'useUniqueFileName=false'
$upload = $uploadJson | ConvertFrom-Json
if (-not $upload.url) { throw "ImageKit upload failed: $uploadJson" }
$finalUrl = "$($upload.url)?tr=$tr"

Write-Host '4) Saving URL into products...' -ForegroundColor Cyan
$dataHeaders = @{
  apikey         = $anon
  Authorization  = "Bearer $access"
  'Content-Type' = 'application/json'
  Prefer         = 'resolution=merge-duplicates,return=representation'
}
$row = @{ id = $ProductId; name = 'ImageKit Verification'; price = 1; image_url = $finalUrl; is_active = $false } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "$base/rest/v1/products" -Headers $dataHeaders -Body $row | Out-Null

$saved = Invoke-RestMethod -Method Get -Uri "$base/rest/v1/products?id=eq.$ProductId&select=id,image_url" `
  -Headers @{ apikey = $anon; Authorization = "Bearer $access" }
$ok = ($saved.image_url -eq $finalUrl)

Write-Host '5) Cleaning up test row...' -ForegroundColor Cyan
Invoke-RestMethod -Method Delete -Uri "$base/rest/v1/products?id=eq.$ProductId" `
  -Headers @{ apikey = $anon; Authorization = "Bearer $access" } | Out-Null

if ($ok) {
  Write-Host "`nPASS: image uploaded and ImageKit URL persisted:" -ForegroundColor Green
  Write-Host "  $finalUrl"
} else {
  Write-Host "`nFAIL: saved URL does not match the expected value." -ForegroundColor Red
  Write-Host "  expected: $finalUrl"
  Write-Host "  saved:    $($saved.image_url)"
  exit 1
}
