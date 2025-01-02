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
/*------------------------------------------------------------------------
    File        : ObjectStreamConstants
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 17 14:18:12 EST 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Util.ObjectStreamConstants.

class OpenEdge.Core.Util.ObjectStreamConstants final: 
    
    define public static property /* BYTE */ PROTOCOL_VERSION_1    as integer init 1       no-undo get.
    
    /* SC_ = stream code */
    define public static property /* BYTE */ SC_BLOCK_DATA         as integer init 8       no-undo get.
    define public static property /* BYTE */ SC_EXTERNALIZABLE     as integer init 4       no-undo get.
    define public static property /* BYTE */ SC_SERIALIZABLE       as integer init 2       no-undo get.
    define public static property /* BYTE */ SC_WRITE_METHOD       as integer init 1       no-undo get.

    
    define public static property /* STRING */ STREAM_MAGIC          as character init 'PABLO' no-undo get.
    define public static property /* BYTE */ STREAM_VERSION        as integer  init 1       no-undo get.
    
    /* TC_ = TypeCode_ */
/*    define public static property /* BYTE */ TC_BASE               as integer init 112     no-undo get.*/
/*    define public static property /* BYTE */ TC_BLOCKDATALONG      as integer init 122     no-undo get.*/
/*    define public static property /* BYTE */ TC_CLASS              as integer init 118     no-undo get.*/
/*    define public static property /* BYTE */ TC_EXCEPTION          as integer init 123     no-undo get.*/
/*    define public static property /* BYTE */ TC_MAX                as integer init 125     no-undo get.*/
/*    define public static property /* BYTE */ TC_PROXYCLASSDESC     as integer init 125     no-undo get.*/
/*    define public static property /* BYTE */ TC_RESET              as integer init 121     no-undo get.*/
    
    define public static property /* BYTE */ TC_ARRAY              as integer init 117     no-undo get.
    define public static property /* BYTE */ TC_BLOCKDATA          as integer init 119     no-undo get.
    define public static property /* BYTE */ TC_METADATA           as integer init 114     no-undo get.
    define public static property /* BYTE */ TC_DATASET            as integer init 121     no-undo get.
    define public static property /* BYTE */ TC_DECIMAL            as integer init 118     no-undo get.
    define public static property /* BYTE */ TC_ENDBLOCKDATA       as integer init 120     no-undo get.
/*    define public static property /* BYTE */ TC_INVALIDOBJECT      as integer init 112     no-undo get.*/
/*    define public static property /* BYTE */ TC_LONGSTRING         as integer init 124     no-undo get.*/
    define public static property /* BYTE */ TC_NULL               as integer init 112     no-undo get.
    define public static property /* BYTE */ TC_OBJECT             as integer init 115     no-undo get.
    define public static property /* BYTE */ TC_ENUM               as integer init 116     no-undo get.
    define public static property /* BYTE */ TC_REFERENCE          as integer init 113     no-undo get.
/*    define public static property /* BYTE */ TC_STRING             as integer init 116     no-undo get.*/
    define public static property /* BYTE */ TC_TABLE              as integer init 122     no-undo get.
    define public static property /* BYTE */ TC_VALUE              as integer init 123     no-undo get.
    
    /* Sizes always in BYTES */
    define public static property SIZE_BYTE     as integer init 1 no-undo get.
    define public static property SIZE_SHORT    as integer init 2 no-undo get.
    define public static property SIZE_USHORT   as integer init 2 no-undo get.
    define public static property SIZE_LONG     as integer init 4 no-undo get.
    define public static property SIZE_ULONG    as integer init 4 no-undo get.
    define public static property SIZE_INT64    as integer init 8 no-undo get.
    define public static property SIZE_FLOAT    as integer init 4 no-undo get.
    define public static property SIZE_DOUBLE   as integer init 8 no-undo get.
    
    define public static property REFTYPE_OBJECT as integer init 1 no-undo get.
    define public static property REFTYPE_TYPE   as integer init 2 no-undo get.
    
    define public static property SERIALIZABLE_IFACE_TYPE   as character init 'OpenEdge.Core.Util.ISerializable' no-undo get.    
    define public static property EXTERNALIZABLE_IFACE_TYPE as character init 'OpenEdge.Core.Util.IExternalizable' no-undo get.
        
    define public static property EXTERNALIZABLE_METHOD_READOBJECT as character init 'ReadObject' no-undo get.
    define public static property EXTERNALIZABLE_METHOD_WRITEOBJECT as character init 'WriteObject' no-undo get.
    define public static property EXTERNALIZABLE_METHOD_WRITETABLE as character init 'WriteTable' no-undo get.
    define public static property EXTERNALIZABLE_METHOD_WRITEDATASET as character init 'WriteDataset' no-undo get.
    define public static property EXTERNALIZABLE_METHOD_WRITEENUM as character init 'WriteEnum' no-undo get.
    define public static property EXTERNALIZABLE_METHOD_READENUM as character init 'ReadEnum' no-undo get.
    
    define public static property SIZE_INDEX_ARRAY as integer init 20 no-undo get.
    
    method static public character ToString (piObjectStreamConstant as integer):
        define variable cString as character no-undo.
        
        case piObjectStreamConstant:
            /* SC_ constants */
            when ObjectStreamConstants:SC_BLOCK_DATA then cString ='SC_BLOCK_DATA'.
            when ObjectStreamConstants:SC_EXTERNALIZABLE then cString ='SC_EXTERNALIZABLE'.
            when ObjectStreamConstants:SC_SERIALIZABLE then cString ='SC_SERIALIZABLE'.
            when ObjectStreamConstants:SC_WRITE_METHOD then cString ='SC_WRITE_METHOD'.
            /* TC_ constants */
            when ObjectStreamConstants:TC_DECIMAL then cString ='TC_DECIMAL'.
            when ObjectStreamConstants:TC_VALUE then cString ='TC_VALUE'.
            when ObjectStreamConstants:TC_ARRAY then cString ='TC_ARRAY'.
            when ObjectStreamConstants:TC_BLOCKDATA then cString ='TC_BLOCKDATA'.
            when ObjectStreamConstants:TC_METADATA then cString ='TC_METADATA'.
            when ObjectStreamConstants:TC_DATASET then cString ='TC_DATASET'.
            when ObjectStreamConstants:TC_ENDBLOCKDATA then cString ='TC_ENDBLOCKDATA'.
/*            when ObjectStreamConstants:TC_LONGSTRING then cString ='TC_LONGSTRING'.*/
            when ObjectStreamConstants:TC_NULL then cString ='TC_NULL'.
            when ObjectStreamConstants:TC_OBJECT then cString ='TC_OBJECT'.
            when ObjectStreamConstants:TC_ENUM then cString ='TC_ENUM'.
            when ObjectStreamConstants:TC_REFERENCE then cString ='TC_REFERENCE'.
/*            when ObjectStreamConstants:TC_STRING then cString ='TC_STRING'.*/
            when ObjectStreamConstants:TC_TABLE then cString ='TC_TABLE'.
            /* REFTYPE_  constants */
            when ObjectStreamConstants:REFTYPE_OBJECT then cString ='REFTYPE_OBJECT'.
            when ObjectStreamConstants:REFTYPE_TYPE then cString ='REFTYPE_TYPE'.
        end case.
        
        return cString.
    end method.    
end class.
