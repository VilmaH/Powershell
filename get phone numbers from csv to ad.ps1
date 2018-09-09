$data = import-csv .\puhelinluettelo.csv -delimiter ";" -encoding UTF8

foreach ($user in $data) {
$nimi = "$($user.etunimi)" + " " + "$($user.sukunimi)"

get-aduser -filter * | ? {$_.Name -eq $nimi} | set-aduser -mobilephone $user.puhelin

}