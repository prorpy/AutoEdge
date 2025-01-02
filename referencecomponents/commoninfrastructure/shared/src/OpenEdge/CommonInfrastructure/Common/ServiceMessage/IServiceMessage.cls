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
    File        : IServiceMessage
    Purpose     : Service message (request-response) passed through OERA layers 
    Syntax      : 
    Description : Base interface for service message (parameter) classes. 
                  Defines properties needed to identify the message in all 
                  OERA layers
    @author hdaniels
    Created     : Tue Feb 09 03:12:07 EST 2010
    Notes       : * Specialised in name by IServiceRequest and -Response, although
                    those interfaces are empty (they exist only as a means to identify
                    the type of message to the compiler and programmer).
                  * The GetMessagaData() and SetMessageData() methods allow access to the data 
                    being sent/received by this message. This data is formatted per the 
                    MessageDataFormat and is stored in the message as either LONGCHAR, HANDLE or 
                    ISerializable object.
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.Core.Util.ISerializable.
using OpenEdge.Lang.DataTypeEnum.
using Progress.Lang.Object.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage:
    
    /** Unique message identifier. Allows for completely decoupled 
        request and response messages to be tied back together. This will probably 
        be a GUID. */
    define public property MessageId as longchar no-undo get.
    
    /** Type of request (ServiceMessageActionEnum). The defaults are Fetch,Save,Define but
        may be overridden (by FetchByRegion or something similar). 
        
        All IServiceMessage instances that are issued together must be of the same type,
        and the same type as their bundle. */ 
    define public property ActionType as ServiceMessageActionEnum no-undo get.
    
    /** Identifies the service message target. 
        Used to find the ServiceAdapter and Business component */
    define public property Service as character no-undo get.
    
    /** Set the data associated with the message.         
        @param lonchar Stores a values 
        @param DataFormatEnum The format of the data target value */
    method public void SetMessageData(input pcData as longchar,
                                      input poMessageDataFormat as DataFormatEnum).
    method public void SetMessageData (input pcData as longchar).
    
    /** Retrieve the message data.       
        @param output-longchar Message data, returned as a longchar. */
    method public void GetMessageData(output pcData as longchar).

    /** The message's data is transported as temp-table/prodataset and is referenced by handle */    
    method public void SetMessageData(input phData as handle,
                                      input poMessageDataFormat as DataFormatEnum).
                                        
    /** Retrieve the message data.      
        @param output-longchar Message data, returned as a handle (prodataset/buffer) */    
    method public void GetMessageData(output phData as handle).
        
    /** The message's data is transported in object form and is referenced as such */
    method public void SetMessageData(input poData as ISerializable,
                                      input poMessageDataFormat as DataFormatEnum).
                               
    /** Retrieve the message data.       
        @param output-longchar Message data, returned as an Object. */
    method public void GetMessageData(output poData as ISerializable).
    
end interface.
