/**
 * SignMaker javascript
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
var signlane = '0fb';
var signbox;
var sequence;
var shiftkey=0;
function loadSignMaker(){
/**
 * SymbolPalette setup
 */
//createLoggingPane();
  loadPalette();
  signbox = new SignBox();
  sequence = new Sequence();
//  signmarker=bsw.slice(0,4);
  var cluster = '';
  if (bsw) {cluster = bsw2cluster(bsw);}
  if (cluster) {signbox.Load(cluster);}
  var seq = '';
  if (bsw) {seq = bsw2seq(bsw);}
  if (seq) {sequence.Load(seq);}
  sequence.setup();
  connect('signbox','onmousedown',signbox,'MouseDown');
  connect('signbox','onmousemove',signbox,'MouseMove');
  connect('signbox','onmouseup',signbox,'MouseUp');
  connect('signbox','onmouseout',signbox,'MouseOut');
  connect(document,'onkeydown',signbox,'KeyDown');
  connect(document,'onkeyup',signbox,'KeyUp');
  signbox.Gridded();
}

function rebuildacceptSM(){
  iHTML = '<a href="' + acceptSM + '?';
  //add build
  var bsw = signlane;
  for (id in signbox.Symbols){ 
    var elemPos = elementPosition(id, 'signbox');
    bsw += key2bsw(signbox.Symbols[id].code) + num2hex(Math.floor(elemPos.x)) + num2hex(Math.floor(elemPos.y)); 
  }
  iHTML += 'bsw=' + bsw;
  var seq = "";
  for (id in sequence.Symbols){ 
    if (sequence.Symbols[id].code){
      seq += key2bsw(sequence.Symbols[id].code); 
    }
  }
  if (seq){
    iHTML += '0fd' + seq;
  }

  if (sid) {
    iHTML += '&sid=' + sid;
  }

  iHTML += '"><img src="media/Submit.png" border="0"></a>';
  $('acceptSM').innerHTML = iHTML;

  imgChecker.check(bsw);
  
  if (signbox.bsw != bsw){
    if (typeof(cl) != 'undefined') cl.cancel();
    signbox.bsw = bsw;
    cl = callLater(.1,resizeSignBox,bsw);
  }
}

function resizeSignBox(bsw){
  if (imgChecker.loading()){
    callLater(.1,resizeSignBox,bsw);
    return;
  }
  signbox.resize();
  setElementDimensions("signbox",{w:signbox.w,h:signbox.h});
  setElementDimensions("signmaker",{w:signbox.w+2,h:signbox.h+2});
  setElementDimensions("signboxTop",{w:signbox.w+2});
  setElementDimensions("signboxLeft",{h:signbox.h});
  setElementDimensions("signboxRight",{h:signbox.h});
  setElementDimensions("signboxBottom",{w:signbox.w+2});
  signal(signbox, 'resize');
}

function SignBox(){
  this.id = 'signbox';
  this.bsw = '';
  this.x = -49;
  this.y = -49;
  this.w = 100;
  this.h = 100;
  this.grid = 0;
  this.startDrag = 0;
  this.Dropped = fnDropped;
  this.select = fnSelect;
  this.deselect = fnDeselect;
  this.CopySymbol = fnCopySymbol;
  this.DeleteSymbol = fnDeleteSymbol;
  this.ClearAll = fnClearAll;
  this.Variation = fnVariation;
  this.Mirror = fnMirror;
  this.Fill = fnFill;
  this.PlaceOver = fnPlaceOver;
  this.Next = fnNext;
  this.Rotate = fnRotate;
  this.MoveSymbol = fnMoveSymbol;
  this.Rebuild= fnRebuild;
  this.setup= fnSBSetup;
  this.Load= fnLoad;
  this.resize = fnSBResize;
  this.Gridded = fnGridded;
  this.MouseDown = fnMouseDown;
  this.MouseMove = fnMouseMove;
  this.MouseUp = fnMouseUp;
  this.MouseOut = fnMouseOut;
  this.KeyDown = fnKeyDown;
  this.KeyUp = fnKeyUp;
  new Droppable('signbox', { 
        accept: ["PaletteSymbol"], 
        ondrop: function (element) { signbox.Dropped(element.id);}               
      });
  this.Symbols = new Array();
  this.sID = 1;
  this.selected= new Array();
  this.setup();
}

function fnKeyDown(e){
  if (e.key().code==16) shiftkey=1;
}

function fnKeyUp(e){
  if (e.key().code==16) shiftkey=0;
}

function fnMouseDown(event){
  var sbPos = getElementPosition(this.id);
  var Pos = event.mouse().client;
  Pos.x -=sbPos.x;
  Pos.y -=sbPos.y;
  this.startDrag = Pos;
  shiftkey=1;
}

function fnMouseMove(event){
  if (this.startDrag){
    var sbPos = getElementPosition(this.id);
    var Pos = event.mouse().client;
    Pos.x -=sbPos.x;
    Pos.y -=sbPos.y;
    var xs = [Pos.x, this.startDrag.x];
    minx = listMin(xs);
    maxx = listMax(xs);
    var ys = [Pos.y, this.startDrag.y];
    miny = listMin(ys);
    maxy = listMax(ys);
    //now select or don't
    for(id in this.Symbols){
      if (this.Symbols[id].xy.x>minx && this.Symbols[id].xy.x<maxx
        && this.Symbols[id].xy.y>miny && this.Symbols[id].xy.y<maxy){
        this.select(id);
      } else {
        this.deselect(id);
      }
    
    }
  }
}

function fnMouseUp(event){
  if (this.startDrag){
    var sbPos = getElementPosition(this.id);
    var Pos = event.mouse().client;
    Pos.x -=sbPos.x;
    Pos.y -=sbPos.y;
    this.startDrag=0;
    shiftkey=0;
  }
}

function fnMouseOut(event){
  if (this.startDrag){
  //make sure out of sign box, not over symbol
    var sbPos = getElementPosition(this.id);
    var Pos = event.mouse().client;
    Pos.x -=sbPos.x;
    Pos.y -=sbPos.y;
    SB = getElementDimensions('signbox');
    if (Pos.x<0 || Pos.x>SB.w
      || Pos.y<0 || Pos.y>SB.h){
      this.startDrag=0;
      shiftkey=0;
    }
  }
}

function fnGridded(){
  if (this.grid==0){
    addElementClass('signbox', 'gridded');
    this.grid=1;
  } else {
    removeElementClass('signbox', 'gridded');
    this.grid=0;
  }
}

function fnLoad(cluster){
  if (cluster){
    var chars = cluster.chunk(3);
  } else {
    var chars = "";
  }
  var tGrp = 0;
  var tSym = 0;
  for (var i=0; i<chars.length;i++){
    base= chars[i]; 
    i++;
    fill= char2fill(chars[i]); 
    i++;
    rot= char2rot(chars[i]); 
    i++;
    code = base + fill + rot;
    x = hex2num(chars[i]); 
    i++; 
    y = hex2num(chars[i]);
    for (var j=0;j<keys.length;j++){
      for (var k=0;k<keys[j].length;k++){
        if (keys[j][k][0]==base) {
          tGrp=j+1;
          tSym=k+1;
        } 
      } 
    }
    var elemPos = getElementPosition(this.id);
    elemPos.x = -x;
    elemPos.y = -y;
    elemPos = getElementPosition(this.id, elemPos);
    var sID = 'symbol' + this.sID;
    this.sID++;
    this.Symbols[sID] = new Symbol(sID,code,elemPos, tGrp, tSym);
    this.Symbols[sID].Refresh();
  }
}

function fnSBResize(){
  var pad = 40;
  if (this.startDrag){return;}
  var bsw = this.bsw;
  var tSign = new Sign(bsw);
  var lx = tSign.cx - tSign.x;
  var rx = tSign.w - lx;
  var mx = Math.max(lx,rx)
  var ly = tSign.cy - tSign.y;
  var ry = tSign.h - ly;
//    var my = Math.max(ly,ry)

  this.x = mx - pad;
  this.y = ly - pad;
  this.w = mx*2 + pad*2;
  this.h = ly + ry + pad*2;
  var adjx = mx + pad - tSign.cx;
  var adjy = ly + pad - tSign.cy;
  //now adjust all the symbols appropriately
  for(ids in this.Symbols){
     var pos = elementPosition(ids,'signbox');
    if (isPunc(bsw.slice(0,3)) && pos.x != 0){adjx=0;adjy=0;}//ugly hack for punctuation
     var x = pos.x;
     var y = pos.y;
     x = x + adjx;
     y = y + adjy;
     setElementPosition(ids,{x:x,y:y});
     this.Symbols[ids].xy = elementPosition(ids,'signbox');
   }
   setStyle('signbox',{'background-position': (pad+mx+1) + 'px ' + (pad+ly+2) + 'px'});
}

function fnCopySymbol(){
  var newS = new Array();
  for(id in this.selected){
    icode = this.Symbols[id].code;
    igrp = this.Symbols[id].grp;
    isym = this.Symbols[id].sym;
    var elemPos = elementPosition(id,{x:-5,y:-5});
    var sID = 'symbol' + this.sID;
    this.sID++;
    this.Symbols[sID] = new Symbol(sID,icode,elemPos, igrp, isym);
    newS[sID]=1;
  }
  for(id in newS){
    this.select(id);
    shiftkey=1;
  }
  shiftkey=0;
}

function fnDeleteSymbol(){
  for(id in this.selected){
    disconnectAll(id);  
    removeElement(id);
    delete this.Symbols[id];
    delete this.selected[id];
    this.Rebuild();
  }
}

function fnClearAll(){
//loop through array
  for (id in this.Symbols){ 
    disconnectAll(id);  
    removeElement(id);
    delete this.Symbols[id];
    this.selected= new Array();
  }
  this.Rebuild();
}

function fnRebuild(){
  rebuildacceptSM();
}


function fnVariation(){
  for(id in this.selected){
    this.Symbols[id].Variation();
  }
}

function fnMirror(){
  for(id in this.selected){
    this.Symbols[id].Mirror();
  }
}

function fnFill(){
  for(id in this.selected){
    this.Symbols[id].Fill();
  }
}

function fnPlaceOver(){
  //copy then delete;
  for(id in this.selected){
    icode = this.Symbols[id].code;
    igrp = this.Symbols[id].grp;
    isym = this.Symbols[id].sym;
    var elemPos = elementPosition(id,{x:-1,y:-1});
    disconnectAll(id);  
    removeElement(id);
    delete this.Symbols[id];
    delete this.selected[id];
    var sID = 'symbol' + this.sID;
    this.sID++;
    this.Symbols[sID] = new Symbol(sID,icode,elemPos, igrp, isym);
  }
}

function fnNext(i) {
  idA = new Array();
  j=0;
  selected='';
  iSelected='';
  for (id in this.selected){
    selected = id;
    this.deselect(id);
  }

  for (id in this.Symbols){ 
    idA.push(id);
    if (selected==id) iSelected = j;
    j++;
  }

  
  if (i==1){//next
    if (idA.length>0){
      if (selected=='' || (iSelected+1)==idA.length){
        this.select(idA[0]);
      } else {
        this.select(idA[iSelected+1]);
      }
    }
  } else {//prev
    if (idA.length>0){
      if (selected=='' || (iSelected)==0){
        this.select(idA[idA.length-1]);
      } else {
        this.select(idA[iSelected-1]);
      }
    }
  }
}

function fnMoveSymbol(direction) {
  aMove = new Array();
  aMove = this.selected;
  for (id in aMove){
    var elemPos = getElementPosition(id,'signbox');
    switch(direction) {
    case 'up':
      elemPos.y--;
      break;    
    case 'down':
      elemPos.y++;
      break;    
    case 'left':
      elemPos.x--;
      break;    
    case 'right':
      elemPos.x++;
      break;    
    }
    setElementPosition(id,elemPos);
  }
  this.Rebuild();
}

function fnRotate(i){
  for(id in this.selected){
    this.Symbols[id].Rotate(i);
  }
}

function fnSBSetup(){
var iHTML = '<table cellpadding=1><tr>';
iHTML += '<td class="button"><a href="" onclick="PaletteSetTop();return false;"><img src="media/sg_list.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="#" onclick="PalettePrevious();return false;"><img src="media/previous.png" border="0"></a></td>';
iHTML += '<td class="button"><div id="acceptSM"><a href="' + acceptSM + '"><img src="media/Submit.png" border="0"></a></div></td>';

iHTML += '</tr><tr>';

iHTML += '<td class="button"><a href="" onclick="signbox.CopySymbol();return false;"><img src="media/copy_sym.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="" onclick="signbox.DeleteSymbol();return false;"><img src="media/del_sym.png" border="0"></a></td>';
iHTML += '<td class="button"><div id="cancel"><a href="" onclick="signbox.ClearAll();return false;"><img src="media/clear_all.png" border="0"></a></div></td>';

iHTML += '</tr><tr>';

iHTML += '<td class="button"><a href="" onclick="signbox.Variation();return false;"><img src="media/var_sym.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="" onclick="signbox.Mirror();return false;"><img src="media/mirror_sym.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="" onclick="signbox.Fill();return false;"><img src="media/fill_sym.png" border="0"></a></td>';

iHTML += '</tr><tr>';

iHTML += '<td class="button"><a href="#" onclick="signbox.PlaceOver();return false;"><img src="media/place_over.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="" onclick="signbox.Rotate(1);return false;"><img src="media/ccw.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="" onclick="signbox.Rotate(-1);return false;"><img src="media/cw.png" border="0"></a></td>';

iHTML += '</tr><tr>';

iHTML += '<td class="button"><a href="#" onclick="signbox.Next(-1);return false;"><img src="media/select_prev.png" border="0"></a></td>';
iHTML += '<td class="button"><a href="#" onclick="signbox.Next(1);return false;"><img src="media/select_next.png" border="0"></a></td>';

iHTML += '<td>';
iHTML +=  '<table cellpadding=2 width=100%>';
iHTML += '<tr><td></td><td><a href="" onclick="signbox.MoveSymbol(\'up\');return false;"><img src="media/up.png" border=0></a></td><td></td></tr>';
iHTML += '<tr><td><a href="" onclick="signbox.MoveSymbol(\'left\');return false;"><img src="media/left.png" border=0></a></td><td><a href="" onclick="signbox.Gridded();return false;"><img src="media/grid_btn.png" border=0></a></td><td><a href="" onclick="signbox.MoveSymbol(\'right\');return false;"><img src="media/right.png" border=0></a></td></tr>';
iHTML += '<tr><td></td><td><a href="" onclick="signbox.MoveSymbol(\'down\');return false;"><img src="media/down.png" border=0></a></td><td></td></tr>';
iHTML += '</table>';
iHTML += '</td>';

iHTML += '</tr></table>';

$('smcommand').innerHTML = iHTML;
}

function fnSelect(sb){
  if(shiftkey==1){
    this.Symbols[sb].select();
    this.selected[sb]=1;
  } else {
    for(id in this.selected){
      this.deselect(id);
    }
    this.Symbols[sb].select();
    this.selected[sb]=1;
  }
}

function fnDeselect(id){
  delete this.selected[id];
  this.Symbols[id].deselect();
}

function fnDropped(id){
  if (Palette[id].code) {
    for (var index in this.Symbols){
      if (char2token(this.Symbols[index].code.slice(0,3))=="P"){return;}
    }
    var token = char2token(Palette[id].code.slice(0,3));
    if (token=="P") {
      for (var index in this.Symbols){
        return;
      }
      var elemPos = elementPosition("signbox");
    } else {
      var elemPos = elementPosition(id);
    }
    if (token=="s") return;
    var sID = 'symbol' + this.sID;
    this.sID++;
    this.Symbols[sID] = new Symbol(sID,Palette[id].code,elemPos, Palette[id].grp, Palette[id].sym);
    this.Rebuild();
    this.select(sID);
  } 
}


function Symbol(id, code,xy, grp, sym){
  this.id = id;
  this.code = code;
  this.grp = grp;
  if (sym==0){sym=1;}
  this.sym = sym;
  this.Variation = fnSBVariation;
  this.Mirror = fnSBMirror;
  this.Fill = fnSBFill;
  this.Rotate = fnSBRotate;
  this.Refresh = fnSBRefresh;
  this.Color = fnSBColor;
  this.wasClicked = fnSBClicked;
  this.DragStart = fnSBDragStart;
  this.Dragging = fnSBDragging;
  this.DragStop = fnSBDragStop;
  this.select = fnSBSelect;
  this.deselect = fnSBDeselect;
  this.line=linecolor;
  this.dragging=0;
  this.vari=keys[grp-1][sym-1][2];
  this.vars=keys[grp-1][sym-1][3];


  pos = elementPosition(xy,'signbox');
  d = DIV({'id':id,'class':'Symbol','style':{'top':pos.y,'left':pos.x}});
  appendChildNodes('signbox',d);
  this.xy = getElementPosition(this.id, 'signbox');
  connect(id, "onclick", this, "wasClicked");
  var x = new Draggable(id,{
      starteffect: function (element) { signbox.Symbols[id].DragStart();}
      ,onchange: function (element) { signbox.Symbols[id].Dragging();}               
      ,endeffect: function (element) { signbox.Symbols[id].DragStop();}               
    });
  this.Refresh();
    //signbox.Symbols[this.id].select();
}

  function fnSBVariation(){
    //find number of vars
    code = this.code;
    base = code.slice(0,3);
    basekey = code.slice(3,5);
    vars = this.vars;
    vgrp = this.grp;
    vsym = this.sym;
    ivar = 0;
    i=0;
    varr = new Array();
    do {
      i++;
      ipow = Math.pow(2,i-1);
      if (ipow & this.vars) {varr.push(i);}
      if (this.vari == i) {ivar=i;}
    } while (ipow < this.vars);
    if (varr.length==1){return;}
 
   if (ivar < varr.length){
      vadj = 1;
    } else {
      vadj = - ivar + 1;
    }
    code = keys[vgrp-1][vsym - 1 + vadj][0] + basekey;
    this.sym = vsym + vadj;
    this.code = code;
    this.vari = varr[ivar + vadj -1];
    this.Refresh();
  }
  
  function fnSBMirror(){
    code = this.code;
    base = code.slice(0,3);
    fill = hexdec(code.slice(3,4));
    rot = hexdec(code.slice(4,5));

    //check for valid rotations for flip 
    fgrp = this.grp;
    fsym = this.sym;
    fTot = keys[fgrp-1][fsym-1][5];
    if (fTot>255) {rAdd=8;} else {
      if ((rot==0) || (rot==4)) {rAdd=0;} 
      if ((rot==1) || (rot==5)) {rAdd=6;} 
      if ((rot==2) || (rot==6)) {rAdd=4;} 
      if ((rot==3) || (rot==7)) {rAdd=2;} 
    }
    cont = 0;
    while (cont == 0) {
      rot += rAdd; 
      if ((rot>7) && (rAdd<8)) {rot = rot -8;}
      if (rot>15) { rot = rot -16;}
      code = base + dechex(fill) + dechex(rot);
      cont = validkey(code);
    }
    this.code = code;
    this.Refresh();
  }
  
  function fnSBFill(){
    code = this.code;
    base = code.slice(0,3);
    fill = hexdec(code.slice(3,4));
    rot = hexdec(code.slice(4,5));
    
    cont = 0;
    while (cont == 0) {
      fill++;           
      if (fill==6) { fill = 0;}
      code = base + dechex(fill) + dechex(rot);
      cont = validkey(code);
    }
    this.code = code;
    this.Refresh();
    
  }
  
  function fnSBRotate(i){
    code = this.code;
    base = code.slice(0,3);

    cont=0;
    while (cont == 0) {
      fill = hexdec(code.slice(3,4));
      rot = hexdec(code.slice(4,5));

      if ((i>0)&&(rot<8)) {
       rot++; 
       if (rot==8) {rot = rot-8;}
      } else 
      if ((i>0)&&(rot>7)) {
       rot--; 
       if (rot==7) {rot = rot+8;}
      } else 
      if ((i<0)&&(rot<8)) {
       rot--; 
       if (rot==-1) {rot = rot+8;}
      } else 
      if ((i<0)&&(rot>7)) {
       rot++; 
       if (rot==16) {rot = rot-8;}
      }

      code = base + dechex(fill) + dechex(rot);
      cont = validkey(code);
    }    
    this.code = code;
    this.Refresh();
  }



  function fnSBDragStart(e){
    if (signbox.selected[this.id]!=1){
      signbox.select(this.id);
    }
    this.xy = getElementPosition(this.id, 'signbox');
  }

  function fnSBDragging(e){
    //gotta move all other stuff.  Let's figure out where they are
    SYM = getElementPosition(this.id,'signbox');
    x = this.xy.x
    y = this.xy.y
    adjX = x - SYM.x;
    adjY = y - SYM.y;
    for (id in signbox.selected){
      if (id != this.id) {
        x = signbox.Symbols[id].xy.x;
        y = signbox.Symbols[id].xy.y;
        x = x - adjX;
        y = y - adjY;
        setElementPosition(id,{x:x,y:y});
      }
    }
  }

  function fnSBDragStop(e){
    this.dragging=1;
    SYM = getElementPosition(this.id,'signbox');
    SB = getElementDimensions('signbox');
    if (SYM.x>SB.w-10 || SYM.x<0 || SYM.y>SB.h-10 || SYM.y<0) {
      for (id in signbox.selected) setElementPosition(id,signbox.Symbols[id].xy);
    }
    for (id in signbox.selected) signbox.Symbols[id].xy = getElementPosition(id, 'signbox');
    this.Refresh();
    
  }

  function fnSBClicked(e){
    if (this.dragging){
      this.dragging=0;
      signbox.select(this.id);
    } else {
      var src=e.src();
      found=0;
      for(id in signbox.selected){
        if (id == this.id) found=1;
      }
      if (found) {
        signbox.deselect(this.id);
      } else {
        signbox.select(this.id);
      }
    }
  }


  function fnSBSelect(){
    this.line='4444ff';
    this.Color();
  }

  function fnSBDeselect(){
    this.line=linecolor;
    this.Color();
  }

  function fnSBColor(){
    htmlSB = '<img src="glyph.php?key=' + this.code + '&line=' + this.line + fillcolor + '">';
    document.getElementById(this.id).innerHTML = htmlSB;
  }

  function fnSBRefresh(){
    this.Color();
    rebuildacceptSM();
  }



function Sequence(){
  this.id = 'sequence';
  this.setup= fnSSetup;
  this.Rebuild=fnSRebuild;
  this.Load = fnSLoad;
  this.Symbols = new Array();
  this.sID = 1;
}

function fnSLoad(seq){
  var chars = seq.chunk(3);
  for (var i=0; i<chars.length;i++){
    base= chars[i]; 
    i++;
    fill= char2fill(chars[i]); 
    i++;
    rot= char2rot(chars[i]); 
    code = base + fill + rot;
    if (code) {
      var sID = 'ssymbol' + this.sID;
      this.sID++;
      this.Symbols[sID] = new SequenceSymbol(sID,code);
      this.Symbols[sID].Refresh();
    }
  }
}


function fnSRebuild(){
  rebuildacceptSM();
}

function fnSSetup(){
    var sID = 'ssymbol' + this.sID;
    this.sID++;
    this.Symbols[sID] = new SequenceSymbol(sID,"");
   // new SequenceSymbol(this.id,sID,"");
}

function SequenceSymbol(id, code){
  this.id = id;
  this.code = code;
  this.code_bak = "";
  this.Refresh = fnSSRefresh;
  this.wasClicked = fnSSClicked;
  this.DragStop = fnSSDragStop;
  this.Dropped = fnSSDropped;

  d = DIV({'id':id,'class':'SequenceSymbol'});
  appendChildNodes('sequence',d);
  connect(id, "onclick", this, "wasClicked");

  var x = new Draggable(id,{
      endeffect: function (element) { sequence.Symbols[id].DragStop();}               
    });


  new Droppable(id, { 
        accept: ["PaletteSymbol", "Symbol", "SequenceSymbol"], 
        ondrop: function (element) { sequence.Symbols[id].Dropped(element.id);}               
      });

}


function fnSSDropped(id){
  var code="";
  if (hasElementClass(id, "PaletteSymbol")){
    code = Palette[id].code;
    var token = char2token(code.slice(0,3));
    if (token=="P") return;
  } 

  if (hasElementClass(id, "Symbol")){
    for (j in signbox.Symbols){ 
      if (j == id){
        code = signbox.Symbols[id].code;
        var token = char2token(code.slice(0,3));
        if (token=="P") return;
      }
    }
  }

  if (hasElementClass(id, "SequenceSymbol")){
    for (j in sequence.Symbols){ 
      if (j == id){
        code = sequence.Symbols[id].code;
        sequence.Symbols[id].code="";
        sequence.Symbols[id].code_bak="";
      }
    }
  }

  var last = "";
  var adv = 0;
  if (code) {
    for (id in sequence.Symbols){ 
      last = sequence.Symbols[id].code;
      if (this.id == id  || adv){
        if (last) {
          adv=1;
        } else {
          adv=0;
        }
        sequence.Symbols[id].code = code;
        sequence.Symbols[id].code_bak = "";
        sequence.Symbols[id].Refresh();
        code = last;
      }
    }

    //add another...
    if(sequence.Symbols[id].code){
      var sID = 'ssymbol' + sequence.sID;
      sequence.sID++;
      sequence.Symbols[sID] = new SequenceSymbol(sID,"");
    } 
  } 
}



  function fnSSClicked(e){
    if (this.dragging){
      this.dragging=0;
    } else {
      var code = this.code;
      this.code = this.code_bak;
      this.code_bak = code;
      this.Refresh();
    }
  }


  function fnSSRefresh(){
    if (this.code) {
      htmlSS = '<img src="glyph.php?key=' + this.code + '&size=.5' + linecolor + fillcolor + '">';
      var pre = '<table width=100% height=100%><tr><td align=middle valign=middle>';
      var post = '</td></tr></table>';
      htmlSS = pre + htmlSS + post;
    } else {
      htmlSS = "";    
    }
    
    document.getElementById(this.id).innerHTML = htmlSS;
    sequence.Rebuild();
  }


  function fnSSDragStop(e){
    setElementPosition(this.id,{x:0,y:0});
  }
  
