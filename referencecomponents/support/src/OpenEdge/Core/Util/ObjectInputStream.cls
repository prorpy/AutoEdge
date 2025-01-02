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
    File        : ObjectInputStream
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Nov 13 14:29:30 EST 2009
    Notes       : * The Read<type>() methods have output parameters because they 
                    cater for both vectors and scalars. The alternative is to
                    have  Read<type>Array() methods that return the valid type.
                  * For the protocol definition, see 
                    https://wiki.progress.com/display/OEBP/Object+Serialization+Protocol
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Core.Util.ObjectStreamConstants.
using OpenEdge.Core.Util.ObjectInputError.
using OpenEdge.Lang.SortDirectionEnum.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Lang.Collections.ObjectStack.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.IOModeEnum.
using OpenEdge.Lang.EnumMember.

using Progress.Lang.ParameterList.
using Progress.Lang.Error.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.Core.Util.ObjectInputStream
        implements IObjectInput:
    
    define private variable mmStreamMptr as memptr no-undo.
    define private variable miCursor as integer no-undo.
    define private variable miDepth as integer  no-undo.
    define private variable moTopLevel as Object no-undo.
    define private variable moCurrentType as class Class no-undo.
    define private variable moTypeStack     as ObjectStack no-undo.
    define private variable miSessionDecimalPoint as integer no-undo.
    define private variable miSessionNumericSeparator as integer no-undo.
    define private variable moReadObjParam as ParameterList no-undo.
    define private variable moObjectInputError as ObjectInputError no-undo.
    
    define private temp-table StreamReference no-undo
        field ReferenceType as integer  /* ObjectStreamConstants:REFTYPE_ */
        field Reference as Object       /* object id for PLO or PLC */
        field Position as integer       /* position in stream */
        index idx1 as primary unique ReferenceType Position
        .
    
    constructor public ObjectInputStream():
        Reset().
    end constructor.
        
    destructor public ObjectInputStream():
        this-object:Clear().
    end destructor.
    
    method protected void Clear():
        define buffer lbRef for StreamReference.
        
        empty temp-table lbRef.        
        moReadObjParam = ?.
        moCurrentType = ?.
        moTopLevel = ?.
        moObjectInputError = ?.
        /* this is the only time we should hard-code a 1; otherwise use ObjectStreamConstants:SIZE_BYTE */
        miCursor = 1.
        set-size(mmStreamMptr) = 0.
    end method.
    
    method public void Initialize():
        /* Create on parameter list object that 
           we'll reuse. */
        moReadObjParam = new ParameterList(1).
        moReadObjParam:SetParameter(1,
                                    substitute(DataTypeEnum:Class:ToString(), this-object:GetClass():TypeName),
                                    IOModeEnum:Input:ToString(),
                                    this-object).
    end method.
    
    /** Resets/reinitialises the input */      
    method public void Reset():
        this-object:Clear().
        Initialize().
    end method.
    
    @todo(task="refactor", action="merg input CHAR and input LONGCHAR to one; disambiguate with params? names?").
    method public void Read(pcStream as longchar):
        define variable mStream as memptr no-undo.
        
        set-byte-order(mStream) = ByteOrderEnum:BigEndian:Value.
                        
        copy-lob from pcStream to mStream.
        this-object:Read(mStream).
                
        /* mStream is a temp-var so clean up. the byte stream
           has been copied to this class' mmStreamMptr for internal use. */
        finally:
            set-size(mStream) = 0.
        end finally.
    end method.
    
    method public void Read(input pcFile as character):
        define variable mStream as memptr no-undo.
        
        set-byte-order(mStream) = ByteOrderEnum:BigEndian:Value.
                
        copy-lob from file pcFile to mStream.
        this-object:Read(mStream).
        
        /* mStream is a temp-var so clean up. the byte stream
           has been copied to this class' mmStreamMptr for internal use. */
        finally:
            set-size(mStream) = 0.
        end finally.
    end method.
    
    method public void Read(pmStream as memptr):
        if get-byte-order(pmStream) ne ByteOrderEnum:BigEndian:Value then
            ThrowError(ObjectInputError:BYTE_ORDER,
                           ByteOrderEnum:BigEndian:ToString(),
                           miCursor - ObjectStreamConstants:SIZE_BYTE).
        
        mmStreamMptr = pmStream.
        
        ReadStreamHeader().
        
        /* If anything (not just ObjectInputError) happens, clean up! */ 
        catch oError as Error:
            this-object:Clear().
            /* pass on the Error */
            undo, throw oError.
        end catch.
    end method.
    
    method protected void ReadStreamHeader():
        if ReadString() ne ObjectStreamConstants:STREAM_MAGIC then
            ThrowError(ObjectInputError:VALUE,
                           ObjectStreamConstants:STREAM_MAGIC,
                           -1).
        
        if ReadByte() ne ObjectStreamConstants:STREAM_VERSION then
            ThrowError(ObjectInputError:STREAM_VERSION,
                           string(ObjectStreamConstants:STREAM_VERSION),
                           miCursor - ObjectStreamConstants:SIZE_BYTE).
        
        miSessionDecimalPoint = ReadByte().
        miSessionNumericSeparator = ReadByte().
        
        /* Is this the right Proversion? */
        if ReadString() ne proversion then
            ThrowError(ObjectInputError:ABL_VERSION,
                           proversion,
                           miCursor - ObjectStreamConstants:SIZE_BYTE).
    end method.
    
    method public void DefaultReadObject():
        define variable iStackLoop as integer no-undo.
        define variable iMemberLoop as integer no-undo.
        define variable iStackSize as integer no-undo.
        define variable iMembers as integer no-undo.
        define variable oType as class Class no-undo.
        
        /* Members are written out from the least-derived ("highest") class
           to the most-derived ("lowest", aka poIn) class. This way values
           that are set at a less-derived class will be overridden and 
           correct. */
        iStackSize = moTypeStack:Size.
        
        do iStackLoop = 1 to iStackSize:
            oType = cast(moTypeStack:Pop(), Class).
            
            /* get this value from somewhere */
            iMembers = 0.
            
            /* does nothing (yet) because of a lack of reflection on members */
            do iMemberLoop = 1 to iMembers:
                /* get props from type */
                /* retrieve value from input object 
                o:<Member> = Read<type>().
                */
            end.
        end.
    end method.
    
    method public Object ReadObject():
        define variable oObj as Object no-undo.            
        define variable oClass as class Class no-undo.
        define variable iRepositionTo as integer no-undo.
        define variable lInvoke as logical no-undo.
        
        /* The first Byte must be one of TC_OBJECT, TC_ENUM or TC_NULL. */        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                assign oObj = ?.            
            when ObjectStreamConstants:TC_ENUM then
            do:
                miCursor = miCursor - ObjectStreamConstants:SIZE_BYTE.
                AddWarning(ObjectInputError:API_CALL,
                           ObjectStreamConstants:EXTERNALIZABLE_METHOD_READENUM,
                           miCursor).
                oObj = ReadEnum().
            end.    /* enum */
            when ObjectStreamConstants:TC_OBJECT then
            /* The TC_OBJECT byte is always followed by one of
               - TC_METADATA: contains class desc and values (if the object is serializable/externalizable)
               - TC_REFERENCE: a pointer (typically backwards) to a previously-defined TC_OBJECT location. */
            case ReadByte():
                when ObjectStreamConstants:TC_REFERENCE then
                do:
                    iRepositionTo = ReadInt().
                    if iRepositionTo eq ? then
                        ThrowError(ObjectInputError:VALUE,
                                       DataTypeEnum:Integer:ToString(),
                                       miCursor - ObjectStreamConstants:SIZE_LONG).
                    
                    oObj = GetReference(ObjectStreamConstants:REFTYPE_OBJECT,
                                        iRepositionTo + ObjectStreamConstants:SIZE_BYTE).
                    if not valid-object(oObj) then
                        ThrowError(ObjectInputError:CLASS_REFERENCE,
                                       'reference',
                                       miCursor - ObjectStreamConstants:SIZE_LONG).
                end.
                when ObjectStreamConstants:TC_METADATA then
                    /* Now we have a pointer to a TC_METADATA byte . We think.
                       Go to the reference position, and then back one, since we want 
                       to make double-sure that we have the TC_METADATA.
                       
                       We're going to re-read this byte (yeah, wasteful, but
                       makes coding more consistent). */
                    assign miCursor = miCursor - ObjectStreamConstants:SIZE_BYTE
                           oObj = ReadObjectInternal().
                otherwise
                    ThrowError(ObjectInputError:BYTE,
                                   ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                                   + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_REFERENCE),
                                   miCursor - ObjectStreamConstants:SIZE_BYTE).
            end case.   /* byte following the TC_OBJECT byte */
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ENUM)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_OBJECT),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.   /* first byte TC_ENUM or TC_OBJECT */
        
        return oObj.
    end method.
    
    method protected void RegisterReference (piType as int,
                                        piPos as int,
                                        poReference as Object):
        def buffer bRef for StreamReference.
                                
        find bRef where
             bRef.ReferenceType = piType and
             bRef.Position = piPos
             no-error.
        if not available bRef then
        do:
            create bRef.
            assign bRef.ReferenceType = piType
                   bRef.Reference = poReference
                   bRef.Position = piPos.
        end.
    end method.
    
    method protected Object GetReference(piType as int,                                          
                                         piPos as int):
        define variable oObj as Object no-undo.                                             
        def buffer bRef for StreamReference.
        
        find bRef where
             bRef.ReferenceType = piType and
             bRef.Position = piPos
             no-error.
        if available bRef then
            oObj = bRef.Reference.
        
        return oObj.
    end method.    
    
    method protected Object ReadObjectInternal():
        define variable oClass as class Class no-undo.
        define variable oObj as Object no-undo.
        define variable iPosition as integer no-undo.
        
        /* the cursor is currently pointing - should be anyway - at the TC_METADATA
           byte marker referring to an object. Keep this for storate in the StreamReference 
           table. */
        assign iPosition = miCursor
               miDepth = 0
               moTypeStack = new ObjectStack()
               /* Find the type */
               oClass = ReadClassDesc()
               /* Create the instance */
               oObj = oClass:New().
        
        /* At this point we have a valid object for adding to the references */
        RegisterReference(ObjectStreamConstants:REFTYPE_OBJECT, iPosition, oObj).
        
        if not valid-object(moTopLevel) then
            moTopLevel = oObj.
        
        /* TC_NULL separates the meta from the data, as it were. */
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_NULL).
        
        /* InvokeReadObject() will determine what calls to make - ReadObject()
           or DefaultReadObject etc. */
        InvokeReadObject(oObj).
        moTypeStack = ?.
        
        /* there's never one written at the end of the top-level object (for space) */
        if oObj ne moTopLevel then
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
        
        return oObj.
    end method.
        
    method protected class Class ReadClassDesc():
        define variable cTypeName as char no-undo.
        define variable oClass as class Class no-undo.
        define variable iByteMarker as integer no-undo.
        define variable iNumFields as int no-undo.
        define variable iTypeFlags as int no-undo.
        define variable cMD5 as character no-undo.
        define variable iCursor as integer no-undo.
        
        /* We're either at the top of the hierarcy (TC_ENDBLOCKDATA), or not (TC_METADATA).
           If neither, then something's wrong. */
        case ReadByte():
            when ObjectStreamConstants:TC_ENDBLOCKDATA then
                /* Unwind the class depth stack, so we know that we
                   need to make another ReadClassDesc() call. Typically,
                   we're in the process of unwinding, so this call will 
                   result in another TC_ENDBLOCKDATA being found, until
                   we're at the bottom of the pile. */
                miDepth = miDepth - 1.
            when ObjectStreamConstants:TC_METADATA then
            do:
                miDepth = miDepth + 1.
                cTypeName = ReadString().
                oClass = Class:GetClass(cTypeName).
                moTypeStack:Push(oClass).
                
                rcode-info:file-name = replace(cTypeName, '.', '/').
                /* Keep cursor just in case MD% doesn't match. */                
                iCursor = miCursor.
                cMD5 = ReadString().
                if cMD5 eq ? then
                    AddWarning(ObjectInputError:MD5_VALUE,
                               'a valid value',
                               iCursor).
                else
                if cMD5 ne rcode-info:md5-value then
                    ThrowError(ObjectInputError:MD5_VALUE,
                                   rcode-info:md5-value,
                                   iCursor).
                
                iTypeFlags = ReadByte().
                
                /* Serializable */
                if IsFlag(iTypeFlags, ObjectStreamConstants:SC_SERIALIZABLE) then
                do:
                    /* read property names, types. */
                end.
            end.    /* TC_METADATA */
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ENDBLOCKDATA)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
        
        /* Up/down we go ... */
        if miDepth ne 0 then
        /* oParentClass = */ ReadClassDesc().
        
        return oClass.
    end method.
    
    method public Object extent ReadObjectArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var oObj as Object extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(oObj) = iExtent.
                do iLoop = 1 to iExtent:
                    oObj[iLoop] = ReadObject().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                
        return oObj.
    end method.
    
    method protected void InvokeReadObject(poIn as Object):
        moCurrentType = poIn:GetClass().
        
        if moCurrentType:IsA(ObjectStreamConstants:SERIALIZABLE_IFACE_TYPE) then
            DefaultReadObject().
        /* A type could be Externalizable and Serializable, so no ELSE */
        if moCurrentType:IsA(ObjectStreamConstants:EXTERNALIZABLE_IFACE_TYPE) then
            moCurrentType:Invoke(poIn,
                          ObjectStreamConstants:EXTERNALIZABLE_METHOD_READOBJECT,
                          moReadObjParam).

        /* If we get here, then the class being serialized doesn't
           re-throw any of the ObjectInputErrors it receives.
           
           We don't want to continue, since there was an error, so 
           we abort. */
        if valid-object(moObjectInputError) then
            undo, throw moObjectInputError.
        
        moCurrentType = ?.                          
    end method.
    
    method public EnumMember ReadEnum():
        define variable oEnum as EnumMember no-undo.
        define variable iValue as integer no-undo.
        define variable cName as character no-undo.
        define variable cType as character no-undo.
        define variable iPos as integer no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                oEnum = ?.
            when ObjectStreamConstants:TC_ENUM then
            do:
                /* keep in case of error */
                iPos = miCursor - ObjectStreamConstants:SIZE_BYTE.
                
                cType = ReadChar().
                iValue = ReadInt().
                cName = ReadChar().
                
                /* value trumps name */
                if iValue ne ? then
                    oEnum = cast(dynamic-invoke(cType, 'EnumFromValue', iValue), EnumMember) no-error.
                else
                if cName ne '' and cName ne ? then
                    oEnum = cast(dynamic-invoke(cType, 'EnumFromString', cName), EnumMember) no-error.
                
                if not valid-object(oEnum) then
                    ThrowError(ObjectInputError:VALUE,
                               substitute('valid EnumMember from Type &1, Name &2, Value &3 and EnumFromString() or EnumFromValue() method',
                                           cType, cName, iValue),
                               iPos).
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ENUM),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
        
        return oEnum. 
    end method.
    
    /**  READ ABL PRIMITIVE DATA TYPES **/
    method public char ReadChar():
        return ReadString().
    end method.
        
    method public char extent ReadCharArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var cVal as char extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(cVal) = iExtent.
                do iLoop = 1 to iExtent:
                    cVal[iLoop] = ReadChar().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                
        return cVal.
    end method.
        
    method public longchar ReadLongChar():
        return ReadLongString().
    end method.
    
    method public longchar extent ReadLongCharArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var cVal as longchar extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(cVal) = iExtent.
                do iLoop = 1 to iExtent:
                    cVal[iLoop] = ReadChar().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                
        return cVal.
    end method.
    
    method public int ReadInt():
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                return ?.
            when ObjectStreamConstants:TC_VALUE then
                return ReadLong().
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public int extent ReadIntArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var iVal as int extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(iVal) = iExtent.
                do iLoop = 1 to iExtent:
                    iVal[iLoop] = ReadInt().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.

        return iVal.
    end method.

    method public int64 ReadInt64():
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                return ?.
            when ObjectStreamConstants:TC_VALUE then
                return int64(ReadDouble()).
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public int64 extent ReadInt64Array():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var iVal as int64 extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(iVal) = iExtent.
                do iLoop = 1 to iExtent:
                    iVal[iLoop] = ReadInt64().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.

        return iVal.
    end method.
    
    method public decimal ReadDecimal():
        /* Decimals are written as strings, since there are no good
           PUT-* analogs for them. They're always written in American
           numeric format, without any numeric separators.
           
           In case anyone cares, we keep the num-dec-point in the stream header.           
          */
        return decimal(replace(ReadString(), '.', session:numeric-decimal-point)).
    end method.
    
    method public dec extent ReadDecimalArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var dVal as decimal extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(dVal) = iExtent.
                do iLoop = 1 to iExtent:
                    dVal[iLoop] = ReadDecimal().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.

        return dVal.
    end method.
    
    method public date ReadDate():
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                return ?.
            when ObjectStreamConstants:TC_VALUE then
                return date(ReadLong()).
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public date extent ReadDateArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var tVal as date extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(tVal) = iExtent.
                do iLoop = 1 to iExtent:
                    tVal[iLoop] = ReadDate().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.

        return tVal.
    end method.

    method public datetime ReadDateTime():
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                return ?.
            when ObjectStreamConstants:TC_VALUE then
                return datetime(date(ReadLong()), ReadLong()).
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public datetime extent ReadDateTimeArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var tVal as datetime extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(tVal) = iExtent.
                do iLoop = 1 to iExtent:
                    tVal[iLoop] = ReadDateTime().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                
        return tVal.
    end method.
    
    method public datetime-tz ReadDateTimeTz():
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                return ?.
            when ObjectStreamConstants:TC_VALUE then
                return datetime-tz(date(ReadLong()), ReadLong(), ReadLong()).
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public datetime-tz extent ReadDateTimeTzArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var tVal as datetime-tz extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(tVal) = iExtent.
                do iLoop = 1 to iExtent:
                    tVal[iLoop] = ReadDateTimeTz().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                
        return tVal.
    end method.
    
    method public log ReadLogical():
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                return ?.
            when ObjectStreamConstants:TC_VALUE then
                return logical(ReadByte()).
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_METADATA)
                               + ', ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public log extent ReadLogicalArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var lVal as logical extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(lVal) = iExtent.
                do iLoop = 1 to iExtent:
                    lVal[iLoop] = ReadLogical().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
        
        return lVal.
    end method.

    method public rowid ReadRowid():
        return to-rowid(ReadString()).
    end method.

    method public rowid extent ReadRowidArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var rVal as rowid extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(rVal) = iExtent.
                do iLoop = 1 to iExtent:
                    rVal[iLoop] = ReadRowid().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                    
        return rVal.
    end method.

    method public recid ReadRecid():
        def var rVal as recid no-undo.
        rVal = ReadInt().
        
        return rVal.
    end method.
    
    method public recid extent ReadRecidArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var rVal as recid extent no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                . /* do nothing */
            when ObjectStreamConstants:TC_ARRAY then
            do:
                iExtent = ReadByte().
                extent(rVal) = iExtent.
                do iLoop = 1 to iExtent:
                    rVal[iLoop] = ReadRecid().
                end.
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).                    
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' +  ObjectStreamConstants:ToString(ObjectStreamConstants:TC_ARRAY),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
        
        return rVal.
    end method.
    
    method public void ReadDataset(input-output dataset-handle phOut):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        define variable iByte as integer no-undo.
        
        iByte = ReadByte().
        case iByte:
            when ObjectStreamConstants:TC_NULL then
                phOut = ?.
            when ObjectStreamConstants:TC_OBJECT then
            do:
                phOut = ReadDatasetDesc(phOut).
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_NULL).
                
                /* buffer data */
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).        
                    
                iMax = ReadByte().
                do iLoop = 1 to iMax:
                    ReadBufferData(phOut:get-buffer-handle(iLoop)).
                end.
                /* buffer */
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
                
                /* dataset */
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_OBJECT),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
                
        end case.
    end method.
    
    method protected handle ReadDatasetDesc(phIn as handle):
        define variable hDataset as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cName as character no-undo.
        define variable lBuildDataset as logical no-undo.
        
        /* this is always written */
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_METADATA).                
        cName = ReadString().
        lBuildDataset = ReadLogical().
        
        if valid-handle(phIn) then
        do:
            if not DataTypeEnum:Dataset:Equals(phIn:type) then  
                ThrowError(ObjectInputError:TYPE,
                               DataTypeEnum:Dataset:ToString(),
                               miCursor).
            
            /* extra check for name. */
            if phIn:name ne cName then
                ThrowError(ObjectInputError:VALUE, cName, miCursor).
            
            /* if passed-in dataset isn't dynamic, throw an error. the values should
               match (although crc-value may differ if the source and target differ and
               so we'd never get here). */
            if phIn:dynamic ne lBuildDataset then
                ThrowError(ObjectInputError:VALUE,
                        'dynamic=' + string(lBuildDataset),
                        miCursor).
            
            hDataset = phIn.                                        
        end.    /* valid-handle */

        if lBuildDataset then
        do:
            create dataset hDataset.
            hDataset:name = cName.
            
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).
                    
            /* buffers */
            iMax = ReadByte().
            do iLoop = 1 to iMax:
                hDataset:add-buffer(ReadTableDesc(?)).
            end.
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
                        
            /* relations */
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).
            
            iMax = ReadByte().
            do iLoop = 1 to iMax:
                ReadDatasetRelation(hDataset).
            end.
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
        
        return hDataset:handle.
    end method.
    
    method protected handle ReadTableDesc(phIn as handle):
        define variable iLoop as integer no-undo.
        define variable iLoop2 as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iIndexEntries as integer no-undo.
        define variable iCursor as integer no-undo.
        define variable hTable as handle no-undo.
        define variable cTableName as char no-undo.
        define variable cIndexName as char no-undo.
        define variable cIndex as character no-undo.
        define variable lBuildTable as logical no-undo.
        
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_METADATA).        
        cTableName = ReadString().
        lBuildTable = ReadLogical().
        
        if valid-handle(phIn) then
        do:
            if not DataTypeEnum:TempTable:Equals(phIn:type) then  
                ThrowError(ObjectInputError:TYPE,
                               DataTypeEnum:TempTable:ToString(),
                               miCursor).
            
            /* extra check for name. */
            if phIn:name ne cTableName then
                ThrowError(ObjectInputError:VALUE, cTableName, miCursor).
            
            /* if passed-in dataset isn't dynamic, throw an error. the values should
               match (although crc-value may differ if the source and target differ and
               so we'd never get here). */
            if phIn:dynamic ne lBuildTable then
                ThrowError(ObjectInputError:VALUE,
                        'dynamic=' + string(lBuildTable),
                        miCursor).
            hTable = phIn.                                        
        end.    /* valid-handle */

        if lBuildTable then
        do:
            create temp-table hTable.
            iMax = ReadByte().
                    
            /* fields */
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).
            
            /* Dump enough info for ADD-NEW-FIELD() */
            do iLoop = 1 to iMax:
                hTable:add-new-field(
                    ReadString(),
                    DataTypeEnum:EnumFromValue(ReadByte()):ToString(), /*cDataType,*/
                    ReadByte(),     /*iExtent,*/
                    ReadString(),   /*cFormat,*/
                    ReadString(),   /*cInitial,*/
                    ReadString(),   /*cLabel,*/
                    ReadString()).  /*cColLabel)*/
            end.
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
                    
            /* Indexes */
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).
            
            iMax = ReadByte().
            do iLoop = 1 to iMax:
                iCursor = miCursor.                
                cIndex = ReadString().
                iIndexEntries = num-entries(cIndex).
                cIndexName = entry(1, cIndex).
                
                /* Don't do this for the default index, and also make sure we've
                   got sufficient things. */
                if iIndexEntries gt 5 then
                do:
                    hTable:add-new-index(cIndexName,
                        logical(integer(entry(2, cIndex))),   /* unique index? */
                        logical(integer(entry(3, cIndex))),   /* primary index? */
                        logical(integer(entry(4, cIndex)))).   /* word index? */
                    
                    do iLoop2 = 5 to iIndexEntries by 2:
                        hTable:add-index-field(cIndexName,
                            entry(iLoop2, cIndex),
                            SortDirectionEnum:EnumFromValue(integer(entry(iLoop2 + 1, cIndex))):ToString()).
                    end.
                end.    /* >5 index entries */
                else
                if cIndexName ne 'default' then
                        ThrowError(ObjectInputError:VALUE,
                                       'even number of index entries',
                                       /* show position where the index string starts and not the
                                          length and markers */
                                       iCursor + ObjectStreamConstants:SIZE_BYTE + ObjectStreamConstants:SIZE_LONG).
            end.
            ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
            
            hTable:temp-table-prepare(cTableName).
            
            phIn = htable.
        end.
        
        return hTable.            
    end method.
    
    method protected void ReadDatasetRelation(phDataset as handle):
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).
        
        phDataset:add-relation(
                phDataset:get-buffer-handle(ReadString()),  /* parent-buffer */
                phDataset:get-buffer-handle(ReadString()),  /* child-buffer */
                ReadString(),   /* relation fields */
                ReadLogical(),  /* reposition? */                
                ReadLogical(),  /* nested? */
                ReadLogical(),  /* active? */                
                ReadLogical(),  /* recursive? */
                ReadLogical()). /*foriegn key hidden? */
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
    end method.
    
    method protected void ReadBufferData (phBuffer as handle):
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).

        iMax = ReadInt().
        do iLoop = 1 to iMax:
            phBuffer:buffer-create().
            ReadBufferRow(phBuffer).
            phBuffer:buffer-release().
        end.
        
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
    end method.    
    
    method protected void ReadBufferRow(phBuffer as handle):
        define variable iLoop  as integer   no-undo.
        define variable iMax   as integer   no-undo.
        define variable cIndex as character no-undo.
        define variable hField as handle    no-undo.

        ValidateByte(ReadByte(), ObjectStreamConstants:TC_BLOCKDATA).        
        
        do iLoop = 1 to phBuffer:num-fields:
            hField = phBuffer:buffer-field(iLoop).
            
            case DataTypeEnum:EnumFromString(hField:data-type):
                when DataTypeEnum:Character then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadChar().
                    else
                        hField:buffer-value = ReadCharArray().
                when DataTypeEnum:Date then 
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadDate().
                    else
                        hField:buffer-value = ReadDateArray().
                when DataTypeEnum:DateTime then
                    if hField:extent eq 0 then 
                        hField:buffer-value = ReadDateTime().
                    else
                        hField:buffer-value = ReadDateTimeArray().
                when DataTypeEnum:DatetimeTZ then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadDateTimeTz().
                    else
                        hField:buffer-value = ReadDateTimeTzArray().
                when DataTypeEnum:Decimal then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadDecimal().
                    else
                        hField:buffer-value = ReadDecimalArray().
                when DataTypeEnum:Integer then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadInt().
                    else
                        hField:buffer-value = ReadIntArray().
                when DataTypeEnum:Int64 then 
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadInt64().
                    else
                        hField:buffer-value = ReadInt64Array().
                when DataTypeEnum:Logical then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadLogical().
                    else
                        hField:buffer-value = ReadLogicalArray().
                when DataTypeEnum:LongChar then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadLongChar().
                    else
                        hField:buffer-value = ReadLongCharArray().
                when DataTypeEnum:Class or when DataTypeEnum:ProgressLangObject then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadObject().
                    else
                        hField:buffer-value = ReadObjectArray().
                when DataTypeEnum:Recid then
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadRecid().
                    else
                        hField:buffer-value = ReadRecidArray().
                when DataTypeEnum:Rowid then 
                    if hField:extent eq 0 then
                        hField:buffer-value = ReadRowid().
                    else
                        hField:buffer-value = ReadRowidArray().
            end case.
        end.
        
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
    end method.
    
    method public void ReadTable(input-output table-handle phTable):
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                phTable = ?.
            when ObjectStreamConstants:TC_TABLE then
            do:
                phTable = ReadTableDesc(phTable).
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_NULL).
                
                ReadBufferData(phTable:default-buffer-handle).
                
                ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
            end.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_TABLE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
    end method.
    
    method public handle ReadHandle():
        return widget-handle(string(ReadInt())).
    end method.
    
    method public handle extent ReadHandleArray():
        def var iExtent as int no-undo.
        def var iLoop as int no-undo.
        def var hVal as handle extent no-undo.
        
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_ARRAY).        

        iExtent = ReadByte().
        extent(hVal ) = iExtent.
        do iLoop = 1 to iExtent:
            hVal [iLoop] = ReadHandle().
        end.
                    
        ValidateByte(ReadByte(), ObjectStreamConstants:TC_ENDBLOCKDATA).
                
        return hVal.
    end method.
    
    /* read from memptr */
    method protected int ReadByte():
        def var iByte as int no-undo.
        
        iByte = get-byte(mmStreamMptr, miCursor).
        miCursor = miCursor + ObjectStreamConstants:SIZE_BYTE.
        
        return iByte.
    end method.
            
    method protected int ReadShort():
        def var iShort as int no-undo.
        
        iShort = get-short(mmStreamMptr, miCursor).
        miCursor = miCursor + ObjectStreamConstants:SIZE_SHORT.
        
        return iShort.
    end method.
    
    method protected int ReadLong():
        def var iLong as int no-undo.
        
        iLong = get-long(mmStreamMptr, miCursor).
        miCursor = miCursor + ObjectStreamConstants:SIZE_LONG.
        
        return iLong.
    end method.
    
    method protected dec ReadDouble():
        def var iDouble as int no-undo.
        
        iDouble = get-double(mmStreamMptr, miCursor).
        miCursor = miCursor + ObjectStreamConstants:SIZE_DOUBLE.
        
        return iDouble.
    end method.
    
    method protected char ReadString():
        /* code same as ReadLongString but we 
           for performance reasons we want to
           use native CHAR not LONGCHAR converted. */
        def var iLength as int no-undo.
        def var cVal as char no-undo.

        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                cVal = ?.
            when ObjectStreamConstants:TC_VALUE then            
                assign iLength  = ReadLong()
                       cVal     = get-string(mmStreamMptr, miCursor, iLength)
                       miCursor = miCursor + iLength.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
        
        return cVal.        
    end method.
        
    method protected longchar ReadLongString():
        def var iLength as int no-undo.
        def var cVal as longchar no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                cVal = ?.
            when ObjectStreamConstants:TC_VALUE then            
                assign iLength  = ReadLong()
                       cVal     = get-string(mmStreamMptr, miCursor, iLength)
                       miCursor = miCursor + iLength.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
        
        return cVal.
    end method.

    method protected raw ReadRaw():
        def var iLength as int no-undo.
        def var rVal as raw no-undo.
        
        case ReadByte():
            when ObjectStreamConstants:TC_NULL then
                /* default for RAW is ? */ .
            when ObjectStreamConstants:TC_VALUE then
                assign iLength  = ReadLong()
                       rVal     = get-bytes(mmStreamMptr, miCursor, iLength)
                       miCursor = miCursor + iLength.
            otherwise
                ThrowError(ObjectInputError:BYTE,
                               ObjectStreamConstants:ToString(ObjectStreamConstants:TC_NULL)
                               + ' or ' + ObjectStreamConstants:ToString(ObjectStreamConstants:TC_VALUE),
                               miCursor - ObjectStreamConstants:SIZE_BYTE).
        end case.
                
        return rVal.
    end method.
    
    method protected void ValidateByte(piActualByte as integer, piCheckByte as integer):
        /* Reference the /previous/ position, since ReadByte() always increments the cursor,
           and since this check happens after the incrememnt, we need to point back to the
           actual byte that doesn't match expectations. */
        if piActualByte ne piCheckByte then
            ThrowError(ObjectInputError:BYTE,
                           ObjectStreamConstants:ToString(piCheckByte),
                           miCursor - ObjectStreamConstants:SIZE_BYTE).
    end method.
    
    method protected void AddWarning(pcType as char, pcParam1 as char, piPosition as int ):
        @todo(task="implement").
        /*
        message
            pcType skip
            pcParam1 skip
            piPosition
        view-as alert-box warning.
        */
    end method.
    
    method protected void ThrowError(pcType as char, pcParam1 as char, piPosition as int ):
        /* Keep a clone around in case the class being serialized doesn't
           re-throw any of the ObjectOutputErrors it receives. We use a 
           clone because the thrown class is GC'd before we need it to be,
           even if we assign it to a member.
           
           We can deal with the Error in InvokeWriteObject if need be. */
        moObjectInputError = new ObjectInputError(pcType, pcParam1, string(piPosition)).
        
        undo, throw cast(moObjectInputError:Clone(), ObjectInputError).
    end method.
    
    method protected logical IsFlag (piValueSum as int, piCheckVal as int):
        define variable iPos as integer no-undo.
        define variable iVal as integer no-undo.
        
        do iPos = 1 to 32 while iVal eq 0:
            iVal = get-bits(piCheckVal, iPos, 1).
        end.
        
        return (get-bits(piValueSum, iPos - 1, 1) eq iVal).
    end method.
    
end class.
