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

Write-Host "Stap 1: Downloaden van YouTube (Poging met omweg)..."
# We voegen extra parameters toe om minder op een bot te lijken
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" `
       --merge-output-format mp4 `
       --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" `
       --no-check-certificate `
       -o "%(playlist_index)s.mp4" "https://youtube.com/playlist?list=PLsirpUvJXKA60orwh-ygOoq_mV3HnJAWn"

Write-Host "Stap 2: Controleren of de bestanden er zijn..."
$files = Get-ChildItem *.mp4
if ($files.Count -eq 0) {
    Write-Error "YouTube blokkeert de download nog steeds. Probeer het script over 10 minuten nog eens of gebruik Plan B."
    exit 1
}

Write-Host "Stap 3: Bewerken..."
$concatList = "file '1.mp4'`n"
for ($i = 0; $i -lt $sketches.Count; $i++) {
    $index = $i + 2
    $inputFile = "$index.mp4"
    $outputFile = "processed_$index.mp4"
    if (Test-Path $inputFile) {
        $artist = $sketches[$i].Artist
        $title = $sketches[$i].Title
        ffmpeg -i $inputFile -vf "drawtext=text='$artist':x=60:y=60:$fontSettings,drawtext=text='$title':x=w-tw-60:y=60:$fontSettings,drawtext=text='$footerText':x=(w-tw)/2:y=h-80:$fontSettings" -c:v libx264 -crf 23 -c:a copy $outputFile
        $concatList += "file '$outputFile'`n"
    }
}

Write-Host "Stap 4: Samenvoegen..."
$concatList | Out-File -FilePath concat_list.txt -Encoding ascii
ffmpeg -f concat -safe 0 -i concat_list.txt -c copy "Desselgem_Master_Show.mp4"
