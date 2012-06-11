/**
 * Binary SignWriting HTML Reference javascript library
 * 
 * Copyright 2007-2010 Stephen E Slevinski Jr
 * Steve (Slevin@signpuddle.net)
 * 
 * This file is part of SWIS: the SignWriting Image Server.
 * 
 * SWIS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * SWIS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SWIS.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * END Copyright
 *  
 * @copyright 2007-2010 Stephen E Slevinski Jr 
 * @author Steve (slevin@signpuddle.net)  
 * @license http://www.opensource.org/licenses/gpl-3.0.html GPL
 * @access public
 * @package SWIS
 * @version 1.2.0
 * @filesource
 *   
 */

function LoadQuery(){
  fullURL = parent.document.URL;
  querystr = window.location.search;
  if (querystr.length != fullURL.length){
    var args = parseQueryString(querystr,true);
    if (args.bsw) {
      $('input').value = args.bsw;
      $('encoding').value='bsw';
      AnalyzeInput();
    }
    if (args.utf){
      $('input').value = args.utf;
      $('encoding').value='utf';
      AnalyzeInput();
    }
    CheckHash(); //will fire LoadHash for the first time.
  }
}

var hashmark_last = '';
function CheckHash(){
  hashmark = window.location.hash;
  hashmark = hashmark.replace('#','');
  if (hashmark != hashmark_last){
    LoadHash(hashmark);
  }
  callLater(1,CheckHash);
}

function SetHash(hashmark){
  window.location.hash = hashmark;
  hashmark_last = hashmark.replace('#','');//ensure no # for empty hash
//  hashmark = hashmark.replace('#','');
//  if (hashmark != hashmark_last){
//   LoadHash(hashmark);
//  }
//  callLater(1,CheckHash);
}

function LoadHash(hashmark){
  var section = hashmark[0];
  var iLen = hashmark.length;
  var iPer = hashmark.indexOf('.');
  if (iPer>0){
    var page_num = hashmark.slice(1,iPer);
    var sign_num = hashmark.slice(iPer+1,iLen);
  } else {
    var page_num = hashmark.slice(1,iLen);
    var sign_num = '';
  }
  switch(section){
    case "v":
      ViewOutput();
      break;
    case "d":
      DetailOutput();
      break;
    case "s":
      SortOutput();
      break;
    case "i":
      IndexOutput();
      break;
    case "f":
      FrequencyOutput();
      break;
    case "m":
      FormatOutput();
      break;
  }
//  if (page_num) alert ("page " + page_num);
//  if (sign_num) alert ("sign " + sign_num);
  hashmark_last = hashmark;
}

function UpdatePage(){
  hashmark=(this.page);
  window.location.replace('#' + (this.page));  
  $("Page_Num").innerHTML = "Page " + (this.page) + " of " + pages.length;
}

function AnalyzeInput(){
  var encoding = $('encoding').value;
  var bsw = '';
  var utf = '';
  var out = '';
  if (encoding=='bsw'){
    bsw = $('input').value;
  } else {
    utf = $('input').value;
    utf = utf.replace(/\s+/g, '');
    if(utf) {
      bsw = utf2bsw(utf);
    }
  }

  if (bsw ==""){
    out += "<h1>Hello world.</h1>";
    bsw = hello + " " + hello_seq + " " + world + " " + world_seq + " " + period;//from bsw.js
    $('input').value = bsw;
    $('encoding').value='bsw';
  }
  bsw = bsw.replace(/\s+/g, '');
  return bsw;
}

function GridOutput(title,grid,bsw){
//check for sign data
  var out = '';
  if (bsw){
    if (validBSW(bsw)){
      sign = new Sign(bsw);
      col = new Column(sign.h);
      col.add(sign);
      col.setup();
      col.display();
      var signDiv = createDOM(col.div);
      var signHTML =  '<table width=' + (10+col.w) + ' height=' + (20+col.h) + '><tr><td valign=top>';
      signHTML += '<div class="column">' + signDiv.innerHTML + '</div>';
      signHTML += '</td></tr></table>';
    } else {
      signHTML = bsw;
    }
  }

  out += '<h2>' + title + '</h2>';
  out += "<div><table cellpadding=5 border=1>";
  if (signHTML){
    oBSW = '<tr><td rowspan=4>' + signHTML + '</td><th>BSW</th>';
  } else {
    oBSW = "<tr><th>BSW</th>";
  }
  oUTF = "<tr><th>UTF-8</th>";
  oToken = "<tr><th>Token</th>";
  oValue = "<tr><th>Value</th>";
  var last_token='';
  var this_token='';
  for (var i=0; i<grid.length; i++) {
    row = grid[i];
    this_token = row[2];
    oBSW += "<td>" + row[0] + "</td>";
    oUTF += "<td>" + row[1] + "</td>";
    oToken += "<td>" + row[2] + "</td>";
    if(this_token=="n" && last_token!="n"){
      oValue += '<td colspan=2>(' + row[3] + ',' + grid[i+1][3] + ')</td>';
    } else if(this_token=="n" && last_token =="n"){
//      oValue += '';
    } else {
      oValue += '<td>' + row[3] + '</td>';
    }
    last_token = this_token
  }
  oBSW += "</tr>";
  oUTF += "</tr>";
  oToken += "</tr>";
  oValue += "</tr>";
  out += oBSW + oUTF + oToken + oValue + "</table></div>";
  return out;
}


function ViewOutput(){
//get data
  bsw = AnalyzeInput();

//reject invalid
  if (!validBSW(bsw)){
    $('output').innerHTML = '<h2>Invalid Binary SignWriting</h2>';
    return;
  }
  $('output').innerHTML = "loading";
  imgChecker.check(bsw);
  callLater(.1,ViewBSW,bsw);
}

function ViewBSW(bsw){
  if (imgChecker.loading()){
    $('output').innerHTML = "loading...";
    callLater(.1,ViewBSW,bsw);
    return;
  }
  $('output').innerHTML = "generating display";
  //getViewportDimensions returns w and h for visible screen.
  units = bsw2unit(bsw);
  var signs = new Array();//includes punc
  forEach(units,function (unit) {signs.push(new Sign(unit))});
  //now on to the columns
  cols = new Array();
  signs.reverse();
  var cPunc = 0;
  var cSign = 0;
  while (signs.length){
    col = new Column(500);
    sign = signs.pop();
    col.add(sign);
    sign = signs.pop();
    while(sign){
      var cur = (isPunc(sign.data)) ? "punc" : "sign";
      sign = col.add(sign);
      if (sign){//rejected due to height
        signs.push(sign);
        sign = null;
      } else {
        switch (cur){
          case "sign":
            cSign++;
            break;
          case "punc":
            cPunc++;
            cSign=0
            break;
        }
        sign = signs.pop();
      }
    }
    col.setup();
    col.display();
    cols.push(col);
  }

  $('output').innerHTML = "all set up";
  //add style for even and odd columns, first and last
  for (var i=0; i<cols.length; i++) {
    var col = cols[i];
    if (i % 2) {
      addElementClass(col.div, "even")
    } else {
      addElementClass(col.div, "odd")
    }
    if (i == 0) {
      addElementClass(col.div, "first")
    }
    if (i == cols.length-1) {
      addElementClass(col.div, "last")
    }
  }

  // add connections for cursor click
//  for (var i=0; i<cols.length; i++) {
//    var col = cols[i];
//    connect(col.div, 'onclick', col, 'wasClicked');
//  }

  $('output').innerHTML = '<a id="v"></a>';
  SetHash("v");
  for (var i=0; i<cols.length; i++) {
    var col = cols[i];
    appendChildNodes("output",col.div);
  }
}

function DetailOutput(hash){
//get data
  bsw = AnalyzeInput();

//reject invalid
  if (!validBSW(bsw)){
    $('output').innerHTML = '<h2>Invalid Binary SignWriting</h2>';
    return;
  }

//get sort and index
  var signs = bsw2signs(bsw);
  var sort_keys = signs2sort(signs);
  var index_keys = signs2index(signs);

  var out = '<h1 id="d">Detail</h1>';


//this is for unit (sign or punc) detail
  var sCnt = 0;
  var pCnt = 0;
  var spCnt = 0;
  bsw_units = bsw2unit(bsw);
  var row = new Array();
  var grid = new Array();
  var code = 0; //tmp code value checking
  var token = 'X';//tmp token value checking
  var first_char='';
  var base_code = 0;
  for (var i=0; i<bsw_units.length; i++) {
    data = bsw_units[i];
    var bswSign = data; //used for grid sign
    grid = new Array();
    dataAr = data.chunk(3)
    first_char = dataAr[0]
    if (isPunc(first_char)){
      pCnt++;
      spCnt=0;
      if (validBSW(data)){
        out += "<h2>Punctuation " + pCnt + "</h2>";
      } else {
        title = "Invalid BSW";
      }
      row = new Array();
      base_link = '<a target="_blank" href="iswa/' + first_char + '/' + first_char + '_bs.html">';
      row.push(base_link + first_char +'</a>');
      row.push(bsw2utf(first_char));
      row.push(bsw2token(first_char));
      code = hexdec(first_char);
      row.push(base_link + '<img border=0 src="' + imgSrc(first_char) + '"></a>');
      grid.push(row);
      //now add fill and rot
      row = new Array();
      fill = dataAr[1];
      row.push(fill);
      row.push(bsw2utf(fill));
      row.push(bsw2token(fill));
//      row.push(hexdec(fill));
      row.push("fill " + (hexdec(char2fill(fill))+1));
      grid.push(row);
      //now add fill and rot
      row = new Array();
      rot = dataAr[2];
      row.push(rot);
      row.push(bsw2utf(rot));
      row.push(bsw2token(rot));
//      row.push(hexdec(rot));
      row.push("rotation " + (hexdec(char2rot(rot))+1));
      grid.push(row);
    

    } else {
      sCnt++;
      spCnt++;
      out += '<h2 id="d1.' + sCnt + '">Detail Sign ' + sCnt + '</h2>';
      if (pCnt){
        out += "<h3>Sign " + spCnt + " after Punctuation " + pCnt + "</h3>";
      }
      row = new Array();
      switch (bsw2token(first_char)){
        case "L":
          title = "Left Lane Sign";
          break;
        case "R":
          title = "Right Lane Sign";
          break;
        default:
          title = "Sign";
      }

      cluster = bsw2cluster(data);
      if (cluster){
        bswSign = first_char + cluster;
        syms = cluster.chunk(3);
        cnt = syms.length/5;
        title += ", " + cnt + " symbol";
        if (cnt>1) title += "s";
        title += " in Cluster";
      } else {
        title += " no symbols ";
      }
      seq = bsw2seq(data);
      if (seq){
        sort = seq.chunk(3)
        cnt = sort.length/3;
        title += ", " + cnt + " symbol";
        if (cnt>1) title += "s";
        title += " in Sequence";
      }
 
      if (!validBSW(data)){
        title = "Invalid BSW";
      }

      chars = data.chunk(3);
      for (var j=0; j<chars.length; j++) {
        char = chars[j];
        base_link = '<a target="_blank" href="iswa/' + char + '/' + char + '_bs.html">';
        code = hexdec(char);
        row = new Array();
        if (isISWA(char)){
          row.push(base_link + char + '</a>');
        } else {
          row.push(char);
        }
        row.push(bsw2utf(char));
        row.push(bsw2token(char));
        if (isISWA(char)){
          row.push(base_link + '<img border=0 src="' + imgSrc(char) + '"></a>');
        } else if(isNum(char)) {
          row.push(hex2num(char));
        } else if(isFill(char)) {
          row.push("fill " + (hexdec(char2fill(char))+1));
        } else if(isRot(char)) {
          row.push("rotation " + (hexdec(char2rot(char))+1));
        } else {//
          token = bsw2token(char);
          switch(token){
            case "B":
              row.push("middle<br>lane");
              break;
            case "L":
              row.push("left<br>lane");
              break;
            case "R":
              row.push("right<br>lane");
              break;
            case "Q":
              row.push("sequence");
              break;
            default:
              row.push("invalid control");
          }
        }
        grid.push(row);
      }
    }
    title="";
    out += GridOutput(title,grid,bswSign);
    if (isPunc(first_char)){
      out += '<br><hr>';
    } else {
      skey = sort_keys.indexOf(sCnt-1);
      out += '<a href="" onclick="SortOutput(\'s1.' + (1+skey) + '\');return false;">';
      out += 'Sort sign ' + (1+skey) + '</a>, ';
      ikey = index_keys.indexOf(sCnt-1);
      out += '<a href="" onclick="IndexOutput(\'i1.' + (1+ikey) + '\');return false;">';
      out += 'Index sign ' + (1+ikey) + '</a><br><br><hr>';
    }
  }
  $('output').innerHTML = out;
  if (hash) {
    SetHash(hash);
  } else {
    SetHash("d");
  }
}

function SortOutput(hash){
//get data
  bsw = AnalyzeInput();

//reject invalid
  if (!validBSW(bsw)){
    $('output').innerHTML = '<h2>Invalid Binary SignWriting</h2>';
    return;
  }

  var signs = bsw2signs(bsw);
  var sort_keys = signs2sort(signs);
  var cnt=0;
  var out = '';
  if (sort_keys.length){
    out = '<h1 id="s">Sort</h1>';
    out += '<h2>SignSpelling Sequence</h2>';
    //sort sequence
    for (var i = 0; i < sort_keys.length; i++) {
      ikey = sort_keys[i];
      seq = bsw2seq(signs[ikey]);
      cluster = signs[ikey];
      if (!seq){
        seq = cluster2seq(cluster);
      }
      var grid_seq = new Array();
      var rowSeq = new Array();
      chunks = seq.chunk(9);
      for(var j=0;j<chunks.length;j++){

        rowSeq = new Array();
        chars = chunks[j];
        first_char = chars.slice(0,3);
        base_link = '<a target="_blank" href="iswa/' + first_char + '/' + first_char + '_bs.html">';
        rowSeq.push(base_link + chars +'</a>');
        rowSeq.push(bsw2utf(chars));
        rowSeq.push(bsw2token(chars));
        rowSeq.push(base_link + '<img border=0 src="' + imgSrc(chars) + '"></a>');
        grid_seq.push(rowSeq);
      }
      out += GridOutput('<h2 id="s1.' + (1+i) + '">Sort Sign ' + (1+i) + '</h2>',grid_seq,cluster);
      out += '<a href="" onclick="DetailOutput(\'d1.' + (1+ikey) + '\');return false;">';
      out += 'Detail sign ' + (1+ikey) + '</a><br><br><hr>';
    }
  }
  if (out==''){
    out = "No signs to sort";
  }
  $('output').innerHTML = out;
  if (hash) {
    SetHash(hash);
  } else {
    SetHash("s");
  }
}

function IndexOutput(hash){
//get data
  bsw = AnalyzeInput();

//reject invalid
  if (!validBSW(bsw)){
    $('output').innerHTML = '<h2>Invalid Binary SignWriting</h2>';
    return;
  }

  var signs = bsw2signs(bsw);
  var index_keys = signs2index(signs);
  var cnt=0;
  var out = '';
  if (index_keys.length){
    out = '<h1 id="i">Index</h1>';
    out += "<h2>Sorted by BaseSymbol</h2>";
    for (var i = 0; i < index_keys.length; i++) {
      ikey = index_keys[i];
      bsw_sign = signs[ikey];
      base = bsw2base(bsw2cluster(bsw_sign));
      var grid_base = new Array();
      var rowBase = new Array();
      chunks = base.chunk(3);
      for(var j=0;j<chunks.length;j++){
        rowBase = new Array();
        first_char = chunks[j];
        base_link = '<a target="_blank" href="iswa/' + first_char + '/' + first_char + '_bs.html">';
        rowBase.push(base_link + first_char +'</a>');
        rowBase.push(bsw2utf(first_char));
        rowBase.push(bsw2token(first_char));
        rowBase.push(base_link + '<img border=0 src="' + imgSrc(first_char) + '"></a>');
        grid_base.push(rowBase);
      }
      cnt++;
      out += GridOutput('<h2 id="i1.' + cnt + '">Index Sign ' + cnt,grid_base,bsw_sign);
      out += '<a href="" onclick="DetailOutput(\'d1.' + (1+ikey) + '\');return false;">';
      out += 'Detail sign ' + (1+ikey) + '</a><br><br><hr>';
    }
  }

  if (out==''){
    out = 'No signs to index';
  }
  $('output').innerHTML = out;
  if (hash) {
    SetHash(hash);
  } else {
    SetHash("i");
  }
}

/**
 * Frequency Output
 */
function FrequencyOutput(){
//get data
  bsw = AnalyzeInput();

//reject invalid
  if (!validBSW(bsw)){
    $('output').innerHTML = '<h2>Invalid Binary SignWriting</h2>';
    return;
  }

  var out = '<h1 id="f">BaseSymbol Frequency for All Signs</h1>';

//setup base_chars array
  var base_bsw = bsw2base(bsw);
  if (base_bsw=="") {
    $('output').innerHTML = '<h2>No BaseSymbols</h2>';
    return;
  }
  var syms = base_bsw.chunk(3);
  syms.sort();
  var iValue = -1; //value of index
  var base_chars = new Array();
  var base_seq = new Array();
  var base_spatial = new Array();
  var base_punc = new Array();
  var base_symbols = new Array();
  for(i=0;i<syms.length;i++){
    iValue = base_chars.indexOf(syms[i]);
    if (iValue==-1){
      base_chars.push(syms[i]);
      base_spatial.push(0);
      base_seq.push(0);
      base_punc.push(0);
      base_syms = new Array();
      base_symbols.push(base_syms);
    }
  }

  var bsw_iswa = bsw2iswa(bsw);
  var syms = bsw_iswa.chunk(9);
  syms.sort();
  var iValue = -1; //value of index
  for(i=0;i<syms.length;i++){
    sym = syms[i];
    base = sym.slice(0,3);
    iValue = base_chars.indexOf(base);
    if (iValue==-1){
      //problem
      base_syms = new Array(syms[i]);
      base_symbols[iValue] = base_syms;
    } else {
      base_syms = base_symbols[iValue];
      base_syms.push(syms[i]);
      base_symbols[iValue]=base_syms;
    }
  }

//now for basesymbol frequency
//get cnt_spatial and cnt_seq
  bsw_units = bsw2unit(bsw);
  var first_char='';
  var iValue = 0;  //index value for base counts
  for (var i=0; i<bsw_units.length; i++) {
    data = bsw_units[i];
    dataAr = data.chunk(3)
    first_char = dataAr[0]
    if (isPunc(first_char)){
      //add to char analysis
      iValue = base_chars.indexOf(first_char);
      base_punc[iValue]+=1;
    } else {
      cluster = bsw2base(bsw2cluster(data));
      if (cluster){
        syms = cluster.chunk(3);
        for(j=0;j<syms.length;j++){
          iValue = base_chars.indexOf(syms[j]);
          base_spatial[iValue]+=1;
        }
      }
      seq = bsw2base(bsw2seq(data));
      if (seq){
        syms = seq.chunk(3);
        for(j=0;j<syms.length;j++){
          iValue = base_chars.indexOf(syms[j]);
          base_seq[iValue]+=1;
        }
      }
    }
  }

  var grid_bs = new Array();
  var grid_bs_seq = new Array();
  var grid_bs_punc = new Array();
  var row = new Array();
  var rowSeq = new Array();
  var rowPunc = new Array();
  for (var i=0;i<base_chars.length; i++){
    //should check for no spatial symbols
    first_char = base_chars[i];
    row = new Array();
    rowSeq = new Array();
    rowPunc = new Array();
    base_code = hexdec(first_char);
    base_link = '<a href="" onclick="SetHash(\'f1.' + first_char + '\');return false;">';
    row.push(base_link + first_char +'</a>');
    rowSeq.push(base_link + first_char +'</a>');
    rowPunc.push(base_link + first_char +'</a>');
    row.push(bsw2utf(first_char));
    rowSeq.push(bsw2utf(first_char));
    rowPunc.push(bsw2utf(first_char));
    row.push(bsw2token(first_char));
    rowSeq.push(bsw2token(first_char));
    rowPunc.push(bsw2token(first_char));
    code = hexdec(first_char);
    iValue = base_chars.indexOf(first_char);
    if (base_spatial[iValue]>0) { 
      spat_cnt = base_spatial[iValue];
    } else {
      spat_cnt='';
    }
    if (base_seq[iValue]>0) { 
      seq_cnt = base_seq[iValue];
    } else {
      seq_cnt='';
    }
    if (base_punc[iValue]>0) { 
      punc_cnt = base_punc[iValue];
    } else {
      punc_cnt='';
    }
    row.push(base_spatial[iValue] + '&nbsp;' + base_link + '<img border=0 src="' + imgSrc(first_char) + '">' + '</a>');
    rowSeq.push(seq_cnt + '&nbsp;' + base_link + '<img border=0 src="' + imgSrc(first_char) + '"></a>');
    rowPunc.push(punc_cnt + '&nbsp;' +  base_link + '<img border=0 src="' + imgSrc(first_char) + '"></a>');
    if (spat_cnt>0) grid_bs.push(row);
    if (seq_cnt>0) grid_bs_seq.push(rowSeq);
    if (punc_cnt>0) grid_bs_punc.push(rowPunc);
  }
  if (grid_bs.length) out += GridOutput("Spatial SignSpellings",grid_bs);
  if (grid_bs_seq.length) out += GridOutput("SignSpelling Sequences",grid_bs_seq);
  if (grid_bs_punc.length) out += GridOutput("Punctuation",grid_bs_punc);

//now symbol frequency
  out+="<br><hr><h1>Symbol Frequency</h1>";
  out+="<h2>by BaseSymbol</h2>";
  for (var i=0;i<base_chars.length; i++){
    var base_char = base_chars[i];
    var grid_sym = new Array();
    base_syms = base_symbols[i];
    bswd = base_syms.length + '&nbsp;<img src="' + imgSrc(base_char) + '">';
    out += '<a id="f1.' + base_char + '"></a>';
    for (var j=0;j<base_syms.length;j++){
      var row = new Array();
      sym_char = base_syms[j];
      base_link = '<a target="_blank" href="iswa/' + base_char + '/' + base_char + '_bs.html">';
      sym_char = base_syms[j];
      row.push(base_link + sym_char +'</a>');
      row.push(bsw2utf(sym_char));
      row.push(bsw2token(sym_char));
      code = hexdec(sym_char);
      row.push(base_link + '<img border=0 src="' + imgSrc(sym_char) + '">' + '</a>');
      grid_sym.push(row);
    }
    out += GridOutput("",grid_sym,bswd);
  } 
  $('output').innerHTML = out;
  SetHash("f");
}

/**
 * Format Output
 */
function FormatOutput(){
//get data
  bsw = AnalyzeInput();

//reject invalid
  if (!validBSW(bsw)){
    $('output').innerHTML = '<h2>Invalid Binary SignWriting</h2>';
    return;
  }
  var out = '<h1 id="m">Format Options</h1>';
  out += "<h2>BSW</h2>";
  //out += bsw;
  out += bsw2spaced(bsw);

  out += "<h2>Unicode PUA</h2>";
  out += bsw2utfspaced(bsw);

  out +="<h2>SignWriting Cartesian Markup</h2>";
  var cUnits = bsw2unit(bsw);
  for(i=0;i<cUnits.length;i++){
    var bUnit = cUnits[i];
    var first_char = bUnit.slice(0,3);
    if (isPunc(first_char)){
      out+=bsw2utf(bUnit,1);
    } else {
      out+=char2token(first_char);
      cluster = bsw2cluster(bUnit);
      if (cluster){
        cluster=cluster.chunk(3);
        for (j=0;j<cluster.length;j++){
          out+=char2utf(cluster[j],1);
          j++;
          out+=char2utf(cluster[j],1);
          j++;
          out+=char2utf(cluster[j],1);
          j++;
          out+=hex2num(cluster[j]) + ",";
          j++;
          out+=hex2num(cluster[j]);
        }
        out+=' ';
      }
      seq = bsw2seq(bUnit);
      if (seq) {
        out+= "Q";
        out+= bsw2utf(seq,1);
      }
      out += ' ';
    }
  } 
 
  out +="<h2>XML</h2>";
  var cUnits = bsw2unit(bsw);
  for(i=0;i<cUnits.length;i++){
    var bUnit = cUnits[i];
    var first_char = bUnit.slice(0,3);
    if (isPunc(first_char)){
      out+='&lt;punc&gt;' + first_char + char2fill(bUnit.slice(3,6)) + char2rot(bUnit.slice(6,9)) + '&lt;punc&gt;<br>';
    } else {
      out+='&lt;sign lane="' + char2lane(first_char) + '"&gt;<br>';
      cluster = bsw2cluster(bUnit);
      if (cluster){
        cluster=cluster.chunk(3);
        for (j=0;j<cluster.length;j++){
          char = cluster[j];
          j++;
          fill = cluster[j];
          j++;
          rot = cluster[j];
          j++;
          x = hex2num(cluster[j]);
          j++;
          y = hex2num(cluster[j]);
          out+='&nbsp&nbsp;&lt;sym x="' + x + '" y="' + y + '"&gt;' + char + char2fill(fill) + char2rot(rot) + '&lt;/sym&gt;<br>';
        }
      }
	  //0fb 
	  100
	  38c
	  392
	  490
	  49f
	  
	  //0fb
	  100
	  38c
	  392
	  4cd
	  4cd
	 char , fill - 908 , rot -914, x- 1229 , y - 1229
	 
      seq = bsw2seq(bUnit);
      if (seq) {
        seq=seq.chunk(3);
        for (j=0;j<seq.length;j++){
          char = seq[j];
          j++;
          fill = seq[j];
          j++;
          rot = seq[j];
          out+='&nbsp&nbsp;&lt;seq&gt;' + char + char2fill(fill) + char2rot(rot) +  '&lt;/seq&gt;<br>';
        }
      }
      out+='&lt;/sign&gt;<br>';
    }
  } 
 
  $('output').innerHTML = out;
  SetHash("m");
}

