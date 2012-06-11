<?php
$i=0;

//about
$icons[$i]['page'] = 'index.php';
$icons[$i]['txt'] = $msg['swis_about'];
$icons[$i]['method'] = 'post';
$i++;

//ISWA
$icons[$i]['page'] = 'iswa';
$icons[$i]['txt'] = $msg['swis_iswa'];
$icons[$i]['method'] = '';
$i++;

//BSW
$icons[$i]['page'] = 'bswref.html';
$icons[$i]['txt'] = $msg['iswa_bsw'];
$icons[$i]['method'] = 'get';
$i++;

//Format
$icons[$i]['page'] = 'format.php';
$icons[$i]['txt'] = $msg['swis_format'];
$icons[$i]['method'] = 'post';
$i++;

//SignMaker
$icons[$i]['page'] = 'signmaker.php';
$icons[$i]['txt'] = $msg['swis_signmaker'];
$icons[$i]['method'] = 'post';
$i++;

//SignText
$icons[$i]['page'] = 'signtext.php';
$icons[$i]['txt'] = $msg['swis_signtext'];
$icons[$i]['method'] = 'post';
$i++;

//Symbols
$icons[$i]['page'] = 'image_sym.php';
$icons[$i]['txt'] = $msg['swis_syms'];
$icons[$i]['method'] = 'post';
$i++;

//Signs
$icons[$i]['page'] = 'image_sign.php';
$icons[$i]['txt'] = $msg['swis_signs'];
$icons[$i]['method'] = 'post';
$i++;

//Columns
$icons[$i]['page'] = 'image_col.php';
$icons[$i]['txt'] = $msg['swis_cols'];
$icons[$i]['method'] = 'post';
$i++;

//SignPuddle Online
$icons[$i]['page'] = 'http://www.signpuddle.org';
$icons[$i]['txt'] = $msg['swis_sponline'];
$icons[$i]['method'] = '';
$i++;

//Lessons Online
$icons[$i]['page'] = 'http://www.signwriting.org/lessons/';
$icons[$i]['txt'] = $msg['swis_lessons'];
$icons[$i]['method'] = 'post';
$i++;

//output top level icons
//echo "<table rules=cols frame=void width=100% cellpadding=6 border=1><tr><th valign=top align=middle width=150>";
echo '<div id="command" class="command">';
echo '<center>';
echo '<img src="media/logo.png" alt="Open SignPuddle logo" border=0>';
echo '<br><br>';
  foreach ($icons as $value) {
    echo '<form method="' . $value['method'] . '" action="' . $value['page'] . '">';
    if ($value['method']) echo '<input type="hidden" name="bsw" value="' . $bsw .'">';
    echo '<button class="cmd" type="submit">';
    echo $value['txt'];
    echo '</button>';
    echo "</form>";
  }
//echo '</th></tr></table>';
echo '</center></div>';
?>
