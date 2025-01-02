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
    File        : SaxWriter
    Purpose     : An OOABL wrapper around the ABL SAX-WRITER handle. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Nov 22 15:40:24 EST 2010
    Notes       : * The majority of method names correspond to the ABL attributes/methods,
                    which are comprehensively documented in the ABL documentation set.
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.XML.SaxWriterError.
using OpenEdge.Core.XML.SaxWriterDataTypeEnum.

using OpenEdge.Lang.SaxWriteStatusEnum.
using OpenEdge.Lang.SerializationModeEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.Assert.

class OpenEdge.Core.XML.SaxWriter use-widget-pool:
    
    /* The actual SAX-WRITER handle */
    define private variable mhSaxWriter as handle no-undo.
    
    /** (derived) Maps to SAX-WRITER WRITE-STATUS attribute. See the ABL documentation for more details. */
    define public property WriteStatus as SaxWriteStatusEnum no-undo
        get():
            if valid-handle(mhSaxWriter) then
                return SaxWriteStatusEnum:EnumFromValue(mhSaxWriter:write-status).
        end get.
    
    /** Maps to SAX-WRITER ENCODING attribute. See the ABL documentation for more details. */
    define public property Encoding  as character no-undo
        get.
        set(input pcEncoding as character):
            ValidateCanUpdateProperty('Encoding').
            mhSaxWriter:encoding = pcEncoding.
            Encoding = pcEncoding.
        end set.
    
    /** Maps to SAX-WRITER FORMATTED attribute. See the ABL documentation for more details. */
    define public property IsFormatted as logical no-undo 
        get.
        set (input plFormatted as logical):
            ValidateCanUpdateProperty('IsFormatted').
            IsFormatted = plFormatted.
            mhSaxWriter:formatted = plFormatted.
        end set.
    
    /** Maps to SAX-WRITER FRAGMENT attribute. See the ABL documentation for more details. */
    define public property IsFragment as logical no-undo
        get.
        set (input plFragment as logical):
            ValidateCanUpdateProperty('IsFragment').
            IsFragment = plFragment.
            mhSaxWriter:fragment = plFragment.
        end set.
    
    /** Maps to SAX-WRITER STANDALONE attribute. See the ABL documentation for more details. */ 
    define public property IsStandalone as logical no-undo
        get.
        set(input plStandalone as logical):
            ValidateCanUpdateProperty('IsStandalone').
            IsStandalone = plStandalone.
            mhSaxWriter:standalone = plStandalone.
        end set.
    
    /** Maps to SAX-WRITER STRICT attribute. See the ABL documentation for more details. */
    define public property IsStrict as logical no-undo
        get.
        set(input plStrict as logical):
            ValidateCanUpdateProperty('IsStrict').
            IsStrict = plStrict.
            mhSaxWriter:strict= plStrict.
        end set.
    
    /** Maps to SAX-WRITER VERSION attribute. See the ABL documentation for more details. */
    define public property Version  as character no-undo
        get.
        set(input pcVersion as character):
            ValidateCanUpdateProperty('Version').
            
            if IsStrict and Version ne '1.0' then
                undo, throw new SaxWriterError('setting ' + quoter('Version') + ' property with SaxWriter:IsString and version is ' + pcVersion, '').
            
            mhSaxWriter:version = pcVersion.
            Version = pcVersion.
        end set.
    
    constructor public SaxWriter():
        Initialize().
    end constructor.
    
    constructor public SaxWriter(input pcFilename as character):
        Initialize().
        WriteTo(pcFilename).
    end constructor.

    constructor public SaxWriter(input pcDocument as longchar):
        Initialize().
        WriteTo(pcDocument).
    end constructor.

    constructor public SaxWriter(input phStream as handle):
        Initialize().
        WriteTo(phStream).
    end constructor.

    constructor public SaxWriter(input pmDocument as memptr):
        Initialize().
        WriteTo(pmDocument).            
    end constructor.
    
    method protected void ValidateCanUpdateProperty(input pcPropertyName as character):
        if valid-handle(mhSaxWriter) then
        case WriteStatus:
            when SaxWriteStatusEnum:Idle or when SaxWriteStatusEnum:Complete then
                /* allowed to update property */ .
            otherwise
                undo, throw new SaxWriterError('setting ' + quoter(pcPropertyName) + ' property with SaxWriter status of ', WriteStatus:ToString()).
        end case.
    end method.
    
    method public void Initialize():
        if not valid-handle(mhSaxWriter) then
            create sax-writer mhSaxWriter.
        else
            Reset().                
    end method.
    
    method public logical  Reset():
        if valid-handle(mhSaxWriter) then
            return mhSaxWriter:reset().
        else
            return false.            
    end method.
    
    method public logical WriteTo(input pcFilename as character):
        return mhSaxWriter:set-output-destination(SerializationModeEnum:File:ToString(), pcFilename).    
    end method.

    method public logical WriteTo(input pcDocument as longchar):
        return mhSaxWriter:set-output-destination(SerializationModeEnum:LongChar:ToString(), pcDocument).    
    end method.

    method public logical WriteTo(input phStream as handle):
        Assert:ArgumentIsType(phStream, DataTypeEnum:Stream, 'stream').
        
        return mhSaxWriter:set-output-destination(SerializationModeEnum:StreamHandle:ToString(), phStream).
    end method.

    method public logical WriteTo(input pmDocument as memptr):    
        return mhSaxWriter:set-output-destination(SerializationModeEnum:Memptr:ToString(), pmDocument).
    end method.
    
    method public logical StartDocument():
        return mhSaxWriter:start-document().
    end method. 

    method public logical EndDocument():
        return mhSaxWriter:end-document().
    end method.

    method public logical DeclareNamespace(input pcNamespaceURI as longchar):
        return DeclareNamespace(pcNamespaceURI, ?).                                               
    end method.                                               
    
    method public logical DeclareNamespace(input pcNamespaceURI as longchar,
                                           input pcNamespacePrefix as longchar):
        return mhSaxWriter:declare-namespace(pcNamespaceURI, pcNamespacePrefix).                                               
    end method.                                               
    
    method public logical StartElement(input pcName as longchar):
        return StartElement(pcName, ?, ?).
    end method.
    
    method public logical StartElement(input pcName as longchar,
                                       input pcNamespaceURI as longchar):
        return StartElement(pcName, pcNamespaceURI, ?).
    end method.
    
    method public logical StartElement(input pcName as longchar,
                                       input pcNamespaceURI as longchar,                                       
                                       input phSaxAttributes as handle):
        return mhSaxWriter:start-element(pcName, pcNamespaceURI, phSaxAttributes).
    end method.

    
    method public logical EndElement(input pcName as longchar):
        return EndElement(pcName, ?).
    end method.
    
    method public logical EndElement(input pcName as longchar,
                                     input pcNamespaceURI as longchar):
        return mhSaxWriter:end-element(pcName, pcNamespaceURI).                                           
    end method.

    method public logical InsertAttribute (input pcName as longchar,
                                           input pcValue as longchar):
        return InsertAttribute(pcName, pcValue, ?). 
    end method.            

    method public logical InsertAttribute (input pcName as longchar,
                                           input pcValue as longchar,
                                           input pcNamespaceURI as longchar):
        return mhSaxWriter:insert-attribute(pcName, pcValue, pcNamespaceURI). 
    end method.
    
    /** Writes a value to the output destination. This method defaults to
        writing characters. 
        
        @param longchar The value being written.
        @return logical Whether the operation succeeded or not. */
    method public logical WriteValue(input pcValue as longchar):
        return WriteValue(SaxWriterDataTypeEnum:Characters, pcValue).
    end method.
    
    /** Writes a value to the output destination. This method simply writes
        the value for the given type, using the correct WRITE-* call. 
        
        There's a WriteFragment() method which deals with a noderef handle.
        
        @param SaxWriterDataTypeEnum The element type
        @param longchar The value being written.
        @return logical Whether the operation succeeded or not. */
    method public logical WriteValue(input poType as SaxWriterDataTypeEnum,
                                     input pcValue as longchar):
        case poType:
            when SaxWriterDataTypeEnum:CData then return mhSaxWriter:write-cdata(pcValue).
            when SaxWriterDataTypeEnum:Characters then return mhSaxWriter:write-characters(pcValue).
            when SaxWriterDataTypeEnum:Comment then return mhSaxWriter:write-comment(pcValue).
            when SaxWriterDataTypeEnum:EntityReference then return mhSaxWriter:write-entity-ref(pcValue).
            when SaxWriterDataTypeEnum:Fragment then return mhSaxWriter:write-fragment(pcValue).
        end case.
    end method.
    
    /** Writes a fragment's values from a specified XML node ref 
        
        @param handle The valid XML node-ref handle containing the fragment
        @return logical Whether the operation succeeded or not. */
    method public logical WriteFragment(input phNodeRef as handle):
        Assert:ArgumentIsType(phNodeRef, DataTypeEnum:XmlNodeRef, 'XML Node Ref').
        
        return mhSaxWriter:write-fragment(phNodeRef).
    end method.

    method public logical WriteDataElement(input pcName as longchar,
                                           input pcValue as longchar):
        return WriteDataElement(pcName, pcValue, ?, ?).                                               
    end method.

    method public logical WriteDataElement(input pcName as longchar,
                                           input pcValue as longchar,
                                           input pcNamespaceURI as longchar):
        return WriteDataElement(pcName, pcValue, pcNamespaceURI, ?).                                               
    end method.
    
    method public logical WriteDataElement(input pcName as longchar,
                                           input pcValue as longchar,
                                           input pcNamespaceURI as longchar,
                                           input phSaxAttributes as handle ):
        return mhSaxWriter:write-data-element(pcName, pcValue, pcNamespaceURI, phSaxAttributes).                                               
    end method.

    method public logical WriteEmptyElement(input pcName as longchar):
        return WriteEmptyElement(pcName, ?, ?).
    end method.

    method public logical WriteEmptyElement(input pcName as longchar,
                                            input pcNamespaceURI as longchar):
        return WriteEmptyElement(pcName, pcNamespaceURI, ?).
    end method.
    
    method public logical WriteEmptyElement(input pcName as longchar,
                                            input pcNamespaceURI as longchar,
                                            input phSaxAttributes as handle ):
        return mhSaxWriter:write-empty-element(pcName, pcNamespaceURI, phSaxAttributes).
    end method.

    method public logical WriteExternalDTD(input pcName as longchar,
                                           input pcSystemId as longchar):
        return WriteExternalDTD(pcName, pcSystemId, ?).
    end method.
    
    method public logical WriteExternalDTD(input pcName as longchar,
                                           input pcSystemId as longchar,
                                           input pcPublicId as longchar):
        return mhSaxWriter:write-external-dtd(pcName, pcSystemId, pcPublicId).
    end method.
    
    method public logical WriteProcessingInstruction(input pcTarget as longchar,
                                                     input pcData as longchar):
        return mhSaxWriter:write-processing-instruction(pcTarget, pcData).                                                         
    end method.
    
end class.
