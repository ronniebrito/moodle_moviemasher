<?php
/**
 * ISWA classes
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

/**
 * ISWA 2010 Coded Character Set class
 *
 * @package SPC
 * @subpackage ISWA 
 */
include "bsw.php";
$iswa = new ISWA();
$SymbolGroups = $iswa->getSymbolGroups();
$BaseSymbols = $iswa->getBaseSymbols();

class ISWA {
  private $subset;
  private $SymbolGroups=array();
  private $BaseSymbols=array();

  public function __construct($subset='iswa') {
    $sg_file = 'iswa/' . $subset . '.sgd';
    $bs_file = 'iswa/' . $subset . '.bsd';
    if (file_exists($sg_file) and file_exists($bs_file)){
      $this->subset = $subset;
    } else {
      $this->subset = 'iswa';
    }
    $this->LoadSymbolGroups();
    $this->LoadBaseSymbols();
  }

/**
 * Load SymbolGroup data
 *  
 * read and load rows of 10 octets
 */ 
  function LoadSymbolGroups(){
    $filename = 'iswa/' . $this->subset . '.sgd';
    $data = trim(file_get_contents($filename));
    $rows = explode("\n",$data);
    foreach ($rows as $i => $row){
      $sg = array();
      if ($i==0){
        $keys = explode("\t",$rows[$i]);
      } else {
        $values = explode("\t",$rows[$i]);
        foreach ($keys as $i => $key){
          $sg[$key] = $values[$i];
        }
        $code = $sg['code'];
        $this->SymbolGroups[$code] = $sg;
      }
    }
  }
//END Load SymbolGroup data//

/**
 * Load BaseSymbol data
 *  
 * read and load rows of 13 octets
 */
  function LoadBaseSymbols(){
    $filename = 'iswa/' . $this->subset . '.bsd';
    $data = trim(file_get_contents($filename));
    $rows = explode("\n",$data);
    foreach ($rows as $i => $row){
      $bs = array();
      if ($i==0){
        $keys = explode("\t",$rows[$i]);
      } else {
        $values = explode("\t",$rows[$i]);
        foreach ($keys as $i => $key){
          $bs[$key] = $values[$i];
        }
        $code = $bs['code'];
        $this->BaseSymbols[$code] = $bs;
      }
    }
  }
//END Load BaseSymbol data//

/**
 * Get All SymbolGroup
 *  
 * return array
 */
  function getSymbolGroups(){
    return $this->SymbolGroups;
  }
//END Get All SymbolGroup//

/**
 * Get 1 SymbolGroup
 *  
 * return array
 */
  function getSymbolGroup($group){
    return $this->SymbolGroups[$group];
  }
//END Get 1 SymbolGroup//

/**
 * Get All BaseSymbol
 *  
 * return array
 */
  function getBaseSymbols(){
    return $this->BaseSymbols;
  }
//END Get All BaseSymbol//

/**
 * Get 1 BaseSymbol
 *  
 * return array
 */
  function getBaseSymbol($base){
    return $this->BaseSymbols[$base];
  }
//END Get 1 BaseSymbol//

/**
 * id to key 
 * symbol id to symbol key 
 */
  function id2key($id){
    $sidparts = explode('-',$id);
    if (count($sidparts)==6){
      $iC = intval($sidparts[0]);
      $iG = intval($sidparts[1]);
      $iB = intval($sidparts[2]);
      $iV = intval($sidparts[3]);
      $iF = intval($sidparts[4]);
      $iR = intval($sidparts[5]);
      if ($iF>6){return;}//fills can not be greater than 6
      if ($iR>16){return;}//rotations can not be greater than 16
      $offset = ($iR-1) + (($iF-1) * 16);
    } else if (count($sidparts)==4){
      $iC = intval($sidparts[0]);
      $iG = intval($sidparts[1]);
      $iB = intval($sidparts[2]);
      $iV = intval($sidparts[3]);
      $iF = 1;
      $iR = 1;
      $offset=0;
    } else if (count($sidparts)==2){ 
      $iC = intval($sidparts[0]);
      $iG = intval($sidparts[1]);
      $iB = 1;
      $iV = 1;
      $iF = 1;
      $iR = 1;
      $offset=0;
    }
//find the symbol group
    foreach ($this->SymbolGroups as $group=>$sg){
      $dgroup = hexdec($group);
      if ($sg['sid_c']==$iC and $sg['sid_g']==$iG){
        for($base=$dgroup;$base<($dgroup+($sg['bases']));$base+=1){
          $hbase = dechex($base);
          $bs = $this->getBaseSymbol($hbase);
          if ($bs['sid_b']==$iB and $bs['sid_v']==$iV){
            $key = $hbase . dechex($iF-1) . dechex($iR-1);
            return $key;
            break;
          }
        }
      } 
    }
    if (!$this->validkey($key)) {return;}
    return $key;
  }  
//END id to name//

/**
 * key to id
 * symbol key to symbol id
 */
  function key2id($key,$parts=6){
    $len = strlen($key);
    if ($len<3){ return;}//error
    $hcode = substr($key,0,3);
    $bs = $this->BaseSymbols[$hcode];
    $group = $bs['group'];
    $sg = $this->SymbolGroups[$group];
    $sid = array();
    $sid[]=$sg['sid_c'];
    $sid[]=$sg['sid_g'];
    $sid[]=$bs['sid_b'];
    $sid[]=$bs['sid_v'];

    $hf = 0;
    if ($len>3) $hf = substr($key,3,1);
    $hr = 0;
    if ($len>4) $hr = substr($key,4,1);

    $sid[] = hexdec($hf)+1;
    $sid[] = hexdec($hr)+1;

    $pad = array(2,2,3,2,2,2);
    foreach ($sid as $i=>$num){
      $sid[$i]=str_pad($num,$pad[$i],"0",STR_PAD_LEFT);
    }
    $sid = array_slice($sid,0,$parts);    

    return implode('-',$sid);
  }  
//END key to id//

/**
 * base to group
 */
  function base2group($base){
    $bs = $this->BaseSymbols[$base];
    $group = $bs['group'];
    return $group;
  }
//END base to group

/**
 * valid key check
 */
  function validkey($key){
    $len = strlen($key);
    if ($len<3){ return ;}//error
    $hcode = substr($key,0,3);

    $bs = $this->BaseSymbols[$hcode];
    if (!$bs){return;}

    $df = 0;
    if ($len>3) $df = hexdec(substr($key,3,1));
    $dr = 0;
    if ($len>4) $dr = hexdec(substr($key,4,1));
    //now for binary algebra!
    $fillbin = pow(2,$df);
    if ($fillbin & $bs['fills']){$bFill = true;}
    $rotbin = pow(2,$dr);
    if ($rotbin & $bs['rots']){ $bRot = true;}
    return $bFill and $bRot;
  }
//END valid key check//

}

?>
