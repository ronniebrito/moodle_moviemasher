/**
 * SignText javascript
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
var signtext;
function loadSignText(){
//createLoggingPane();
  loadPalette();
  signbox = new SignBox();
  sequence = new Sequence();
  sequence.setup();
  connect(document,'onkeydown',signbox,'KeyDown');
  connect(document,'onkeyup',signbox,'KeyUp');
  signbox.Gridded();
//  connect(window,'onresize',Resize);
  signtext = new SignText();
  appendChildNodes("detail",signtext.div);
  loadBSW(bsw);
}
function loadBSW(bswd){
  imgChecker.check(bswd);
  callLater(.1,viewBSW,bswd);
}

var iLoadCnt = 0;
function viewBSW(bswd){
  if (imgChecker.loading()){
    callLater(.1,viewBSW,bswd);
    //loading message
    iLoadCnt++;
    itest = 1+ parseInt(iLoadCnt/10);
    if (itest==4){itest=1;iLoadCnt=0;}
    var iHTML = "Loading";
    for (var i=1; i<=itest; i++) {
        iHTML += '.';
    }
    $('signtext').innerHTML = iHTML;
    return;
  }
  $('signtext').innerHTML = "";
  if (bswd==""){
    signtext.load("0fb");
    signtext.center();
    signtext.selected='signdiv_1';
    signtext.units[0].signmaker();
  } else {
    signtext.load(bswd);
    signtext.center();
  }
}

function curBSW(){
  //add build
  var icur = signtext.getIndex(signtext.selected);
  var bswd = lane2char(signtext.units[icur].sign.lane);
  for (id in signbox.Symbols){ 
    var elemPos = elementPosition(id, 'signbox');
    code = signbox.Symbols[id].code;
    base = code.slice(0,3);
    fill = code.slice(3,4);
    rot = code.slice(4,5);
    bswd += base + fill2char(fill) + rot2char(rot) + num2hex(Math.floor(elemPos.x)) + num2hex(Math.floor(elemPos.y)); 
    if (char2token(base)=="P"){
      bswd=base + fill2char(fill) + rot2char(rot);
    }
  }
  var seq = "";
  for (id in sequence.Symbols){ 
    if (sequence.Symbols[id].code){
      code = sequence.Symbols[id].code;
      base = code.slice(0,3);
      fill = code.slice(3,4);
      rot = code.slice(4,5);
      seq += base + fill2char(fill) + rot2char(rot); 
    }
  }
  if (seq){
    bswd += '0fd' + seq;
  }
  return bswd;

}
function rebuildacceptSM(){
  //add build
  var bswd = curBSW();
  imgChecker.check(bswd);
  if (signbox.bsw != bswd){
    if (typeof(cl) != 'undefined') cl.cancel();
    signbox.bsw = bswd;
    cl = callLater(.1,resizeSignBox,bswd);
  }
}

function SignText (){
  this.w = 250;
  this.lane_offset = 100;
  this.llane = 0;
  this.rlane = 0;
  this.hpad = 20;
  this.vpad = 20;
  this.sp = 10;
  this.i = 1;
  this.sid = 'signdiv_';
  this.units = new Array();
  this.div = DIV({'id':'signtext'});

  this.selected = '';
  this.clipboard = '';

  this.setup = fnSTSetup;
  this.load = fnSTLoad;
  this.newlast = fnSTNewLast;
  this.center = fnSTCenter;
  this.signclick = fnSTSignClick;
  this.signclose = fnSTSignClose;
  this.signcopy = fnSTSignCopy;
  this.signundo = fnSTSignUndo;
  this.signredo = fnSTSignRedo;
  this.signpastebefore = fnSTSignPasteBefore;
  this.signreplace = fnSTSignReplace;
  this.signpasteafter = fnSTSignPasteAfter;
  this.signdelete = fnSTSignDelete;
  this.signbefore = fnSTSignBefore;
  this.signafter = fnSTSignAfter;
  this.signlane = fnSTSignLane;
  this.getIndex = fnSTGetIndex;
  this.updatesave = fnSTUpdateSave;
  this.setup();
  return this;
}

  function fnSTSetup(){
    var iHTML = '<table cellpadding=1><tr>';
    iHTML += '<td class="button"><div id="acceptST"></td>';
    iHTML += '<td class="button"><div id="history"></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signclose();return false;"><img border=0 src="media/Close.png"></a></td>';
    iHTML += '</tr><tr>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signbefore();return false;"><img border=0 src="media/NewBefore.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signafter();return false;"><img border=0 src="media/NewAfter.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signundo();return false;"><img border=0 src="media/Undo.png"></a></td>';
    iHTML += '</tr><tr>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signcopy();return false;"><img border=0 src="media/CopySign.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signdelete();return false;"><img border=0 src="media/DeleteSign.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signredo();return false;"><img border=0 src="media/Redo.png"></a></td>';
    iHTML += '</tr><tr>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signpastebefore();return false;"><img border=0 src="media/PasteBefore.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signpasteafter();return false;"><img border=0 src="media/PasteAfter.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signreplace();return false;"><img border=0 src="media/ReplaceSign.png"></a></td>';
    iHTML += '</tr><tr>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signlane(-1);return false;"><img border=0 src="media/leftlane.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signlane(0);return false;"><img border=0 src="media/middlelane.png"></a></td>';
    iHTML += '<td class="button"><a href="" onclick="signtext.signlane(1);return false;"><img border=0 src="media/rightlane.png"></a></td>';
    iHTML += '</tr></table>';
    $('stcommand').innerHTML = iHTML;
  }

  function fnSTGetIndex(name){
    for (var i in this.units){
      if (this.units[i].id == name) {
        return i;
      }
    }
  }

  function fnSTLoad(bswd){
    //add first sign auto...
    bswUnits = bsw2unit(bswd);
    var prevUnit = 'S';
    var thisUnit = '';
    var uID;
    for (var i in bswUnits){
      stUnit = bswUnits[i];
      uID = this.sid + this.i;
      var signdiv = new SignDiv(uID,stUnit);
      if (isPunc(signdiv.sign.first_char)){
        thisUnit='P';
      } else {
        thisUnit='S';
      }
//    if (prevUnit!=''){
      d = DIV({'id':uID + '_sp','class':'space' + prevUnit + thisUnit});
      appendChildNodes("signtext",d);
//    }
      appendChildNodes("signtext",signdiv.div);
      signdiv.emptycheck();

      connect(uID, "onclick", this, 'signclick');
      this.units.push(signdiv);
      this.i++;
      prevUnit = thisUnit;
    }
    this.newlast();
  }
  function fnSTNewLast(){
    for (var i in this.units) {}
    var bswd = this.units[i].sign.data;
    if (bswd != "0fa" && bswd != "0fb" && bswd != "0fc"){
    //taken from fnSTSignAfter
      var uID = this.sid + this.i;
      this.i++;
      var signdiv = new SignDiv(uID,"0fb");
      var d = DIV({'id':uID + '_sp','class':'spaceSS'});
      insertSiblingNodesAfter(this.units[i].id,signdiv.div);
      insertSiblingNodesAfter(this.units[i].id,d);
      connect(uID, "onclick", this, 'signclick');
      addElementClass(uID,'signempty');
      var newi = 1 + parseInt(i);
      this.units.splice(newi,0,signdiv);
      this.center();
    }
  }

  function fnSTCenter(){
    //if the center changed, so did the saved bsw...
    this.updatesave();
    //first get global left and right of center
    var cleft = "first";
    var cright = "first";
    for (var i in this.units) {
      if (cleft=="first"){
        cleft = this.units[i].sign.cx - this.units[i].sign.x - (this.units[i].sign.lane * this.lane_offset);
        cright = this.units[i].sign.w - cleft;
      }
      var sign = this.units[i].sign;
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

    //cycle through signs and place
    for (var i in this.units) {
      var sign = this.units[i].sign;
//      var dtlPos = getElementPosition(sign.id);
      pos = new Coordinates(this.vpad + sign.x + this.cleft - sign.cx + (sign.lane * this.lane_offset),0);
      setElementPosition(this.units[i].id,pos);
    }

    //now set lanes
    pos.x = this.vpad + this.cleft + 1;
    pos.y = 0;
    setElementPosition("middlelane",pos);
    var dtlDim = getElementDimensions('detail');
    setElementDimensions("middlelane",{h:dtlDim.h});
  }

  function fnSTSignClick(e){
    var src=e.src();
    sid = src.id;
    isid = this.getIndex(sid);
    //close previous if other is selected
    if (this.selected!='' && sid != this.selected){
      removeElementClass(this.selected,'signselected');
      icur = this.getIndex(this.selected);
      if (this.units[icur].editing==1){
        this.units[icur].update(curBSW());
      }
      this.units[icur].reset();
      signtext.center();
    }

    if (sid == this.selected){
//      this.selected = sid;
      if (this.units[isid].editing==2) {
        this.units[isid].signmaker();
      }
    }

    if (sid != this.selected){
      this.selected = sid;
      if (this.units[isid].editing==0) {
        this.units[isid].signtext();
      }
    }
  }

  function fnSTSignClose(){
    icur = this.getIndex(this.selected);
    if (this.units[icur].editing==1){
      this.units[icur].update(curBSW());
      this.units[icur].reset();
      this.center();
      this.units[icur].signtext();
      this.newlast();
    } else {
      this.units[icur].reset();
      this.selected='';
    }
  }

  function fnSTSignCopy(){
    if (this.selected!=""){
      icur = this.getIndex(this.selected);
      this.clipboard = this.units[icur].sign.data;
      this.units[icur].reset();
      this.selected='';
    }
  }

  function fnSTSignPasteBefore(){
    if (this.selected!="" && this.clipboard!=""){
      var icur = this.getIndex(this.selected);
      this.units[icur].reset();

      var uID = this.sid + this.i;
      this.i++;
      var signdiv = new SignDiv(uID,this.clipboard);
      var d = DIV({'id':uID + '_sp','class':'spaceSS'});
      insertSiblingNodesBefore(this.selected + '_sp',d);
      insertSiblingNodesBefore(this.selected + '_sp',signdiv.div);
      connect(uID, "onclick", this, 'signclick');
      this.units.splice(icur,0,signdiv);
      this.selected = '';
      this.center();
    }
  }

  function fnSTSignReplace(){
    if (this.selected!="" && this.clipboard!=""){
      icur = this.getIndex(this.selected);
      this.units[icur].update(this.clipboard);
      this.units[icur].reset();
      this.selected='';
      this.center();
      this.newlast();
    }
  }

  function fnSTSignPasteAfter(){
    if (this.selected!="" && this.clipboard!=""){
      var icur = this.getIndex(this.selected);
      this.units[icur].reset();
      var uID = this.sid + this.i;
      this.i++;
      var signdiv = new SignDiv(uID,this.clipboard);
      var d = DIV({'id':uID + '_sp','class':'spaceSS'});
      insertSiblingNodesAfter(this.selected,signdiv.div);
      insertSiblingNodesAfter(this.selected,d);
      connect(uID, "onclick", this, 'signclick');
      var newi = 1 + parseInt(icur);
      this.units.splice(newi,0,signdiv);
      this.selected = '';
      this.center();
      this.newlast();
    }
  }

  function fnSTSignDelete(){
    if (this.selected!=""){
      var icur = this.getIndex(this.selected);
      this.units.splice(icur,1);
      removeElement(this.selected);
      removeElement(this.selected + "_sp");
      addElementClass('stcommand','invisible');
      this.selected='';
      this.center();
  
      this.newlast();
    }
  }

  function fnSTSignUndo(){
    icur = this.getIndex(this.selected);
    this.units[icur].undo();
    this.units[icur].reset();
    this.center();
    this.units[icur].signtext();
  }

  function fnSTSignRedo(){
    icur = this.getIndex(this.selected);
    this.units[icur].redo();
    this.units[icur].reset();
    this.center();
    this.units[icur].signtext();
  }

  function fnSTSignBefore(){
    if (this.selected!=""){
      var icur = this.getIndex(this.selected);
      this.units[icur].reset();

      var uID = this.sid + this.i;
      this.i++;
      var signdiv = new SignDiv(uID,"0fb");
      var d = DIV({'id':uID + '_sp','class':'spaceSS'});
      insertSiblingNodesBefore(this.selected + '_sp',d);
      insertSiblingNodesBefore(this.selected + '_sp',signdiv.div);
      connect(uID, "onclick", this, 'signclick');
      this.units.splice(icur,0,signdiv);
      this.selected = uID;
      this.center();
      icur = this.getIndex(this.selected);
      this.units[icur].signmaker();
    }
  }

  function fnSTSignAfter(){
    if (this.selected!=""){
      var icur = this.getIndex(this.selected);
      this.units[icur].reset();

      var uID = this.sid + this.i;
      this.i++;
      var signdiv = new SignDiv(uID,"0fb");
      var d = DIV({'id':uID + '_sp','class':'spaceSS'});
      insertSiblingNodesAfter(this.selected,signdiv.div);
      insertSiblingNodesAfter(this.selected,d);
      connect(uID, "onclick", this, 'signclick');
      var newi = 1 + parseInt(icur);
      this.units.splice(newi,0,signdiv);
      this.selected = uID;
      this.center();
      icur = this.getIndex(this.selected);
      this.units[icur].signmaker();
    }
  }

  function fnSTSignLane(lane){
    if (this.selected!=""){
      var icur = this.getIndex(this.selected);
      if (isPunc(this.units[icur].sign.first_char)){return;}
      this.units[icur].sign.lane = lane;
      this.units[icur].sign.first_char = lane2char(lane);
      var bswd = this.units[icur].sign.data;
      var seq = bsw2seq(bswd);
      if (seq!=''){seq = "0fd" + seq;}
      this.units[icur].update(lane2char(lane) + bsw2cluster(bswd) + seq);
      this.center();
      this.units[icur].resize();
    }
  }
  function fnSTUpdateSave(){
    var bsw='';
    var bswd='';
    for (i in this.units){
        bswd = this.units[i].sign.data;
      if (i == this.units.length-1){
        if (bswd != "0fa" && bswd != "0fb" && bswd != "0fc"){bsw += bswd;}
      } else {
        bsw += bswd;
      }
    }
    var iHTML = '<a href="' + acceptST + 'bsw=' + bsw + '"><img border=0 src="media/Submit.png"></a>';
    $('acceptST').innerHTML = iHTML;
    var iHTML = '<a href="signtext.php?bsw=' + bsw + '"><img border=0 src="media/History.png"></a>';
    $('history').innerHTML = iHTML;
  }

/****c** display/SignDiv
 *  NAME
 *    SignDiv -- Sign Div for display
 *  USAGE
 *    iSignDiv = new SignDiv(bswd);
 *  PURPOSE
 *    create glyphogram unit in Div for display
 *  INPUTS
 *    bswd  - a string of hexidecimal chars represting BSW data for a sign or punctuation
 *  RESULT
 *    iSignDiv  - instance of class SignDiv
 *  EXAMPLE
 *    iSignDiv = new SignDiv(hello);
 ******/
function SignDiv (id,bswd){
  this.id = id;
  this.history = new Array();
  this.version = 0;
  this.history[0]= bswd;

  this.resize = fnSDResize;
  this.editing = 0;
  this.view = fnSDView;
  this.signmaker = fnSDSignMaker;
  this.signtext = fnSDSignText;
  this.clear = fnSDClear;
  this.reset = fnSDReset;
  this.update = fnSDUpdate;
  this.undo = fnSDUndo;
  this.redo = fnSDRedo;
  this.emptycheck = fnSDEmptyCheck;
  this.sign = new Sign(bswd);
  var cluster = bsw2cluster(bswd);
  this.div = DIV({'id':id,'class':'signdiv','style':{'height':this.sign.h + 'px','width':this.sign.w + 'px'}});
  this.view();
  return this;
}

  function fnSDResize(){
    if (this.editing==1){
      setElementDimensions(this.id,{w:signbox.w+73,h:signbox.h});
      var sPos = getElementPosition('signmaker','detail');
      var dtlDim = getElementDimensions('detail');
      var thsDim = getElementDimensions(this.div);
      sPos.x = sPos.x -dtlDim.w + thsDim.w; 
      sPos.y -=4;
      setElementPosition('smcommand',sPos);
      addElementClass('stcommand','invisible');
      removeElementClass(this.id,'signselected');
      removeElementClass('smcommand','invisible');
    } else {
      setElementDimensions(this.id,{w:this.sign.w,h:this.sign.h});
      addElementClass('smcommand','invisible');
      if (this.editing==2){
        var sPos = getElementPosition(this.div);
        var thsDim = getElementDimensions(this.div);
        sPos.x = sPos.x + thsDim.w + 25; 
        sPos.y -=8;
        setElementPosition('stcommand',sPos);
        removeElementClass('stcommand','invisible');
        addElementClass(this.id,'signselected');
      } else {
        addElementClass('stcommand','invisible');
        removeElementClass(this.id,'signselected');
      }
    }
  }

  function fnSDView(){
    this.editing=0;
    var bswd = this.sign.data;
    var first_char = this.sign.first_char;
    if (isPunc(first_char)) {
      pos = new Coordinates(0,0);
      //align top needed for proper placement of short images (firefox bug?)
      d = DIV({'class':'Symbol'},IMG({src:imgSrc(bswd,false),align:"top"}));
      appendChildNodes(this.div,d);
      setElementPosition(d,pos);
    } else {
      var cluster = bsw2cluster(bswd)
      if (cluster) {
        var chars = cluster.chunk(3);
      } else {
        var chars = '';
      }
      if (chars.length>2){
        //get initial values for min x,y
        for (var j=0; j<chars.length; j++) {
          sym_base = chars[j++];
          sym_fill = char2fill(chars[j++]);
          sym_rot = char2rot(chars[j++]);
          sym_char = sym_base + sym_fill + sym_rot;
          sx = hex2num(chars[j++]);
          sy = hex2num(chars[j]);
          pos = new Coordinates(sx - this.sign.x,sy-this.sign.y);
          //align top needed for proper placement of short images (firefox bug?)
          d = DIV({'class':'Symbol'},IMG({src:imgSrc(sym_char,false),align:"top"}));
          appendChildNodes(this.div,d);
          setElementPosition(d,pos);
        }
      }
    }
  }

  function fnSDSignMaker(){
    this.editing=1;

    var ih = '<div id="signmaker">';
    ih += '<div id="signboxTop"></div><div id="signboxLeft"></div>';
    ih += '<div id="signbox"></div>';
    ih += '<div id="signboxRight"></div>';
    ih += '<div id="signboxBottom"></div>';
    ih += '</div>';
    ih += '<div id="sequence"></div>';

    $(this.id).innerHTML=ih;

    signbox = new SignBox();
    sequence = new Sequence();

    connect('signbox','onmousedown',signbox,'MouseDown');
    connect('signbox','onmousemove',signbox,'MouseMove');
    connect('signbox','onmouseup',signbox,'MouseUp');
    connect('signbox','onmouseout',signbox,'MouseOut');
    signbox.Gridded();
    var cluster = '';
    var bswd = this.sign.data;
    if (bswd) {cluster = bsw2cluster(bswd);}
    if (char2token(this.sign.first_char)=="P"){
      cluster=this.sign.data + num2hex(0) + num2hex(0);
    }
    signbox.Load(cluster);
    var seq = '';
    if (bswd) {seq = bsw2seq(bswd);}
    if (seq) {sequence.Load(seq);}
    sequence.setup();
    var iHTML = '<a href="" onclick="signtext.signclose();return false;">';
    iHTML += '<img src="media/AddSentence.png" border="0"></a>';
    $('acceptSM').innerHTML = iHTML;
    if (cluster==""){rebuildacceptSM();} //needed for empty signs
    connect(signbox, 'resize', this, 'resize'); 
  }

  function fnSDSignText(){
    this.editing=2;
    this.resize();
  }

  function fnSDClear(){
    $(this.id).innerHTML='';
  }
  function fnSDReset(){
    this.clear();
    this.view();
    this.resize();
  }

  function fnSDUpdate(bswd){
    this.sign = new Sign(bswd);
    if (this.history.length>=(this.version+2)){
      this.history.splice(this.version+1,this.history.length-this.version);
    }
    this.version++;
    this.history[this.version] = bswd;
    this.emptycheck();
  }

  function fnSDUndo(){
    if (this.version==0) {return;}
    this.version--;
    var bswd = this.history[this.version];
    this.sign = new Sign(bswd);
    this.emptycheck();
  }

  function fnSDRedo(){
    if (this.version == (this.history.length-1)){return;}
    this.version++;
    var bswd = this.history[this.version];
    this.sign = new Sign(bswd);
    this.emptycheck();
  }

  function fnSDEmptyCheck(){
    var bswd = this.sign.data;
    if (bswd == "0fa" || bswd == "0fb" || bswd == "0fc"){
      addElementClass(this.id,'signempty');
    } else {
      removeElementClass(this.id,'signempty');
    }
  }
