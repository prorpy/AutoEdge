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
    File        : ServiceMessage
    Purpose     : A message which may be the request or response portion of a data
                  fetch, save, define or other message. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Apr 26 16:46:22 EDT 2010
    Notes       : * This message class is abstract because we want to highlight
                    the separation of request and response.
                  * If the message data is a stored in a temp-table/prodataset or
                    PLO, then we only store a reference. When the message is passed
                    across a session boundary, it's data must be serialized and deserialized
                    by the service adapter and service interface.
                  * This class is itself serialisable. Note that we don't write the 
                    MessageData as part of the serialization since that is typically
                    extracted into a ProDataSet by the service adapter for transport;
                    that being more efficient/faster.
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.

using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.ISerializable.

using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessage abstract
        implements IServiceMessage, IExternalizable:
    
    /** Unique message identifier. Allows for completely decoupled request and response
        messages to be tied back together. This will probably be a GUID. */
    define public property MessageId as longchar no-undo get. private set.
    
    /** Type of request (ServiceMessageActionEnum). The defaults are Fetch,Save,Define but
        may be overridden (by FetchByRegion or something similar). 
        
        All IServiceMessage instances that are issued together must be of the same type,
        and the same type as their bundle. */
    define public property ActionType as ServiceMessageActionEnum no-undo get. private set.
    
    /** Identifies the service message target.
        Used to find the ServiceAdapter and Business component */
    define public property Service as character no-undo get. private set.
    
    /** The data transport type for this message. These may differ for request and response. */
    define private variable mcMessageData as longchar no-undo.
    define private variable moMessageData as ISerializable no-undo.
    define private variable mhMessageData as handle no-undo.
    
    define private variable moMessageDataFormat as DataFormatEnum no-undo.
    define private variable moMessageDataType as DataTypeEnum no-undo.
    
    constructor public ServiceMessage():
        /* serialization only */
    end constructor.
    
    /** This constructor will typically only be used for Requests, not responses,
        since the response needs a MessageId for ithe request that triggered it.
        
        @param pcService The service name for which this message is being incokved.
        @param poMessageType Uses the ServiceMessageActionEnum to define the action of the message. */
    constructor public ServiceMessage(input pcService as character,
                                      input poMessageType as ServiceMessageActionEnum):
        this-object(guid(generate-uuid), pcService, poMessageType).
    end constructor.
    
    /*  General constructor for requests and responses. 
        
        @param pcMessageId 
        @param pcService The service name for which this message is being invoked.
        @param poMessageType Uses the ServiceMessageActionEnum to define the action of the message.  */    
    constructor public ServiceMessage(input pcMessageId as longchar,
                                      input pcService as character,
                                      input poActionType as ServiceMessageActionEnum):
        Assert:ArgumentNotNullOrEmpty(pcMessageId, 'Message Id').
        Assert:ArgumentNotNullOrEmpty(pcService, 'Service').
        Assert:ArgumentNotNull(poActionType, 'Action type').
        
        assign MessageId = pcMessageId
               ActionType = poActionType
               Service = pcService.
    end constructor.
    
    method override public logical Equals(p0 as Object):
        define variable lEqual as logical no-undo.
        
        lEqual = super:Equals(p0).
        
        if not lEqual then
          lEqual = type-of(p0, IServiceMessage) and
                   this-object:MessageId eq cast(p0, IServiceMessage):MessageId. 
        
        return lEqual.
    end method.

    /** The GetMessageData() and SetMessageData() methods allow access to the data being sent/
        received by this message. This data is formatted per the MessageDataFormat above;
        and is stored in the message as either LONGCHAR, HANDLE or ISerializable Object */
    method public void SetMessageData (input pcMessageData as longchar,
                                       input poMessageDataFormat as DataFormatEnum):
        Assert:ArgumentNotNull(poMessageDataFormat, 'Data format').                                           
        assign moMessageDataFormat = poMessageDataFormat
               moMessageDataType = DataTypeEnum:LongChar
               mcMessageData = pcMessageData.
    end method.

    method public void SetMessageData (input pcMessageData as longchar):
        SetMessageData(pcMessageData, DataFormatEnum:Other).
    end method.
    
    method public void GetMessageData(output pcData as longchar):
        if not moMessageDataType:Equals(DataTypeEnum:LongChar) then
            return error new InvalidValueSpecifiedError('data format', ' - expecting ' + DataTypeEnum:LongChar:ToString()).
            
        pcData = mcMessageData.
    end method.
    
    method public void SetMessageData(input phData as handle):
        define variable oMessageDataFormat as DataFormatEnum no-undo.
        
        Assert:ArgumentNotNull(phData, 'Data structure').
        
        case DataTypeEnum:EnumFromString(phData:type):
            when DataTypeEnum:TempTable or when DataTypeEnum:Buffer then oMessageDataFormat = DataFormatEnum:TempTable. 
            when DataTypeEnum:Dataset then oMessageDataFormat = DataFormatEnum:ProDataSet.
            otherwise return error new InvalidValueSpecifiedError('handle type', ' - expecting ' + DataTypeEnum:Handle:ToString()). 
        end case.
        
        SetMessageData(phData, oMessageDataFormat).
    end method.
    
    method public void SetMessageData(input phData as handle,
                                      input poMessageDataFormat as DataFormatEnum):
        Assert:ArgumentNotNull(phData, 'Data structure').
        Assert:ArgumentNotNull(poMessageDataFormat, 'Data format').
        
        case DataTypeEnum:EnumFromString(phData:type):
            when DataTypeEnum:TempTable or when DataTypeEnum:Buffer then 
                if not poMessageDataFormat:Equals(DataFormatEnum:TempTable) then
                    return error new InvalidValueSpecifiedError(
                            'data format for ' + DataTypeEnum:EnumFromString(phData:type):ToString(),
                            ' - expecting ' + DataFormatEnum:TempTable:ToString()).
            
            when DataTypeEnum:Dataset then
                if not poMessageDataFormat:Equals(DataFormatEnum:ProDataSet) then
                    return error new InvalidValueSpecifiedError(
                            'data format for ' + DataTypeEnum:Dataset:ToString(),
                            ' - expecting ' + DataFormatEnum:ProDataSet:ToString()).
            
            otherwise 
                return error new InvalidValueSpecifiedError('data type ', ' - expecting ' + DataTypeEnum:Handle:ToString()). 
        end case.
        
        assign moMessageDataFormat = poMessageDataFormat
               moMessageDataType = DataTypeEnum:Handle
               mhMessageData = phData.
    end method.
    
    method public void GetMessageData(output phData as handle):
        if not moMessageDataType:Equals(DataTypeEnum:Handle) then
            return error new InvalidValueSpecifiedError('data format', ' - expecting ' + DataTypeEnum:Handle:ToString()).
        
        @todo(task="question", action="righty?").
        case moMessageDataFormat:
            /* We want to pass the dataset out in a deep copy, so that it doesn't go away when this message is deleted */
            when DataFormatEnum:ProDataSet then phData = mhMessageData:handle.
            otherwise phData = mhMessageData.
        end case.
    end method.
    
    method public void SetMessageData(input poData as ISerializable,
                                      input poMessageDataFormat as DataFormatEnum):
        Assert:ArgumentNotNull(poMessageDataFormat, 'Data format').
                                                  
        assign moMessageDataFormat = poMessageDataFormat
               moMessageDataType = DataTypeEnum:ProgressLangObject
               moMessageData = poData.
    end method.
    
    method public void GetMessageData(output poData as ISerializable):
        if not moMessageDataType:Equals(DataTypeEnum:ProgressLangObject) then
            return error new InvalidValueSpecifiedError('data format', ' - expecting ISerializable object').
        
        poData = moMessageData.                    
    end method.

    method public void WriteObject(input poStream as IObjectOutput):
        poStream:WriteLongchar(MessageId).
        poStream:WriteEnum(ActionType).
        poStream:WriteChar(Service).
        
        /* We don't write the MessageData since that is typically extracted into a ProDataSet
           by the service adapter for transport. */
    end method.
    
    method public void ReadObject(input poStream as IObjectInput):
        MessageId = poStream:ReadLongchar().
        ActionType = cast(poStream:ReadEnum(), ServiceMessageActionEnum).
        Service = poStream:ReadChar().
    end method.
    
end class.
