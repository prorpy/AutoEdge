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
    File        : SavvionType
    Purpose     : Common parent class for Savvion complex types like DataSlotInstances.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 23 11:10:25 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxWriter.
using OpenEdge.Core.XML.SaxReader.
using OpenEdge.Core.XML.WebServiceProtocol.

using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.IOModeEnum.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.SerializationModeEnum.
using OpenEdge.Lang.TimeStamp.
using OpenEdge.Lang.Assert.
using Progress.Lang.ParameterList.
using Progress.Lang.Class.


class OpenEdge.Lang.BPM.SavvionType abstract:
    
    define static private variable mcCurrentParseOperation as character no-undo.
    define static private variable mcCurrentParseElement as character no-undo.
    define static private variable moCurrentParseType as class Class no-undo.
    define static private variable moCurrentParseObject as SavvionType no-undo.
    define static private variable moCurrentParseCollection as ICollection no-undo.
    
    constructor public SavvionType ():
    end constructor.
    
    /** Serializes an array of SavvionType objects into XML.
        
        @param SaxWriter The SaxWriter object being used for the serialization
        @param longchar The (complex) element name for the array
        @param longchar The namespace in use
        @param DataSlotInstance[] The array of dataslots being serialized.  */
    method static void ArrayToXml(input poSaxWriter as SaxWriter,
                                  input pcElementName as longchar,
                                  input pcNamespace as longchar,  
                                  input poSavvionType as SavvionType extent):   
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = extent(poSavvionType).
        if iMax gt 0 then
        do:
            do iloop = 1 to iMax:
                poSaxWriter:StartElement(substitute('&1:&2', pcNamespace, pcElementName)).
                poSavvionType[iLoop]:ObjectToXML(poSaxWriter, pcNamespace).
                poSaxWriter:EndElement(substitute('&1:&2', pcNamespace, pcElementName)).
            end.
        end.        
    end method.
    
    /** Serializes an array of characters into XML.
        
        @param SaxWriter The SaxWriter object being used for the serialization
        @param longchar The (complex) element name for the array
        @param longchar The namespace in use
        @param longchar[] The array of character values being serialized.  */
    method static void ArrayToXml(input poSaxWriter as SaxWriter,
                                  input pcElementName as longchar,
                                  input pcNamespace as longchar,  
                                  input pcValue as longchar extent):   
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = extent(pcValue).
        if iMax gt 0 then
        do iloop = 1 to iMax:
            SavvionType:WriteElement(poSaxWriter, pcElementName, pcValue[iLoop], pcNamespace).
        end.
    end method.
    
    /** Serializes this instance of the type to XML, using a SAXWriter object.
        
        @param SaxWriter The SAX writer used to serialize the object.
        @param longchar The namespace used. */
    method abstract public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar  ).

    /** Serializes an array of SavvionType objects into a table.
        
        @param Class The concrete type of the SavvionType being serialised.
        @param SavvionType[] An array of Savvion types to serialise as a table
        @param table-handle The output table handle. */    
    method static void ArrayToTable(input poType as class Class,
                                    input poSavvionType as SavvionType extent,
                                    output table-handle phTable):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oPL as ParameterList no-undo.
        define variable hBuffer as handle no-undo.
        
        oPL = new ParameterList(1).
        oPL:SetParameter(1,
                         IOModeEnum:TableHandle:ToString(),
                         IOModeEnum:Output:ToString(),
                         phTable).
        poType:Invoke('GetTable', oPL).
        hBuffer = phTable:default-buffer-handle.
        
        iMax = extent(poSavvionType).
        do iLoop = 1 to iMax
           transaction:
            hBuffer:buffer-create().
            poSavvionType[iLoop]:ObjectToBuffer(hBuffer).
            hBuffer:buffer-release().
        end.
    end method.
    
    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. 
    method abstract public void GetTable(output table-handle phTable).
        */
    
    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method abstract public void ObjectToBuffer(input phBuffer as handle).
        

    /** Helper method that writes an element to the SaxWriter.
    
        @param SaxWriter The SAX writer in use
        @param longchar The name of the element being written
        @param longchar The element's value
        @param longchar The namespace used. */ 
    method static protected void WriteElement(input poSaxWriter as SaxWriter,
                                              input pcElementName as longchar,
                                              input pcValue as longchar,
                                              input pcNamespace as longchar):
        SavvionType:WriteElement(
                poSaxWriter,
                pcElementName,
                pcValue,
                pcNamespace,
                ? /* value type */).
    end method.

    /** Helper method for writing logical/boolean elements.
        
        @param SaxWriter The SAX writer in use
        @param longchar The name of the element being written
        @param logical The element's value
        @param longchar The namespace used. */ 
    method static protected void WriteElement(input poSaxWriter as SaxWriter,
                                              input pcElementName as longchar,
                                              input plValue as logical,
                                              input pcNamespace as longchar):
        SavvionType:WriteElement(
            poSaxWriter,
            pcElementName,
            string(plValue, 'true/false'),
            pcNamespace).                                                  
    end method.

    /** Helper method for writing datetime elements.
        
        @param SaxWriter The SAX writer in use
        @param longchar The name of the element being written
        @param datetime-tz The element's value
        @param longchar The namespace used. */ 
    method static protected void WriteElement(input poSaxWriter as SaxWriter,
                                              input pcElementName as longchar,
                                              input ptValue as datetime-tz,
                                              input pcNamespace as longchar):
        SavvionType:WriteElement(
            poSaxWriter,
            pcElementName,
            TimeStamp:ToISODateFromABL(ptValue),
            pcNamespace).                                                  
    end method.

    /** Helper method for writing int64 elements.
        
        @param SaxWriter The SAX writer in use
        @param longchar The name of the element being written
        @param int64 The element's value
        @param longchar The namespace used. */ 
    method static protected void WriteElement(input poSaxWriter as SaxWriter,
                                              input pcElementName as longchar,
                                              input piValue as int64,
                                              input pcNamespace as longchar):
        SavvionType:WriteElement(
            poSaxWriter,
            pcElementName,
            string(piValue),
            pcNamespace).                                                  
    end method.
    
    /** Helper method that writes an element to the SaxWriter.
    
        @param SaxWriter The SAX writer in use
        @param longchar haracter The name of the element being written
        @param longchar The element's value
        @param longchar The namespace used. 
        @param longchar The Type of the value being written. This will add an attribute
               to the element indicating the type of the value. */
    method static protected void WriteElement(input poSaxWriter as SaxWriter,
                                              input pcElementName as longchar,
                                              input pcValue as longchar,
                                              input pcNamespace as longchar,
                                              input pcValueType as longchar):
        poSaxWriter:StartElement(substitute('&1:&2', pcNamespace, pcElementName)).
        
        if pcValue eq ? or pcValue eq '' then
            poSaxWriter:InsertAttribute("xsi:nil", "true").
        else
        do:
            if pcValueType ne ? and pcValueType ne '' then
                poSaxWriter:InsertAttribute("xsi:type", substitute('xsd:&1', WebServiceProtocol:XmlTypeFromABL(pcValueType))).
            
            poSaxWriter:WriteValue(pcValue).
        end.
        
        poSaxWriter:EndElement(substitute('&1:&2', pcNamespace, pcElementName)).
    end method.
    
    /** Passes data from the SAX Reader/Parser into the SavvionType object,
        where it will be set (probably) to a property of that object.    
        
        @param longchar The name of the element whose data we're reading 
        @param longchar The data value */
    method abstract void ReadElement(input pcElementName as longchar,
                                     input pcValue as longchar).
                                                                         
    /** Converts a SOAP message to an array of objects.
        
        @param longchar The XML message in longchar format (likely how it returns from the WebService)
        @param longchar The WebServices operation name
        @param Progress.Lang.Class The actual/concrete type to create.
        @return SavvionType[] An array of objects of that type, containing data. */
    method static SavvionType extent XMLToArray(input pcDocument as longchar,
                                                input pcOperationName as longchar,
                                                input poOutputType as class Class):
        define variable oSavvionType as SavvionType extent no-undo.
        define variable oSaxReader as SaxReader no-undo.
        
        Assert:ArgumentIsType(
                    poOutputType,
                    Class:GetClass('OpenEdge.Lang.BPM.SavvionType')).
        
        SavvionType:moCurrentParseType = poOutputType.
        SavvionType:mcCurrentParseOperation = pcOperationName.
        if valid-object(SavvionType:moCurrentParseObject) then
            SavvionType:moCurrentParseCollection:Clear().
        else
            SavvionType:moCurrentParseCollection = new Collection().

        oSaxReader = new SaxReader().
        
        oSaxReader:SaxReaderStartElement:Subscribe(SavvionType:SaxReaderStartElementHandler).
        oSaxReader:SaxReaderEndElement:Subscribe(SavvionType:SaxReaderEndElementHandler).
        oSaxReader:SaxReaderCharacters:Subscribe(SavvionType:SaxReaderCharactersHandler).
        
        oSaxReader:ParseDocument(pcDocument).
        
        return cast(SavvionType:moCurrentParseCollection:ToArray(), SavvionType).
        finally:
            SavvionType:moCurrentParseType = ?.
            SavvionType:moCurrentParseCollection:Clear().
            SavvionType:moCurrentParseObject = ?.
            SavvionType:mcCurrentParseOperation = ''.
            SavvionType:mcCurrentParseElement = ''.
            
            oSaxReader:SaxReaderStartElement:Unsubscribe(SavvionType:SaxReaderStartElementHandler).
            oSaxReader:SaxReaderEndElement:Unsubscribe(SavvionType:SaxReaderEndElementHandler).
            oSaxReader:SaxReaderCharacters:Unsubscribe(SavvionType:SaxReaderCharactersHandler).
        end finally.
    end method.
    
    /** START-ELEMENT event handler for the SAX-READER. Method implemented as per 
        ABL documentation.  */
    method static void SaxReaderStartElementHandler(input phSaxReader    as handle,
                                                    input pcNamespaceURI as longchar,
                                                    input pcLocalName    as longchar,
                                                    input pcQName        as longchar,
                                                    input phAttributes   as handle):
        define variable oType as SavvionType no-undo.
        
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        case string(pcLocalName):
            when (SavvionType:mcCurrentParseOperation + 'Response') then .
            when (SavvionType:mcCurrentParseOperation + 'Return') then
            do:
                SavvionType:moCurrentParseObject = cast(SavvionType:moCurrentParseType:New(), SavvionType).
                SavvionType:moCurrentParseCollection:Add(SavvionType:moCurrentParseObject).
            end.
            otherwise
            do:
                SavvionType:mcCurrentParseElement = pcLocalName.
                
                /* If the value is nill/null/known, then pass that through to the object */         
                iMax = phAttributes:num-items.
                do iLoop = 1 to iMax:
                    case phAttributes:get-qname-by-index(iLoop):
                        when 'xsi:nil' then
                            if logical(phAttributes:get-value-by-index(iLoop)) then
                                SavvionType:moCurrentParseObject:ReadElement(pcLocalName, ?).
                    end case.
                end.
            end.
        end case.
    end method.
    
    /** END-ELEMENT event handler for the SAX-READER. Method implemented as per 
        ABL documentation.  */
    method static void SaxReaderEndElementHandler(input phSaxReader as handle,
                                                  input pcName as longchar,
                                                  input pcPublicID as longchar,                                                  
                                                  input pcSystemID as longchar):                                                                
        case string(pcName):
            when (SavvionType:mcCurrentParseOperation + 'Response') then .
            /* when closing the <operation>Return element, we can let go of the SavvionType, since we're done with it. */
            when (SavvionType:mcCurrentParseOperation + 'Return') then
                SavvionType:moCurrentParseObject = ?.
        end case.
        
        SavvionType:mcCurrentParseElement = ''.             
    end method.

    /** CHARACTERS event handler for the SAX-READER. Method implemented as per 
        ABL documentation.  */
    method static void SaxReaderCharactersHandler(input phSaxReader as handle,
                                                  input pcCharData as longchar,
                                                  input piNumChars as integer):
        SavvionType:moCurrentParseObject:ReadElement(SavvionType:mcCurrentParseElement, pcCharData).
        
        catch oError as Progress.Lang.Error:
            message program-name(1) program-name(2) skip(2)
                oError:GetMessage(1) skip
            view-as alert-box error title '[PJ DEBUG]'.
            
            undo, throw oError.
        end catch.
    end method.
    
end class.
