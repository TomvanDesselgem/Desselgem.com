$fontSettings = "fontsize=34:fontcolor=white:borderw=2:bordercolor=black"
$footerText = "Desselgem.com"

$sketches = @(
    @{Artist="Piv Huvluv"; Title="Desselgem Koerse"},
    @{Artist="Hans Cools"; Title="Wielertoeristen"},
    @{Artist="Joost Van Hyfte"; Title="Guust ontmoet een Hollander"},
    @{Artist="Moshin Abbas"; Title="Nachtwinkel"},
    @{Artist="David Galle"; Title="Tom Pekkers, de opgesloten caféganger"},
    @{Artist="Karel Declercq"; Title="De radeloze regenworm"},
    @{Artist="Ronald Van Rillaer"; Title="De mannen van 't Zuid"},
    @{Artist="Jeroen Maes"; Title="Controle"}
)

Write-Host "Stap 1: Downloaden van YouTube..."
# We dwingen MP4 af om compatibiliteitsproblemen te voorkomen
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" --merge-output-format mp4 -o "%(playlist_index)s.mp4" "https://youtube.com/playlist?list=PLsirpUvJXKA60orwh-ygOoq_mV3HnJAWn"

Write-Host "Stap 2: Bewerken van video's..."
# We maken de lijst voor het samenvoegen. De intro (1.mp4) moet er al zijn.
$concatList = "file '1.mp4'`n"

for ($i = 0; $i -lt $sketches.Count; $i++) {
    $index = $i + 2
    $inputFile = "$index.mp4"
    $outputFile = "processed_$index.mp4"
    
    if (Test-Path $inputFile) {
        $artist = $sketches[$i].Artist
        $title = $sketches[$i].Title
        Write-Host "Bewerken: $artist - $title"
        # We voegen de teksten toe en zorgen dat de video-indeling hetzelfde blijft
        ffmpeg -i $inputFile -vf "drawtext=text='$artist':x=60:y=60:$fontSettings,drawtext=text='$title':x=w-tw-60:y=60:$fontSettings,drawtext=text='$footerText':x=(w-tw)/2:y=h-80:$fontSettings" -c:v libx264 -crf 23 -c:a copy $outputFile
        $concatList += "file '$outputFile'`n"
    } else {
        Write-Host "Oeps: $inputFile niet gevonden. Is de download gelukt?"
    }
}

Write-Host "Stap 3: Alles aan elkaar plakken..."
$concatList | Out-File -FilePath concat_list.txt -Encoding ascii
ffmpeg -f concat -safe 0 -i concat_list.txt -c copy "Desselgem_Master_Show.mp4"
Write-Host "Klaar!"
