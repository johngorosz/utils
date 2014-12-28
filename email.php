#!/usr/bin/php -q
<?php
// read from stdin
$fd = fopen("php://stdin", "r") or die("can't open stdin");
$email = "";
//$outfile = exec( mktemp --tmpdir=/home1/johngoro/utils );
$outfile = "tmpemail";

$gas_2_num = "12059710165";
$elec_1_num = "20400221048";
$gas_1_num = "12059700133";
$elec_2_num = "20400211098";
$elec_3_num = "29128390019";

$debug = 0;
if ($debug) echo "begin parse\n";

// read each line
while (!feof($fd)) {
    $line = fread($fd, 4096);
    $email .= $line;


    // figure out file name
    if (strpos($line,$gas_1_num) !== false) {
        $outfile = "gas_1";
        if ($debug) echo "file $outfile\n";
    } elseif (strpos($line,$gas_2_num) !== false) {
        $outfile = "gas_2";
        if ($debug) echo "file $outfile\n";
    } elseif (strpos($line,$elec_1_num) !== false) {
        $outfile = "electric_1";
        if ($debug) echo "file $outfile\n";
    } elseif (strpos($line,$elec_2_num) !== false) {
        $outfile = "electric_2";
        if ($debug) echo "file $outfile\n";
    } elseif (strpos($line,$elec_3_num) !== false) {
        $outfile = "electric_3";
        if ($debug) echo "file $outfile\n";
    } else {
        if ($debug) {echo "no match for:\n"; echo "$line\n";}
    }
}

// open file for output
$fh = fopen($outfile, 'w') or die("can't open file");
fwrite($fh, $email);

fclose($fh);
fclose($fd);

// 
?>
