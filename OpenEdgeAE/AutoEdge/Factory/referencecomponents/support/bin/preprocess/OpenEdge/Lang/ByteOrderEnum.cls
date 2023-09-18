/** ****************************************************************************
  Copyright 2012 Progress Software Corporation
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
    http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
**************************************************************************** **/
/** ------------------------------------------------------------------------
    File        : ByteOrderEnum
    Purpose     : Enumeration of byte-order 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 21 09:40:59 EST 2009
    Notes       : * Taken from ABL documentation
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.ByteOrderEnum final inherits EnumMember:

    define public static property Default       as ByteOrderEnum no-undo get. private set.
    define public static property HostByteOrder as ByteOrderEnum no-undo get. private set.
    define public static property BigEndian     as ByteOrderEnum no-undo get. private set.
    define public static property LittleEndian  as ByteOrderEnum no-undo get. private set.
    
    constructor static ByteOrderEnum():
        ByteOrderEnum:HostByteOrder = new ByteOrderEnum(host-byte-order, 'host-byte-order').
        ByteOrderEnum:BigEndian = new ByteOrderEnum(big-endian, 'big-endian').
        ByteOrderEnum:LittleEndian = new ByteOrderEnum(little-endian, 'little-endian').
        
        ByteOrderEnum:Default = ByteOrderEnum:HostByteOrder.
    end constructor.
        
    constructor public ByteOrderEnum ( input piValue as integer, input pcName as character ):
        super (input piValue, input pcName).
    end constructor.
    
    method static public ByteOrderEnum EnumFromString(pcByteOrder as char):
        define variable oMember as ByteOrderEnum no-undo.
        
        case pcByteOrder:
            when ByteOrderEnum:HostByteOrder:ToString() then oMember = ByteOrderEnum:HostByteOrder.
            when ByteOrderEnum:BigEndian:ToString() then oMember = ByteOrderEnum:BigEndian.
            when ByteOrderEnum:LittleEndian:ToString() then oMember = ByteOrderEnum:LittleEndian.
        end case.
        
        return oMember.        
    end method.
    
    method static public ByteOrderEnum EnumFromValue(piByteOrder as integer):
        define variable oMember as ByteOrderEnum no-undo.
        
        case piByteOrder:
            when ByteOrderEnum:HostByteOrder:Value then oMember = ByteOrderEnum:HostByteOrder.
            when ByteOrderEnum:BigEndian:Value then oMember = ByteOrderEnum:BigEndian.
            when ByteOrderEnum:LittleEndian:Value then oMember = ByteOrderEnum:LittleEndian.
        end case.
        
        return oMember.
    end method.

end class.
