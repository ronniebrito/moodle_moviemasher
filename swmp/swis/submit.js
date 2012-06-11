function OnSubmitForm() {
  if(document.pressed == 'sym') {
    document.bswform.action ="image_sym.php";
  } else if(document.pressed == 'sign') {
    document.bswform.action ="image_sign.php";
  } else if(document.pressed == 'col') {
    document.bswform.action ="image_col.php";
  } else if(document.pressed == 'signtext') {
    document.bswform.action ="signtext.php";
  } else if(document.pressed == 'format') {
    document.bswform.action ="format.php";
  }
  return true;
}
