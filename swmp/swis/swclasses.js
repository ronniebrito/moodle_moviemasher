/**
 * SignWriting Classes library for javascript
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

function Sign (bswd){
  if (bswd==""){bswd = "0080";}
  this.data = bswd;
  var first_char = bswd.slice(0,3);
  this.first_char = first_char;
  if (isPunc(first_char)) {
    this.data = bswd;//force punc only
    if (imgChecker.isGood(bswd)){
      var pSize = imgChecker.size(bswd);
    } else {
      var pSize = {w:19,h:33};
    }
    this.w = pSize.w;
    this.h = pSize.h;
    this.cx = pSize.w/2;
    this.cy = pSize.h/2;
    this.x = 0;//this.w/2;
    this.y = 0;//this.h/2;
    this.lane = 0; //all punc goes in the center lane
  } else {
    this.lane = char2lane(first_char);
    var cluster = bsw2cluster(bswd)
    if (cluster !='') {
      var chars = cluster.chunk(3);
    } else {
      var chars = '';
    }
    if (chars.length>4) {
      //get initial values for min x,y
      var sym_char = chars[0];
      var sym_fill = chars[1];
      var sym_rot = chars[2];
      var minX = hex2num(chars[3]);
      var maxX = minX;
      var minY = hex2num(chars[4]);
      var maxY = minY;
      var minCX = 0;
      var maxCX = 0;
      var minCY = 0;
      var maxCY = 0;
      var cc = 0; //center count
      for (var i=0; i<chars.length; i++) {
        sym_char = chars[i++];
        sym_fill = chars[i++];
        sym_rot = chars[i++];
        x_val = hex2num(chars[i++]);
        y_val = hex2num(chars[i]);
        minX = Math.min(minX,x_val);
        minY = Math.min(minY,y_val);
        if (imgChecker.isGood(sym_char + sym_fill + sym_rot)){
          pSize = imgChecker.size(sym_char + sym_fill + sym_rot);
        } else {
          pSize = {w:19,h:33};
        }
        maxX = Math.max(maxX,x_val + pSize.w);
        maxY = Math.max(maxY,y_val + pSize.h);
        if(isHead(sym_char) || isTrunk(sym_char)){
          if(cc>0){
            minCX = Math.min(minCX,x_val);
            maxCX = Math.max(maxCX,x_val + pSize.w);
            minCY = Math.min(minCY,y_val);
            maxCY = Math.max(maxCY,y_val + pSize.h);
          } else {
            minCX = x_val;
            maxCX = x_val + pSize.w;
            minCY = y_val;
            maxCY = y_val + pSize.h;
          }
          cc++;
        }
      }
      this.x = minX;
      this.y = minY;
      this.w = maxX - minX;
      this.h = maxY - minY;
      //rough estimate for center if no centering syms
      if (cc>0){
        this.cx = (minCX + maxCX)/2;
        this.cy = (minCY + maxCY)/2;
      } else {
        this.cx = (minX + maxX)/2;
        this.cy = (minY + maxY)/2;
      }
    } else {
      this.x = 0;
      this.y = 0;
      this.w = 40;
      this.h = 40;
      this.cx = 20;
      this.cy = 20;
    }
  }

  return this;
}

function Column (height){
  this.h = height;
  this.w = 250;
  this.lane_offset = 50;
  this.hpad = 20;
  this.vpad = 20;
  this.sp = 10;
  this.cursor = this.hpad;
  this.units = new Array();
  this.positions = new Array();
  this.last = ''; //sign or punc, used for spacing
  this.div = DIV({'class':'Column','style':{'height':height + 'px'}});
  this.add = function(sign){
    var cur = (isPunc(sign.first_char)) ? "punc" : "sign";
    if(this.last) {
      switch (this.last + cur) {
        case "signsign":
          this.cursor += this.sp*2;
          break;
        case "signpunc":
          this.cursor += this.sp;
          break;
        case "puncsign":
          this.cursor += this.sp*3;
          break;
        default://punc to punc?
          this.cursor += this.sp;
          break;
      }
    }
    this.last = cur;
    if ((this.h>(this.cursor + sign.h)) || (this.units.length ==0)){
      sign.top = this.cursor;
      this.units.push(sign);
      this.positions.push({down:this.cursor,unit:cur});
      this.cursor += sign.h;
      return null;
    } else {
      return sign;
    }
  };

  this.setup = function(){
    //first get global left and right of center
    cleft = this.units[0].cx - this.units[0].x - (this.units[0].lane * this.lane_offset);
    cright = this.units[0].w - cleft;
    for (var i=0; i<this.units.length; i++) {
      var sign = this.units[i];
     sleft = sign.cx - sign.x - (sign.lane * this.lane_offset);
      sright = sign.w - sleft;
      cleft = Math.max(cleft,sleft);
      cright = Math.max(cright,sright);
    }

    //set column width and center left & right
    var width = cright + cleft + this.vpad * 2;
    setStyle(this.div,{'width':width + 'px'});
    this.w = width;
    this.cleft = cleft;
    this.cright = cright;
  }

  this.display = function(){
    //cycle through signs and place
    for (var i=0; i<this.units.length; i++) {
      var sign = this.units[i];
      var chars = sign.data.chunk(3);
      var first_char = chars[0];
      var dtlPos = getElementPosition(this.div);
      if (isPunc(first_char)) {
        pos = new Coordinates(this.vpad + this.cleft - (sign.cx),sign.top);
        //align top needed for proper placement of short images (firefox bug?)
        d = DIV({'class':'Symbol'},IMG({src:imgSrc(sign.data,false),align:"top"}));
        appendChildNodes(this.div,d);
        setElementPosition(d,pos);
      } else {
        var cluster = sign.first_char + bsw2cluster(sign.data);//remove sequence
        chars = cluster.chunk(3);
        if (chars.length>5){
          //get initial values for min x,y
          for (var j=1; j<chars.length; j++) {
            sym_char = chars[j++];
            sym_fill = chars[j++];
            sym_rot = chars[j++];
            sx = hex2num(chars[j++]);
            sy = hex2num(chars[j]);
            pos = new Coordinates(this.vpad + this.cleft - sign.cx + sx + (sign.lane * this.lane_offset),sign.top+sy-sign.y);
            //align top needed for proper placement of short images (firefox bug?)
            d = DIV({'class':'Symbol'},IMG({src:imgSrc(sym_char + sym_fill + sym_rot,false),align:"top"}));
            appendChildNodes(this.div,d);
            setElementPosition(d,pos);
          }
        }
      }
    }
  };
  return this;
}

function imgSrc(cSym,flag){
//flag true to pass without bad check
  var src = "";
  var char = "";
  switch (cSym.length) {
    case 3:
      src = "glyph.php?base=" + cSym;
      char = key2bsw(base2view(cSym));
      break;
    case 4:
      alert ("old BSW call");
      src ="ui/unknown.png";
      break;
    case 5://key call
      src = "glyph.php?key=" + cSym;
      char = key2bsw(cSym);
      break;
    case 9://3 char call
      src = "glyph.php?bsw=" + cSym;
      char = cSym;
      break;
    default://unknown
      alert ("unknown length " + cSym);
      src ="ui/unknown.png";
      break;
  }

  if (!flag) {
    if (imgChecker.isBad(char)){
      src ="ui/unknown.png";
    }
  }
  return src;
}

var imgChecker = new imgChecking();

function imgChecking(){
  var imgood = new Array();//list of good chars
  var imbad = new Array();//list of bad chars
  var imload = new Array();//list of loading chars
  var imsize = new Array();//list of image sizes

  this.good = function(cSym){//called when a img is good
    fnChrFltr = partial(compare,cSym);
    imload = filter(fnChrFltr,imload);
    imgood.push(cSym);
    var limg = new Image();
    limg.src = imgSrc(cSym,true);
    imsize[cSym] = {w:limg.width,h:limg.height};
  }

  this.bad = function(cSym){//called when a img is bad
    fnChrFltr = partial(compare,cSym);
    imload = filter(fnChrFltr,imload);
    imbad.push(cSym);
  }

  this.check = function(data){//called to check iswa images
    if (data=="") {return;}
    tdata = '' + data;
    var chars = tdata.chunk(3);
    var iswa = new Array();
    //for loop to add iswa chars plus fill and rotations...
    for (var i=0; i<chars.length; i++) {
      char = chars[i];
      if (isISWA(char)){
        i++;
        var fill = chars[i];
        i++;
        var rot = chars[i];
        var cSym = char + fill + rot;
        iswa.push(cSym);
      }
    }
    forEach(iswa,function (cSym){
      //skip if good, bad, or loading
      if (findValue(imgood,cSym)>-1){return;}
      if (findValue(imbad,cSym)>-1){return;}
      if (findValue(imload,cSym)>-1){return;}
      imload.push(cSym);
      new loadImg(cSym);
    });
  }

  this.loading = function(){//loading check for any sym
    if (imload.length) {return true;} else {return false;}
  }

  this.isGood = function(cSym){//loading check
    if (findValue(imgood,cSym)==-1) {
      return false;
    } else {
      return true;
    }
  }

  this.isBad = function(cSym){//loading check
    if (findValue(imbad,cSym)==-1) {return false;} else {return true;}
  }

  this.size = function(cSym){//return size of image
    return imsize[cSym];
  }
}

//load image function with good and bad checking
function loadImg(cSym){
  this.good = function(){
    imgChecker.good(cSym);
  }
  this.bad = function(){
    imgChecker.bad(cSym);
  }
  var limg = new Image();
  limg.onload=this.good;
  limg.onerror=this.bad;
  limg.src = imgSrc(cSym,true);
}

