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

Write-Host "Bezig met downloaden van YouTube..."
yt-dlp -f "mp4" -o "%(playlist_index)s.%(ext)s" "https://youtube.com/playlist?list=PLsirpUvJXKA60orwh-ygOoq_mV3HnJAWn"

for ($i = 0; $i -lt $sketches.Count; $i++) {
    $index = $i + 2
    $artist = $sketches[$i].Artist
    $title = $sketches[$i].Title
    Write-Host "Bewerken van video $index: $artist"
    ffmpeg -i "$index.mp4" -vf "drawtext=text='$artist':x=60:y=60:$fontSettings,drawtext=text='$title':x=w-tw-60:y=60:$fontSettings,drawtext=text='$footerText':x=(w-tw)/2:y=h-80:$fontSettings" -c:v libx264 -crf 23 -c:a copy "processed_$index.mp4"
}

"file '1.mp4'" > concat_list.txt
for ($i = 2; $i -le 9; $i++) { "file 'processed_$i.mp4'" >> concat_list.txt }
ffmpeg -f concat -safe 0 -i concat_list.txt -c copy "Desselgem_Master_Show.mp4"
