param(
    [Parameter(Mandatory=$true)]
    [string]$inputImage,

    [Parameter(Mandatory=$true)]
    [int]$size,

    [Parameter(Mandatory=$true)]
    [string]$outputDir,

    [Parameter(Mandatory=$true)]
    [string]$outputGif = "zoom_loop.gif",

    [Parameter(Mandatory=$true)]
    [int]$frameCount = 60,

    [Parameter(Mandatory=$true)]
    [double]$zoomFactor = 1.02,

    [Parameter(Mandatory=$true)]
    [int]$targetSize = 1000
)

# Parameters
#$inputImage = "centered_image.jpg"       # Your input image
#$outputDir = "frames"
#$frameCount = 60                         # Total frames (30 in, 30 out)
#$outputGif = "zoom_loop.gif"
#$size = 6874                             # Output size (same as original)
#$zoomFactor = 1.02                       # Per-frame zoom step

# Create output directory
if (Test-Path $outputDir) {
    Write-Error "Directory '$outputDir' already exists. Exiting script."
    exit 1
}
#if (Test-Path $outputDir) { Remove-Item $outputDir -Recurse -Force }
New-Item -ItemType Directory -Path $outputDir | Out-Null

# Generate zoom-in frames
for ($i = 0; $i -lt $frameCount; $i++) {
    $scale = [math]::Pow([double]$zoomFactor, $i)
    $cropSize = [math]::Floor($size / $scale)   # Smaller crop size as zoom increases
    $offset = [math]::Floor(($size - $cropSize) / 2)  # Center the crop

    $frameName = "{0}\frame_{1:D3}.jpg" -f $outputDir, $i

    Write-Host "Processing... scale=$scale, cropSize=$cropSize, offset=$offset, frameName=$frameName"

    # Crop and resize the zoomed portion
    magick $inputImage -crop "${cropSize}x${cropSize}+${offset}+${offset}" +repage `
                       -resize "${targetSize}x${targetSize}!" `
                       $frameName
}

# Generate zoom-in frames
#for ($i = 0; $i -lt $frameCount; $i++) {
#    $scale = [math]::Pow($zoomFactor, $i)
#    $newSize = [math]::Floor($size * $scale)
#    $frameName = "{0}\frame_{1:D3}.jpg" -f $outputDir, $i
#
#    Write-Host "Processing... scale=$scale, newSize=$newSize, frameName=$frameName"
#
#    magick $inputImage -resize "${newSize}x${newSize}!" `
#                       -gravity center -crop "${size}x${size}+0+0" +repage `
#                       -resize "${targetSize}x${targetSize}!" `
#                       $frameName
#}

# Generate zoom-out frames (reverse order)
#for ($i = ($frameCount / 2 - 1); $i -ge 0; $i--) {
#    $source = "{0}\frame_{1:D3}.jpg" -f $outputDir, $i
#    $target = "{0}\frame_{1:D3}.jpg" -f $outputDir, ($frameCount - 1 - $i)
#    Copy-Item $source $target
#}

# Generate looping GIF
magick -delay 4 -loop 0 "$outputDir\frame_*.jpg" "$outputDir\$outputGif"

# You can later do manual gif experiments from command-line with resizing to desired size: magick -delay 4 -loop 0 "frame_*.jpg" -resize 100x100 "loop7.gif"

Write-Host "GIF created: $outputGif"
