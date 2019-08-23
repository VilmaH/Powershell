##################################################
# 
# This sricpt checks a CSV-list for correct Finnish social security numbers.
# Tämä skripti tarkistaa annetun suomalaisen henkilötunnuksen oikeellisuuden CSV-tiedostosta.
#
# Vilma Hallikas 8/2019
#
##################################################

#Import a csv of social security numbers.
$hetucsv = Import-Csv "hetu.csv" -Encoding UTF8

#List of correct checkup characters
$takistusmerkki = @{
0 = '0'
1 = '1'
2 = '2'
3 = '3'
4 = '4'
5 = '5'
6 = '6'
7 = '7'
8 = '8'
9 = '9'
10 = 'A'
11 = 'B'
12 = 'C'
13 = 'D'
14 = 'E'
15 = 'F'
16 = 'H'
17 = 'J'
18 = 'K'
19 = 'L'
20 = 'M'
21 = 'N'
22 = 'P'
23 = 'R'
24 = 'S'
25 = 'T'
26 = 'U'
27 = 'V'
28 = 'W'
29 = 'X'
30 = 'Y'
}
$output = @()


foreach($hetu in $hetucsv){

    #Basic regex check
    if($hetu.hetu -match '^(0[1-9]|[1-2]\d|3[01])(0[1-9]|1[0-2])(\d\d)([-+A])(\d\d\d)([0-9A-FHJ-NPR-Y])$')
    {
        #Take the running number and it's modulo 31 and check against list of correct characters
        if($hetu.hetu.Substring(7,3) % 31 -match $tarkistusmerkki){
        }else{
            $output += $hetu
        }
    }else{
        $output += $hetu
    }
}
$output | export-csv "vaarahetu.csv" -Encoding UTF8 -NoClobber -NoTypeInformation