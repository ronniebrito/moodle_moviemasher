<?php
echo '<TABLE BORDER CELLPADDING=3>';
echo '<tr><th colspan=5>';
echo $msg['swis_data'];
echo '</th></tr>';
echo '<tr><td colspan=5>';
echo '<textarea id="input" name="bsw" cols="60" rows="10">' . $bsw . '</textarea>';
echo '</td></tr>' . "\n";
echo '<tr>' . "\n";

echo '<td align=middle><INPUT TYPE=SUBMIT name="sym" onClick="document.pressed=this.name" VALUE="' . $msg['swis_syms'] . '"></td>' . "\n";
echo '<td align=middle><INPUT TYPE=SUBMIT name="sign" onClick="document.pressed=this.name" VALUE="' . $msg['swis_signs'] . '"></td>' . "\n";
echo '<td align=middle><INPUT TYPE=SUBMIT name="col" onClick="document.pressed=this.name" VALUE="' . $msg['swis_cols'] . '"></td>' . "\n";
echo '<td align=middle><INPUT TYPE=SUBMIT name="signtext" onClick="document.pressed=this.name" VALUE="' . $msg['swis_signtext'] . '"></td>' . "\n";
echo '<td align=middle><INPUT TYPE=SUBMIT name="format" onClick="document.pressed=this.name" VALUE="' . $msg['swis_format'] . '"></td>' . "\n";
echo '</tr></table>' . "\n";
?>
