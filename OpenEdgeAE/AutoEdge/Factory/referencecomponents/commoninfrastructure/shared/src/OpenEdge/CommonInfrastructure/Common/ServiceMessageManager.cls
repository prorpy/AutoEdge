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
    File        : ServiceMessageManager
    Purpose     : Manager and broker of ServiceMessages (requests/responses)
    Syntax      : 
    Description : 
    @author pjudge 
    Created     : Mon Apr 26 12:26:37 EDT 2010
    Notes       : * This manager groups requests by service before running the
                    requests on the services
                  * It maintains a lookup map of message IDs and message consumers,
                    so that when it receives a response, it know who to pass that
                    response on to.
  ----------------------------------------------------------------------  */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.

using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IManager.
using OpenEdge.CommonInfrastructure.Common.Service.

using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.

using OpenEdge.Lang.String.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessageManager inherits Service 
            implements IServiceMessageManager, IManager:
    
    /** Use this property in lieu of having to say Class:GetClass('....IServiceManager') every time */
    define static public property IServiceMessageManagerType as class Class no-undo get. private set.
    
    constructor static ServiceMessageManager():
        ServiceMessageManager:IServiceMessageManagerType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.IServiceMessageManager').
    end constructor.
    
    /** A (lookup) map of message ID's and their requestors. */
    define protected property MessageConsumers as IMap no-undo get. private set.
    
    constructor public ServiceMessageManager(input poComponentInfo as IComponentInfo):
        super(poComponentInfo).
    end constructor.
    
    /** Executes the request(s) asynchroronously.
    
        @param IMessageConsumer The object initiating this request 
        @param IServiceRequest An array of the request(s) to be executed.  */
    method public void ExecuteRequest (input poMessageRequestor as IMessageConsumer,
                                       input poRequests as IServiceRequest extent):
        define variable oRequestByService as IMap no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oString as String no-undo.
        define variable oServiceProvider as IServiceProvider no-undo.
        
        oRequestByService = GroupRequestsByService(poRequests, false).
        
        /* perform the requests per service. */                
        oIterator = oRequestByService:KeySet:Iterator().
        do while oIterator:HasNext():
            assign oString = cast(oIterator:Next(), String)
                   oServiceProvider = ServiceManager:GetServiceProvider(string(oString:Value)).
            oServiceProvider:ExecuteRequest(cast(cast(oRequestByService:Get(oString), ICollection):ToArray(), IServiceRequest)).
        end.
    end method.
    
    /** Executes responses for the message requested earlier.
        
        @param poResponse A single response message  */
    method public void ExecuteResponse(input poResponse as IServiceResponse):
        /* Calling Remove() on the Map returns the value before removing it from the Map.
           We want to remove the consumer reference to avoid leaks. */
        cast(MessageConsumers:Remove(
                new String(cast(poResponse, IServiceMessage):MessageId)), IMessageConsumer)
                        :ReceiveMessageResponse(poResponse).
    end method.
    
    /** Executes responses for the message(s) requested earlier.
        
        @param poResponse An array of request responses. */
    method public void ExecuteResponse(input poResponse as IServiceResponse extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = extent(poResponse).
        do iLoop = 1 to iMax:
            ExecuteResponse(poResponse[iLoop]).
        end.
    end method.
    
    /** A synchronous/linear/connected service request call. Services a 
        request in a synchronous manner. There are no no IMessageConsumers,
        and that whoever calls this method knows how to deal with the responses.
        
        @param IServiceRequest An array of the request(s) to be executed.
        @return IServiceResponse An array of response for the requests.     */
    method public IServiceResponse extent ExecuteRequest(input poRequests as IServiceRequest extent):                                                                 
        define variable oResponse as IServiceResponse extent no-undo.
        define variable oServiceResponse as IServiceResponse extent no-undo.
        define variable oRequestByService as IMap no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oString as String no-undo.
        define variable oServiceProvider as IServiceProvider no-undo.
        define variable iExtent as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        oRequestByService = GroupRequestsByService(poRequests, true).
        extent(oResponse) = extent(poRequests).
        iExtent = 0.
        
        /* perform the requests per service. */
        oIterator = oRequestByService:KeySet:Iterator().
        do while oIterator:HasNext():
            assign oString = cast(oIterator:Next(), String)
                   oServiceProvider = ServiceManager:GetServiceProvider(string(oString:Value)).
            
            oServiceResponse = oServiceProvider:ExecuteSyncRequest(
                    cast(cast(oRequestByService:Get(oString), ICollection):ToArray(), IServiceRequest)).
            
            /* Add the responses from this service call to the complete set. */                    
            iMax = extent(oServiceResponse).
            do iLoop = 1 to iMax:
                oResponse[iExtent + iLoop] = oServiceResponse[iLoop]. 
            end.
            iExtent = iExtent + iMax.
        end.
        
        return oResponse.
    end method.
    
    /** Groups a set of requests by service. There's no sorting done on the service; the grouped
        requests are created in the order in which they are found in the passed message collection. 
        
        @param IServiceRequest An array of messages (requests) which are being grouped.
        @param logical  Whether the request is synchronous or not. If not so,  maintain a
               map of the request IDs and the consumers.
        @return IMap A collection of service requests, keyed per service.           */
    method protected IMap GroupRequestsByService(input poRequests as IServiceRequest extent,
                                                 input plSyncRequest as logical):        
        define variable oMessageId as String no-undo.
        define variable oRequestByService as IMap no-undo.
        define variable oRequest as IServiceRequest no-undo.
        define variable oString as String no-undo.
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        /* Group all together requests by service, which allows us to make one
           call per service (via the service adapter). */
        oRequestByService = new TypedMap(String:Type,
                                         Class:GetClass('OpenEdge.Lang.Collections.ICollection')).
        iMax = extent(poRequests).
        do iLoop = 1 to IMax:
            oRequest = poRequests[iLoop].
            oString = new String(cast(oRequest, IServiceMessage):Service).
            oMessageId = new String(cast(oRequest, IServiceMessage):MessageId).
            
            if not oRequestByService:ContainsKey(oString) then
                oRequestByService:Put(oString, new Collection()).
            
            cast(oRequestByService:Get(oString), ICollection):Add(oRequest).
            
            /* Save off the consumer for this message */
            if not plSyncRequest then
                MessageConsumers:Put(oMessageId, poRequests[iLoop]).
        end.
                
        return oRequestByService.               
    end method.
    
    method override public void DestroyComponent():
        super:DestroyComponent().
        
        MessageConsumers:Clear().
    end method.

    method override public void CreateComponent():
        super:CreateComponent().
        
        MessageConsumers = new TypedMap(
                                    String:Type,
                                    Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer')).
    end method.
    
end class.
