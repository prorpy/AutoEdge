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
    File        : ObjectOutputStream
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Nov 13 14:22:25 EST 2009
    Notes       : * IExternalizable types don't write out metadata
                 * For the protocol definition, see
                 https://wiki.progress.com/display/OEBP/Object+Serialization+Protocol     
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.
using OpenEdge.Core.Util.ObjectStreamConstants.
using OpenEdge.Core.Util.ObjectOutputError.
using OpenEdge.Lang.SortDirectionEnum.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Lang.Collections.ObjectStack.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.IOModeEnum.
using OpenEdge.Lang.CompareStrengthEnum.
using OpenEdge.Lang.EnumMember.

using Progress.Lang.ParameterList.
using Progress.Lang.Error.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.Core.Util.ObjectOutputStream
            implements IObjectOutput:
    
    define private variable miCursor              as integer           no-undo.
    define private variable mrStreamBuffer        as raw               no-undo.
    define private variable moTopLevel            as Object            no-undo.
    define private variable moTypeStack           as ObjectStack       no-undo.
    
    define private variable moWriteObjParam       as ParameterList     no-undo.
    define private variable moObjectOutputError   as ObjectOutputError no-undo.
    define private variable mlStreamHeaderWritten as logical           no-undo.
    
    define private temp-table StreamReference no-undo
        field ReferenceType as integer  /* ObjectStreamConstants:REFTYPE_ */
        field Reference     as integer      /* object id for PLO or PLC */
        field Position      as integer       /* */
        index idx1 as primary unique ReferenceType Reference
        .
    constructor public ObjectOutputStream():
        Initialize().
    end constructor.
    
    destructor public ObjectOutputStream():
        this-object:Clear().
    end destructor.
    
    method protected void Clear():
        define buffer lbRef for StreamReference.
            
        empty temp-table lbRef.
        moTopLevel = ?.
        
        length(mrStreamBuffer) = 0. 
        mrStreamBuffer = ?.
        miCursor = 0.
        moWriteObjParam = ?.
        moObjectOutputError = ?.
        mlStreamHeaderWritten = false.
    end method.
    
    /** Resets/reinitialises the output */
    method public void Reset():
        this-object:Clear().
        Initialize().
    end method.
    
    method protected void Initialize():
        /* Create on parameter list object that
           we'll reuse. */
        moWriteObjParam = new ParameterList(1).
        moWriteObjParam:SetParameter(1,
            substitute(DataTypeEnum:Class:ToString(), this-object:GetClass():TypeName),
            IOModeEnum:Input:ToString(),
            this-object).
        
        miCursor = 1.
    end method.
    
    method protected void WriteStreamHeader():
        WriteString(ObjectStreamConstants:STREAM_MAGIC).
        WriteByte(ObjectStreamConstants:STREAM_VERSION).
        
        /* This is invariant for this object, so write it in the
           header instead of for each decimal. Note that we write 
           dates in broken-down pieces, so don't need to keep formats
           for them. */
        WriteByte(asc(session:numeric-decimal-point)).
        WriteByte(asc(session:numeric-separator)).
        
        /* What version are we running? */
        WriteString(proversion).
        
        mlStreamHeaderWritten = true.
    end method.
    
    /**  Writes the serialized output to the specified file 
         
         @param character The name of a file to write the output into. */    
    method public void Write(pcFileName as char):
        define variable mStream as memptr no-undo.

        this-object:Write(output mStream).
        copy-lob mStream to file pcFileName.
        
        finally:
            set-size(mStream) = 0.
        /* this-object:Clear called from Write(memptr) */
        end finally.
    end method.
    
    /**  Writes the serialized output to a memptr
         
         @param memptr The memprt into which to write the output. */    
    method public void Write(output pmStream as memptr):
        set-byte-order(pmStream) = ByteOrderEnum:BigEndian:Value.
        set-size(pmStream) = miCursor.
        put-bytes(pmStream, 1) = mrStreamBuffer.
        
        /* make sure we clear the memptr*/
        finally:
            this-object:Clear().
        end finally.
    end method.
    
    /**  Writes the serialized output to a CLOB
         
         @param longchar The CLOB into which to write the output. */            
    method public void Write(output pcStream as longchar):
        define variable mStream as memptr no-undo.
        
        this-object:Write(output mStream).
        copy-lob mStream to pcStream.
        
        finally:
            set-size(mStream) = 0.
        /* this-object:Clear called from Write(memptr) */
        end finally.        
    end method.
    
    method protected void DefaultWriteObject(poIn as Object):
        define variable iStackLoop  as integer no-undo.
        define variable iMemberLoop as integer no-undo.
        define variable iStackSize  as integer no-undo.
        define variable iMembers    as integer no-undo.
        define variable oType       as class   Class no-undo.
        
        /* Write out the members from the least-derived ("highest") class
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
            Write<type>(o:<Member>).
            */
            end.
        end.
    end method.
    
    /** write the ABL data types **/
    method public void WriteObject(poIn as Object):
        define variable iRefPosition     as integer no-undo.
        define variable iMetadataBytePos as integer no-undo.
        define variable lWriteDetails    as logical no-undo.
        
        /* Top-level class */
        if not valid-object(moTopLevel) then
        do:
            WriteStreamHeader().
            moTopLevel = poIn.
        end.
        
        /* The first byte folling TC_OBJECT will always be another byte marker.
           It should be either TC_NULL, TC_REFERENCE or TC_METADATA, depending
           on circumstance. */
        if valid-object(poIn) then
        do:
            /* Enumerations (EnumMember) must be written using WriteEnum() rather than
               WriteObject. */
            if type-of(poIn, EnumMember) then
            do:
                WriteEnum(cast(poIn, EnumMember)).
                return.
            end.
            
            WriteByte(ObjectStreamConstants:TC_OBJECT).
            if poIn eq moTopLevel then
                lWriteDetails = true.
            else
                assign /* iMetadataBytePos is where the TC_OBJECT byte for the 
                          class will be (ie the previous position at the TC_OBJECT byte) */
                    iMetadataBytePos = miCursor - ObjectStreamConstants:SIZE_BYTE
                    iRefPosition     = AddReference(ObjectStreamConstants:REFTYPE_OBJECT,
                                            int(poIn),  /* object reference ('handle'), as key value */
                                            iMetadataBytePos)
                    lWriteDetails    = iRefPosition eq iMetadataBytePos.
            
            if lWriteDetails then
            do:
                moTypeStack = new ObjectStack().
                
                /* next byte is going to be TC_METADATA, unless we're PLO, 
                   which we shouldn't (can't?) be */
                WriteClassDesc(poIn:GetClass()).
                
                /* Only write the TC_NULL when the whole class def for this class is done */
                WriteByte(ObjectStreamConstants:TC_NULL).
                InvokeWriteObject(poIn).
                /* no longer needed */
                moTypeStack = ?.
                /* Completely done with object. Don't need this for
                   the top-level since we're now at the end of the stream.
                   Or should be. */
                if poIn ne moTopLevel then
                    WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
            end.    /* write details */
            else
            do:
                /* point to existing object def (earlier) in stream */
                WriteByte(ObjectStreamConstants:TC_REFERENCE).
                WriteInt(iRefPosition).
            end.
        end.    /* valid-object */
        else
            WriteByte(ObjectStreamConstants:TC_NULL).
    end method.    
    
    method protected void InvokeWriteObject(poIn as Object):
        define variable oType as class Class no-undo.
        
        oType = poIn:GetClass().

        if oType:IsA(ObjectStreamConstants:SERIALIZABLE_IFACE_TYPE) then
            DefaultWriteObject(poIn).
        
        /* A type could be Externalizable and Serializable, so no ELSE */
        if oType:IsA(ObjectStreamConstants:EXTERNALIZABLE_IFACE_TYPE) then
            oType:Invoke(poIn,
                ObjectStreamConstants:EXTERNALIZABLE_METHOD_WRITEOBJECT,
                moWriteObjParam).
        /* If we get here, then the class being serialized doesn't
           re-throw any of the ObjectOutputErrors it receives.
           
           We don't want to continue, since there was an error, so 
           we abort. */
        if valid-object(moObjectOutputError) then
            undo, throw moObjectOutputError .
    end method.
    
    method protected integer AddReference (piType as int,
        piRef as int,
        piPos as int):
        def buffer bRef for StreamReference.
        
        find bRef where
            bRef.ReferenceType = piType and
            bRef.Reference = piRef
            no-error.
        if not available bRef then
        do:
            create bRef.
            assign 
                bRef.ReferenceType = piType
                bRef.Reference     = piRef
                bRef.Position      = piPos.
        end.
        
        return bRef.Position.
    end method.
    
    method protected void WriteClassDesc(poType as class Class):
        define variable iFlags           as integer   no-undo.
        define variable lWriteMemberInfo as logical   no-undo.
        define variable cMD5             as character no-undo.
        define variable cTypeName        as character no-undo.
        
        /* Don't write top-level class, ie Progress.Lang.Object. The
           PROVERSION written into the stream header will ensure we 
           have the right top-level object.
           
           Note, don't write the name in the highly unlikely case that
           PLO changes in the future. */
        if valid-object(poType:SuperClass) then
        do:
            WriteByte(ObjectStreamConstants:TC_METADATA).
            moTypeStack:Push(poType).
            
            cTypeName = poType:TypeName.
            WriteString(cTypeName).
            
            rcode-info:file-name = replace(cTypeName, '.', '/').
            cMD5  = rcode-info:md5-value no-error.
            WriteString(cMD5).
            
            assign 
                lWriteMemberInfo = no
                iFlags           = 0.
            
            if poType:IsA(ObjectStreamConstants:EXTERNALIZABLE_IFACE_TYPE) then
                assign iFlags           = iFlags + ObjectStreamConstants:SC_EXTERNALIZABLE + ObjectStreamConstants:SC_WRITE_METHOD
                    lWriteMemberInfo = no.
            
            if poType:IsA(ObjectStreamConstants:SERIALIZABLE_IFACE_TYPE) then                
                assign iFlags           = iFlags + ObjectStreamConstants:SC_SERIALIZABLE
                    lWriteMemberInfo = yes.
            
            /* Each class in the hierarchy needs to be either Serializable or Externalizable. */
            if iFlags eq 0 then
                ThrowError(ObjectOutputError:TYPE,
                    'type that implements ' + ObjectStreamConstants:SERIALIZABLE_IFACE_TYPE 
                    + ' or ' + ObjectStreamConstants:EXTERNALIZABLE_IFACE_TYPE).
            WriteByte(iFlags).
            
            if lWriteMemberInfo then
            do:
            /* num properties, variables, fields */
            /* actually write out property names, types */
            end.

            WriteClassDesc(poType:SuperClass).
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteObjectArray(pIn as Object extent):        
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().

        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteObject(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteEnum(input poMember as EnumMember):
        ValidateStream().
        
        if valid-object(poMember) then
        do:
            WriteByte(ObjectStreamConstants:TC_ENUM).
            WriteChar(poMember:GetClass():TypeName).
            WriteInt(poMember:Value).
            WriteChar(poMember:Name).
        end.
        else
            WriteByte(ObjectStreamConstants:TC_NULL).
    end method.
    
    method public void WriteChar(pc as char):
        ValidateStream().
        WriteString(pc).
    end method.
        
    method public void WriteCharArray(pIn as character extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteChar(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteLongchar(pc as longchar):
        ValidateStream().
        WriteString(pc).
    end method.
    
    method public void WriteLongcharArray(pIn as longchar extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteLongchar(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteInt(pi as int):
        ValidateStream().
        
        if pi eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_VALUE).
            WriteLong(pi).
        end.
    end method.
    
    method public void WriteIntArray(pIn as integer extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteInt(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteInt64(pi as int64):
        ValidateStream().
        if pi eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_VALUE).                   
            WriteDouble(pi).
        end.
    end method.
            
    method public void WriteInt64Array(pIn as int64 extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteInt64(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteDecimal(pd as dec):
        def var cVal as char no-undo.
        
        ValidateStream().
                
        /* Put into stream as string since there's no decent analog in PUT-* terms.
           Convert to American format for writing. Don't change the SESSION since we
           have no idea what the caller is doing before or after the WriteDecimal() calls:
           they might be using a string representation of a decimal for some strange thing. 
           So we will 'hand-craft' it. */
        assign 
            cVal = replace(string(pd), session:numeric-separator, '')
            cVal = replace(cVal, session:numeric-decimal-point, '.').
        
        WriteString(cVal).
    end method.
    
    method public void WriteDecimalArray(pIn as dec extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.

        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteDecimal(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteDate(pt as date):
        ValidateStream().
        if pt eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_VALUE).                           
            WriteLong(int(date(pt))).
        end.
    end method.
        
    method public void WriteDateArray(pIn as date extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteDate(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.

    method public void WriteDateTime(pt as datetime):
        ValidateStream().
        
        if pt eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_VALUE).
            WriteLong(int(date(pt))).
            WriteLong(mtime(pt)).
        end.
    end method.
    
    method public void WriteDateTimeArray(pIn as datetime extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteDateTime(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteDateTimeTz(pt as datetime-tz):
        ValidateStream().
        
        if pt eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_VALUE).
            WriteLong(int(date(pt))).
            WriteLong(mtime(pt)).
            WriteLong(timezone(pt)).
        end.
    end method.
    
    method public void WriteDateTimeTzArray(pIn as datetime-tz extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
    
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteDateTimeTz(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteLogical(pl as log):
        ValidateStream().
        if pl eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_VALUE).        
            WriteByte(int(pl)).
        end.
    end method.
    
    method public void WriteLogicalArray(pIn as log extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteLogical(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.

    method public void WriteRowid(pr as rowid):
        ValidateStream().
        WriteString(string(pr)).    
    end method.
    
    method public void WriteRowidArray(pIn as rowid extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteRowid(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.

    method public void WriteRecid(pr as recid):
        ValidateStream().
        WriteInt(int(pr)).    
    end method.
    
    method public void WriteRecidArray(pIn as recid extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iMax eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).        
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteRecid(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
        
    method protected void WriteDatasetDesc(phIn as handle):
        define variable iLoop     as integer no-undo.
        define variable iMax      as integer no-undo.
        define variable hRelation as handle  no-undo.
        
        WriteByte(ObjectStreamConstants:TC_METADATA).   /* dataset */
        WriteString(phIn:name).
        WriteLogical(phIn:dynamic). /* ie do we need to construct the dataset? */
        
        if phIn:dynamic then
        do:
            /* buffers */
            WriteByte(ObjectStreamConstants:TC_BLOCKDATA).  /* buffers */
            iMax = phIn:num-buffers.
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteTableDesc(phIn:get-buffer-handle(iLoop)).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).   /* buffers */
            
            /* relations */
            WriteByte(ObjectStreamConstants:TC_BLOCKDATA).  /* relations */
            iMax = phIn:num-relations.
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteDatasetRelation(phIn:get-relation(iLoop)).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA). /* relations */
        end.
    end method.
    
    method public void WriteDataset (phIn as handle):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        if not valid-handle(phIn) then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            if not DataTypeEnum:Dataset:Equals(phIn:type) then
                ThrowError(ObjectOutputError:TYPE,
                    DataTypeEnum:Dataset:ToString()).
            
            WriteByte(ObjectStreamConstants:TC_OBJECT).     /* dataset */
            WriteDatasetDesc(phIn).
            WriteByte(ObjectStreamConstants:TC_NULL).
            
            WriteByte(ObjectStreamConstants:TC_BLOCKDATA).  /* buffer data */
            iMax = phIn:num-buffers.
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteBufferData(phIn:get-buffer-handle(iLoop)).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).   /* buffer data */
            
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).  /* dataset */
        end.
    end method.
    
    method protected void WriteDatasetRelation(phIn as handle):
        WriteByte(ObjectStreamConstants:TC_BLOCKDATA).
    
        /* Write information for a relation in the order
           that ADD-RELATION() expects it in. */                
        WriteString(phIn:parent-buffer:name).
        WriteString(phIn:child-buffer:name).
        WriteString(phIn:relation-fields).
        WriteLogical(phIn:reposition).
        WriteLogical(phIn:nested).
        WriteLogical(phIn:active).
        WriteLogical(phIn:recursive).
        WriteLogical(phIn:foreign-key-hidden).
        
        WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).            
    end method.
    
    method protected void WriteTableDesc(phIn as handle):
        define variable hField as handle  no-undo.
        define variable iLoop  as integer no-undo.
        define variable iMax   as integer no-undo.
        
        WriteByte(ObjectStreamConstants:TC_METADATA).   /* buffer */
        WriteString(phIn:name).
        WriteLogical(phIn:dynamic). /* ie do we need to construct the table/buffer? */
        
        if phIn:dynamic then
        do:
            iMax = phIn:num-fields.
            WriteByte(iMax).
                        
            WriteByte(ObjectStreamConstants:TC_BLOCKDATA).   /* fields */
            /* Dump enough info for ADD-NEW-FIELD(). And write it in the order that A-N-F() expects,
               so we don't have to use intermediaries on read. */
            do iLoop = 1 to iMax:
                hField = phIn:buffer-field(iLoop).
                WriteString(hField:name).
                WriteByte(DataTypeEnum:EnumFromString(hField:data-type):Value).
                WriteByte(hField:extent).   /* Extent will be 0 for scalars */
                WriteString(hField:format).
                WriteString(hField:default-string).
                WriteString(hField:label).
                WriteString(hField:column-label).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).   /* fields */
            
            WriteIndexInfo(phIn).
        end.
    end method.
    
    method protected void WriteIndexInfo(phIn as handle):
        define variable iLoop  as integer   no-undo.
        define variable iMax   as integer   no-undo.
        define variable cIndex as character extent no-undo.        

        WriteByte(ObjectStreamConstants:TC_BLOCKDATA).  /* Indexes */
        
        assign 
            iMax           = 1
            extent(cIndex) = ObjectStreamConstants:SIZE_INDEX_ARRAY
            cIndex[iMax]   = phIn:index-information(iMax)
            .
        do while cIndex[iMax] ne ?:
            assign 
                iMax         = iMax + 1
                cIndex[iMax] = phIn:index-information(iMax).
        end.
        /* we'll be outta this loop with a too-high iMax value */
        iMax = iMax - 1.
        if iMax gt extent(cIndex) then
            ThrowError(ObjectOutputError:ARRAY_SIZE, string(ObjectStreamConstants:SIZE_INDEX_ARRAY)).

        WriteByte(iMax).
                
        do iLoop = 1 to iMax:
            WriteString(cIndex[iLoop]).
        end.
        WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).   /* indexes */
    end method.
    
    method protected void WriteBufferRow(phIn as handle):
        define variable iLoop  as integer   no-undo.
        define variable iMax   as integer   no-undo.
        define variable cIndex as character no-undo.
        define variable hField as handle    no-undo.
        
        WriteByte(ObjectStreamConstants:TC_BLOCKDATA).   /* row */
        do iLoop = 1 to phIn:num-fields:
            hField = phIn:buffer-field(iLoop).
            
            case DataTypeEnum:EnumFromString(hField:data-type):
                when DataTypeEnum:Character then
                    if hField:extent eq 0 then
                        WriteChar(hField:buffer-value).
                    else
                        WriteCharArray(hField:buffer-value).
                when DataTypeEnum:Date then 
                    if hField:extent eq 0 then
                        WriteDate(hField:buffer-value).
                    else
                        WriteDateArray(hField:buffer-value).
                when DataTypeEnum:DateTime then
                    if hField:extent eq 0 then
                        WriteDateTime(hField:buffer-value).
                    else
                        WriteDateTimeArray(hField:buffer-value).
                when DataTypeEnum:DatetimeTZ then
                    if hField:extent eq 0 then
                        WriteDateTimeTz(hField:buffer-value).
                    else
                        WriteDateTimeTzArray(hField:buffer-value).
                when DataTypeEnum:Decimal then
                    if hField:extent eq 0 then
                        WriteDecimal(hField:buffer-value).
                    else
                        WriteDecimalArray(hField:buffer-value).
                when DataTypeEnum:Integer then
                    if hField:extent eq 0 then
                        WriteInt(hField:buffer-value).
                    else
                        WriteIntArray(hField:buffer-value).
                when DataTypeEnum:Int64 then
                    if hField:extent eq 0 then
                        WriteInt64(hField:buffer-value).
                    else
                        WriteInt64Array(hField:buffer-value).
                when DataTypeEnum:Logical then
                    if hField:extent eq 0 then
                        WriteLogical(hField:buffer-value).
                    else
                        WriteLogicalArray(hField:buffer-value).
                when DataTypeEnum:LongChar then
                    if hField:extent eq 0 then
                        WriteLongChar(hField:buffer-value).
                    else
                        WriteLongCharArray(hField:buffer-value).
                when DataTypeEnum:Class or 
                when DataTypeEnum:ProgressLangObject then
                    if hField:extent eq 0 then
                    do:
                        if type-of(hField:buffer-value, EnumMember) then
                            WriteEnum(hField:buffer-value).
                        else
                            WriteObject(hField:buffer-value).
                    end.
                    else
                        WriteObjectArray(hField:buffer-value).
                when DataTypeEnum:Recid then
                    if hField:extent eq 0 then
                        WriteRecid(hField:buffer-value).
                    else
                        WriteRecidArray(hField:buffer-value).
                when DataTypeEnum:Rowid then 
                    if hField:extent eq 0 then
                        WriteRowid(hField:buffer-value).
                    else
                        WriteRowidArray(hField:buffer-value).
                otherwise
                ThrowError(ObjectOutputError:TYPE,
                    'something other than ' + hField:data-type).
            end case.
        end.
        
        WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).   /* row */
    end method.
    
    method protected void WriteBufferData (phIn as handle):
        define variable hQry    as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        WriteByte(ObjectStreamConstants:TC_BLOCKDATA).  /* data */
        create buffer hBuffer for table phIn:table-handle buffer-name 'Serialize'.
        create query hQry.
        hQry:set-buffers(hBuffer).
        hQry:query-prepare('preselect each ' + hBuffer:name).
        hQry:query-open().
        WriteInt(hQry:num-results).
        
        hQry:get-first().        
        do while not hQry:query-off-end:
            WriteBufferRow(hBuffer).
            hQry:get-next().
        end.
        hQry:query-close().
        WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).   /* data */
        
        delete object hQry.
        delete object hBuffer.
    end method.
    
    method public void WriteTable(phIn as handle):
        define variable hBuffer as handle no-undo.
        
        ValidateStream().
        
        if not valid-handle(phIn) then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            if not DataTypeEnum:Buffer:Equals(phIn:type) then
            do:
                if not DataTypeEnum:TempTable:Equals(phIn:type) then
                    ThrowError(ObjectOutputError:TYPE,
                        DataTypeEnum:Buffer:ToString()
                        + ' or ' + DataTypeEnum:TempTable:ToString()).
                phIn = phIn:default-buffer-handle.
            end.
            
            WriteByte(ObjectStreamConstants:TC_TABLE).
            WriteTableDesc(phIn).
            WriteByte(ObjectStreamConstants:TC_NULL).
            
            WriteBufferData(phIn).
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    method public void WriteHandle(ph as handle):
        ValidateStream().
        case DataTypeEnum:EnumFromString(ph:type):
            when DataTypeEnum:Buffer or 
            when DataTypeEnum:TempTable then
                ThrowError(ObjectOutputError:API_CALL,
                    ObjectStreamConstants:EXTERNALIZABLE_METHOD_WRITETABLE).
            when DataTypeEnum:Dataset then
                ThrowError(ObjectOutputError:API_CALL,
                    ObjectStreamConstants:EXTERNALIZABLE_METHOD_WRITEDATASET).
            otherwise
            WriteInt(int(ph)).
        end case.
    end method.
    
    method protected void ThrowError(pcType as char, pcParam as char):
        /* Keep a clone around in case the class being serialized doesn't
           re-throw any of the ObjectOutputErrors it receives. We use a 
           clone because the thrown class is GC'd before we need it to be,
           even if we assign it to a member.
           
           We can deal with the Error in InvokeWriteObject if need be. */
        moObjectOutputError = new ObjectOutputError(pcType, pcParam).        
        
        undo, throw cast(moObjectOutputError:Clone(), ObjectOutputError).
    end method.
    
    method public void WriteHandleArray(pIn as handle extent):
        define variable iLoop as integer no-undo.
        define variable iMax  as integer no-undo.
        
        ValidateStream().
        
        iMax = extent(pIn).
        if iLoop eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            WriteByte(ObjectStreamConstants:TC_ARRAY).
            WriteByte(iMax).
            do iLoop = 1 to iMax:
                WriteHandle(pIn[iLoop]).
            end.
            WriteByte(ObjectStreamConstants:TC_ENDBLOCKDATA).
        end.
    end method.
    
    /* Protected Write*() methods below do the actual writes to the stream. */
    method protected void WriteByte(piIn as int):
        put-byte(mrStreamBuffer, miCursor) = piIn.
        miCursor = miCursor + ObjectStreamConstants:SIZE_BYTE.
    end method.
    
    method protected void WriteShort(piIn as int):
        put-short(mrStreamBuffer, miCursor) = piIn.
        miCursor = miCursor + ObjectStreamConstants:SIZE_SHORT.
    end method.
    
    method protected void WriteLong(piIn as int):
        put-long(mrStreamBuffer, miCursor) = piIn.
        miCursor = miCursor + ObjectStreamConstants:SIZE_LONG.
    end method.
    
    method protected void WriteDouble(pdIn as dec):
        put-double(mrStreamBuffer, miCursor) = pdIn.
        miCursor = miCursor + ObjectStreamConstants:SIZE_DOUBLE.
    end method.
    
    method protected void WriteString(pcVal as char):
        define variable lcVal as longchar no-undo.
        lcVal = pcVal.
        
        WriteString(lcVal).
    end method.
    
    method protected void WriteString(pcVal as longchar):
        define variable iLength as integer no-undo.
        define variable iMarker as integer no-undo.
        
        if pcVal eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            iLength = length(pcVal, CompareStrengthEnum:Raw:ToString()).
            
            WriteByte(ObjectStreamConstants:TC_VALUE).
            WriteLong(iLength).
            put-string(mrStreamBuffer, miCursor) = pcVal.
            miCursor = miCursor + iLength.
        end.
    end method.

    method protected void WriteRaw(prVal as raw):
        define variable iLength as integer no-undo.
        define variable iMarker as integer no-undo.
        
        if prVal eq ? then
            WriteByte(ObjectStreamConstants:TC_NULL).
        else
        do:
            iLength = length(prVal, CompareStrengthEnum:Raw:ToString()).
            
            WriteByte(ObjectStreamConstants:TC_VALUE).
            WriteLong(iLength).
            put-bytes(mrStreamBuffer, miCursor) = prVal.
            miCursor = miCursor + iLength.
        end.
    end method.
    
    method protected void ValidateStream():
        if not mlStreamHeaderWritten then
            ThrowError(ObjectOutputError:STREAM, 'stream header to be written').
    end method.
    
end class.
