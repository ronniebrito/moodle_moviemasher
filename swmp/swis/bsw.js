/**
 * BSW Library for JavaScript
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

String.prototype.chunk = function(n) {
  if (typeof n=='undefined') n=2;
  return this.match(RegExp('.{1,'+n+'}','g'));
};

var hello = "0fb14c38e3924ba4b027138c3984d04c2";
var hello_seq = "0fd14c38e39227138c398";
var world = "0fb18738c39c4c24d918738c3934bb4c320538c3924d34c62ef38c3924cb4af";
var world_seq = "0fd18738c39318738c39c2ef38c39220538c392";
var period = "38838c392";
var hello_world = hello + world + period;

var sg_list = new Array('100','10e','11e','144','14c','186','1a4','1ba','1cd','1f5', '205','216','22a','255','265','288','2a6','2b7','2d5','2e3', '2f7', '2ff','30a','32a','33b','359', '36d','376', '37f', '387');

function dechex(d) {return d.toString(16);}

function hexdec(h) {return parseInt(h,16);} 

function bin2hex(str){
  var hex = '';
  for(i=0;i<str.length;i++) {
      d = str.charCodeAt(i);
      hex +=  padLeft(d.toString(16),2,"0");
  } 
  return hex;
}

function hex2bin(hex){
  var str = '';
  forEach(hex.chunk(2),function(char){
    str +=  String.fromCharCode(hexdec(char));
  });
  return str;
}

function num2hex(num) {return dechex(num+1229);}

function hex2num(hex) {return parseInt(hex,16)-1229;} 

function bsw2base(bsw){
  if (bsw=="")return;
  var bsw_base = '';
  var chunks = bsw.chunk(3);
  chunks = chunks.sort();
  forEach(chunks,function(char){
    if(isISWA(char)){
      bsw_base += char;
    }
  });
  return bsw_base
}

function base2view(base){
  var view = base + '00';
  if (isHand(base)){
    if(!isSymGrp(base)){
      view = base + '10';
    }
  }
  return view;
}

function key2bsw(key){
  var base = key.slice(0,3);
  var fill = key.slice(3,4);
  var rot = key.slice(4,5);
  return base + fill2char(fill) + rot2char(rot);
}

function bsw2key(bsw){
  var base = bsw.slice(0,3);
  var fill = bsw.slice(3,6);
  var rot = bsw.slice(6,9);
  return base + char2fill(fill) + char2rot(rot);
}

function bsw2iswa(bsw){
  if (bsw=="")return;
  var iswa_chars = '';
  var chars = bsw.chunk(3);
  var char = '';
  for (var i=0; i<chars.length; i++) {
    char = chars[i];
    if(isISWA(char)){
      iswa_chars += char;
      i++;
      iswa_chars += chars[i];
      i++;
      iswa_chars += chars[i];
    }
  }
  return iswa_chars; 
}

function char2utf(char,plane){
  if (!plane){plane=15;}
  code = hexdec(char) + 55046;
  char = dechex(plane) + dechex(code);
  var utf = '&#' + hexdec(char) + ';';
   return utf;
}

function bsw2utf(bsw,plane){
  var bsw_utf = '';
  forEach(bsw.chunk(3),function(char){ 
    bsw_utf += char2utf(char,plane);
  });
  return bsw_utf;
}

function utf2char(utf){
  var val = encodeURIComponent(utf);
  var plane = val.slice(0,3);
  var a = val.slice(4,6);
  var b = val.slice(7,9);
  var c = val.slice(10,12);

  switch(plane){
    case "%F0"://plane 1
      var code = parseInt(hexdec(c)-128) + parseInt(hexdec(b)-128)*64 + parseInt(hexdec(a)-144) * 64 * 64 - 55046;
      if (code<256){
        return '0' + dechex(code);
      } else {
        return dechex(code);
      }
      break;
    case "%F3"://plane 15
      var code = parseInt(hexdec(c)-128) + parseInt(hexdec(b)-128)*64 + parseInt(hexdec(a)-176) * 64 * 64 - 55046;
      if (code<256){
        return '0' + dechex(code);
      } else {
        return dechex(code);
      }
      break;
    case "%F4"://plane 16
      var code = parseInt(hexdec(c)-128) + parseInt(hexdec(b)-128)*64 + parseInt(hexdec(a)-128) * 64 * 64 - 55046;
      if (code<256){
        return '0' + dechex(code);
      } else {
        return dechex(code);
      }
      break;
  }
}

function utf2bsw(bsw_utf){
  var bsw = '';
  forEach(bsw_utf.chunk(2),function(utf){ 
    bsw += utf2char(utf);
  });
  return bsw;
}

function char2lane(char){
  var lane = 0;
  switch (char) {
    case "0fa"://left lane
      lane=-1;
      break;
    case "0fc"://right lane
      lane=1;
      break;
    default://center lane
      lane=0;
      break;
  }
  return lane;
}

function lane2char(lane){
  var char = "0fb";
  switch (lane) {
    case -1://left lane
      char="0fa";
      break;
    case 1://right lane
      char="0fc";
      break;
    default://center lane
      char="0fb";
      break;
  }
  return char;
}

function char2fill(char){
  return dechex(hexdec(char)-908);
}

function fill2char(fill){
  return dechex(hexdec(fill)+908);
}

function char2rot(char){
  return dechex(hexdec(char)-914);
}

function rot2char(rot){
  return dechex(hexdec(rot)+914);
}

inHexRange = function(start,end,char){
  return (hexdec(start)<=hexdec(char) && hexdec(end)>=hexdec(char)); 
}

isControl= partial(inHexRange,"fa","ff"); 
isISWA = partial(inHexRange,"100","38b");
isHand = partial(inHexRange,"100","204");
isMove = partial(inHexRange,"205","2f6");
isDyn = partial(inHexRange,"2f7","2fe");
isHead = partial(inHexRange,"2ff","36c");
isTrunk = partial(inHexRange,"36d","375");
isLimb = partial(inHexRange,"376","37e");
isSeq = partial(inHexRange,"37f","386");
isPunc = partial(inHexRange,"387","38b"); 
isFill = partial(inHexRange,"38c","391"); 
isRot = partial(inHexRange,"392","3a1"); 
isNum = partial(inHexRange,"3a2","5f9"); 

function isSymGrp(char){
  var symgrp = findValue(sg_list,char);
  if (symgrp == -1) {
    return false;
  } else {
    return true;
  } 
}

function char2token(char){
var token = '-';
  switch (char) {
    case "0fb":// sign box
      token = 'B';
      break;
    case "0fd"://sequence
      token = 'Q';
      break;
    case "0fa"://left lane
      token = 'L';
      break;
    case "0fc"://right lane
      token = 'R';
      break;
    default://
      if (isHand(char)) token = 'h';
      if (isMove(char)) token = 'm';
      if (isDyn(char)) token = 'd';
      if (isHead(char)) token = 'f';
      if (isTrunk(char)) token = 't';
      if (isLimb(char)) token = 'x';
      if (isSeq(char)) token = 's';
      if (isPunc(char)) token = 'P';
      if (isFill(char)) token = 'i';
      if (isRot(char)) token = 'o';
      if (isNum(char)) token = 'n';
  }
  return token;
}

function bsw2token(bsw){
  var chars = bsw.chunk(3);
  var key='';
  forEach(chars,function(char){key+=char2token(char);});
  return key;
}

function validBSW(bsw){
  var tokens = bsw2token(bsw);
  return /^([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?|Pio)+$/i.test(tokens);
}

function tokensplit(bsw,tokenmatch){
  var bsw_array = new Array();
  var cursor = 0;
  forEach (tokenmatch, function (tokens){
    var len = tokens.length;
    if (len) {
      bswd = bsw.slice(cursor,cursor+len*3);
      bsw_array.push(bswd);
      cursor += len*3;
    }
  });
  return bsw_array;
}

function bsw2segment(bsw){
  var tokens = bsw2token(bsw);
  var pattern = /([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?)*(Pio)?/ig;
  var tokenSegments = tokens.match(pattern);
  return tokensplit(bsw,tokenSegments);
}

function bsw2unit(bsw){
  var tokens = bsw2token(bsw);
  var pattern = /(([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?)|Pio)/ig;
  var tokenUnits = tokens.match(pattern);
  return tokensplit(bsw,tokenUnits);
}

function bsw2signs(bsw){
  var tokens = bsw2token(bsw);
  var pattern = /(([LBR]([hmdftx]ionn)*(Q([hmdftxs]io)+)?)|Pio)/ig;
  var tokenUnits = tokens.match(pattern);
  var units = tokensplit(bsw,tokenUnits);
  var signs = new Array();
  
  for (var i=0; i<units.length; i++) {
    data = units[i];
    first_char = data.slice(0,3);
    if (isPunc(first_char)){
      //safely ignore
    } else {
      signs.push(data);
    }
  }
  return signs;
}

function signs2sort(signs){
//setup sort and index array
  var index_seq = new Array();
  var cnt_seq=0;

//now ignore punctuation
//populate seq sorting arrays
  var first_char='';
  var iValue = 0;  //index value for base counts
  for (var i=0; i<signs.length; i++) {
    data = signs[i];
    first_char = data.slice(0,3);
    cluster = first_char + bsw2cluster(data);
    seq = bsw2seq(data);
    if (seq=="") {
      seq = cluster2seq(cluster);
    }
    if (seq){//ignore empty signs
      index_seq["0FD" + seq + cluster + i]= i;
      cnt_seq++;
    }
  }

  var keys = new Array();
  if (cnt_seq){
    //sort sequence
    for(k in index_seq) { keys.push(k); }
    keys.sort( function (a, b){return (a > b) - (a < b);} );
  }
  
  var sort_keys = new Array();
  for (var i=0; i<keys.length;i++){
    sort_keys[i]=index_seq[keys[i]];
  }
  return sort_keys;
}

function signs2index(signs){
//setup index array
  var index_base = new Array();
  var cnt_base=0;

//now ignore punctuation
//populate index with basesymbols
  var first_char='';
  var iValue = 0;  //index value for base counts
  for (var i=0; i<signs.length; i++) {
    data = signs[i];
    first_char = data.slice(0,3);
    cluster = first_char + bsw2cluster(data);
    base = bsw2base(data);
    if (base){//ignore empty signs
      index_base["0FD" + base + cluster + i]= i;
      cnt_base++;
    }
  }

  var keys = new Array();
  if (cnt_base){
    //base sequence
    for(k in index_base) { keys.push(k); }
    keys.sort( function (a, b){return (a > b) - (a < b);} );
  }
  
  var index_keys = new Array();
  for (var i=0; i<keys.length;i++){
    index_keys[i]=index_base[keys[i]];
  }
  return index_keys;
}

function bsw2spaced(bsw){
  if (bsw=="")return;
  if (!validBSW(bsw)){return;}
  var units = bsw2unit(bsw);
  var bsw = units[0];
  bsw= bsw.replace("0FD"," 0FD");
  var spaced = bsw;
  for (var i=1; i<units.length; i++) {
    bsw = units[i];
    bsw=bsw.replace("0FD"," 0FD");
    spaced += ' ' + bsw;
  }
  return spaced;
}

function bsw2utfspaced(bsw){
  if (bsw=="")return;
  if (!validBSW(bsw)){return;}
  bsw = bsw2spaced(bsw);
  var chunks = bsw.split(' ');
  var spaced = bsw2utf(chunks[0]);
  for (var i=1; i<chunks.length; i++) {
    bsw = chunks[i];
    spaced += ' ' + bsw2utf(bsw);
  }
  return spaced;
}

function bsw2cluster(bsw){
  var tokens = bsw2token(bsw);
  var pattern = /([hmdftx]ionn)+/i;
  var tokenCluster = tokens.match(pattern);
  if (tokenCluster!=null){
    var pos = tokens.indexOf(tokenCluster[0]);
    var len = tokenCluster[0].length;
    return bsw.slice(pos*3,pos*3+len*3);
  } else {
    return "";
  }
}

function bsw2seq(bsw){
  var tokens = bsw2token(bsw);
  var pattern = /Q([hmdftxs]io)+/i;
  var tokenSeq = tokens.match(pattern);
  var seq;
  if (tokenSeq) {
    var pos = tokens.indexOf(tokenSeq[0]);
    var len = tokenSeq[0].length;
    seq = bsw.slice(3+pos*3,pos*3+len*3);
  } else {
    seq = '';
  }
  return seq;
}

function cluster2seq(bsw){
  var cluster = bsw2cluster(bsw);
  var seq = '';
  if (cluster){
    var bswd = bsw2iswa(cluster);
    chunks = bswd.chunk(9);
    chunks = chunks.sort();
    bswd = chunks.toString();
    seq = bswd.replace(/,/g,'');
  }
  return seq;
}

function locationsplit(bsw,iPunc, iSign){
//needs cleaned up and simplified
  var bsw_array = new Array();
  var preLoc = '';
  var unitLoc = '';
  var postLoc = '';

  var segs = bsw2segment(bsw);
  for(i=0;i<segs.length;i++) {
    if (i<iPunc) {
      if( (i == (iPunc-1)) && (iSign==0)){
        //special case to return punc
        var units = bsw2unit(segs[i]);
        for(j=0;j<units.length;j++) {
          if ((j+1)<units.length) {
            preLoc += units[j];
          } else {
            unitLoc = units[j];
          }
        }
       } else {
        preLoc += segs[i];
      }
    } else if (i>iPunc) {
      postLoc += segs[i];
    } else {  //i == iPunc
      var units = bsw2unit(segs[i]);
      for(j=0;j<units.length;j++) {
        if ((j+1)<iSign) {
          preLoc += units[j];
        } else if ((j+1)>iSign) {
          postLoc += units[j];
        } else {  //(j+1) == iSign
          unitLoc = units[j];
        }
      }
    }
  } 
  bsw_array.push(preLoc);
  bsw_array.push(unitLoc);
  bsw_array.push(postLoc);
  return bsw_array;
}
