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
/** -----------------------------------------------------------------------
    File        : ServiceMessageConsumerCollection
    Purpose     : A collection of one or more requests when 
                  service requests are made.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Apr 26 15:03:13 EDT 2010
    Notes       : * This class is used by classes that will perform service
                    requests on behalf of other classes (for example when a Presenter 
                    makes requests for multiple Models so that there are fewer calls
                    to the AppServers).
                  * This class will typically only be used in the DataboundPresenter,
                    but the functionality has been separated out so that it can potentially
                    be used elsewhere.
                  * One IMessageConsumer can be used by multiple messages (message IDs). However,
                    there's a single consumer per message.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageConsumerCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer.
using OpenEdge.Lang.Assert.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageConsumerCollection:
    
    /* Static so that we only have one instance of the TT in memory.*/
    define private static temp-table Messages no-undo
        field RequestGroupKey as character
        field MessageId as character        
        field Consumer as Object        /* IMessageConsumer */
        field IsOutstanding as logical
        
        /* A message ID is globally unique */
        index idx0 as unique MessageId
        
        /* Each message can appear only once per RequestGroupKey */
        index idx1 as primary unique RequestGroupKey MessageId
        
        index idx2 RequestGroupKey IsOutstanding
        /* A consumer can be used by many messages, although typically only by one */
        index idx3 RequestGroupKey Consumer
        .
    
    /** (mandatory) A key value used to aggregate requests. This request key needs to be globally unique */
    define public property RequestGroupKey as character no-undo get. private set.
    
    /** (derived, readonly) The number of requests/messages herein. */
    define public property TotalMessages as integer no-undo
        get():
            return ServiceMessageConsumerCollection:EnumerateMessages(RequestGroupKey, false).
        end get.
    
    /** (derived, readonly) The number of requests/messages that  are outstanding
        (ie have not received a response yet). */
    define public property OutstandingMessages as integer no-undo
        get():
            return ServiceMessageConsumerCollection:EnumerateMessages(RequestGroupKey, true).
        end get.
    
    /** @param character The parent key all these messages */
    constructor public ServiceMessageConsumerCollection(input pcRequestGroupKey as character):
        Assert:ArgumentNotNullOrEmpty(pcRequestGroupKey, 'request key').
        
        RequestGroupKey = pcRequestGroupKey.
    end constructor.
    
    constructor public ServiceMessageConsumerCollection():
        this-object(guid(generate-uuid)).
    end constructor.
    
    destructor public ServiceMessageConsumerCollection():
        ReleaseMessages().
    end destructor.
    
    /** Releases/removes all messages for this RequestGroupKey from the (shared/static)
        temp-table. */
    method public void ReleaseMessages():
        ServiceMessageConsumerCollection:ReleaseMessages(RequestGroupKey).
    end method.
    
    /** Releases all messages for a specific RequestGroupKey.
        
        @param integer The weak reference to the RequestGroupKey. */
    method static private void ReleaseMessages(input pcRequestGroupKey as character):
        define buffer lbMsg for Messages.
        define query qryMsg for lbMsg.
        
        open query qryMsg preselect each lbMsg where lbMsg.RequestGroupKey = pcRequestGroupKey.
        get first qryMsg.
        do while not query-off-end('qryMsg'):
            delete lbMsg.
            get next qryMsg.
        end.
        finally:
            close query qryMsg.
        end finally.
    end method.
    
    /** Retrieves the MessageConsumer for a single message id. While the same IMessageConsumer
        can be used by multiple messages, there's a single consumer per message.
        
        @param character The message's unique ID
        @param IMessageConsumer A consumer for the message.  */
    method public IMessageConsumer GetMessageConsumer(input pcMessageId as longchar):
        define variable cStringId as character no-undo.
        
        define buffer lbMsg for Messages.
        
        cStringId  = pcMessageId.
        find lbMsg where
             lbMsg.RequestGroupKey = RequestGroupKey and
             lbMsg.MessageId = cStringId. 
        
        return cast(lbMsg.Consumer, IMessageConsumer). 
    end method.
        
    /** Retrieves MessageConsumer objects for all given message ids.
        
        @param character An array of message ids
        @param IMessageConsumer An array of message consumers for the message.  */
    method public IMessageConsumer extent GetMessageConsumer(input pcMessageId as longchar extent):
        define variable oMC as IMessageConsumer extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
            
        iMax = extent(pcMessageId).
        extent(oMC) = iMax.
        
        do iLoop = 1 to iMax:
            oMC[iLoop] = GetMessageConsumer(pcMessageId[iLoop]).
        end.
        
        return oMC.
    end method.

    /** Returns an array of the message IDs for the messages bundled herein.
        
        @return String An array of message ID for this bundle. */ 
    method public longchar extent GetMessages():
        define variable cMsg as character extent no-undo.
        define buffer lbMsg for Messages.
        define query qryMsg for lbMsg.
        
        open query qryMsg preselect 
            each lbMsg where lbMsg.RequestGroupKey = RequestGroupKey.
        extent(cMsg) = query qryMsg:num-results.
        
        get first qryMsg.
        do while not query-off-end('qryMsg'):
            cMsg[current-result-row('qryMsg')] = lbMsg.MessageId. 
            get next qryMsg.
        end.
        
        return cMsg.      
        finally:
            close query qryMsg.
        end finally.
    end method.
    
    /** Returns the request key for a message. Each message ID can only be part of
        a single request.
         
        @param character The Message Id 
        @return character The request key for the input message ID.      */
    method static public character GetMessageRequestGroupKey (input pcMessageId as longchar):
        define variable cStringId as character no-undo.
        define buffer lbMsg for Messages.
        
        cStringId = pcMessageId.
        find lbMsg where lbMsg.MessageId = cStringId.
        
        return lbMsg.RequestGroupKey.
    end method.
    
    /** Add a request to this collection.
        
        @param character The unique identifier of the message.
        @param IMessageConsumer The object that responds to the message.    */
    method public void AddMessage(input pcMessageId as longchar,
                                  input poMessageConsumer as IMessageConsumer):
        define variable cStringMsgId as character no-undo.
        define buffer lbMsg for Messages.
        
        cStringMsgId = pcMessageId.
        create lbMsg.
        assign lbMsg.RequestGroupKey = RequestGroupKey
               lbMsg.MessageId = cStringMsgId
               lbMsg.Consumer = poMessageConsumer
               lbMsg.IsOutstanding = true.
    end method.
    
    /** Removes a request from this collection.
        
        @param character The unique message ID for a message. */    
    method public void RemoveMessage(input pcMessageId as longchar):
        define variable cStringMsg as character no-undo.
        
        define buffer lbMsg for Messages.
        
        cStringMsg  = pcMessageId.        
        find lbMsg where
             lbMsg.RequestGroupKey = RequestGroupKey and
             lbMsg.MessageId = cStringMsg .
        delete lbMsg.
    end method.
    
    /** Removes all the messages associated with a message consumer. 
        a request from the bundle.
        
        @param character The unique message ID for a message. */    
    method public void ReleaseConsumer(input poMessageConsumer as IMessageConsumer):
        define variable oMC as IMessageConsumer extent no-undo.
        define buffer lbMsg for Messages. 
        define query qryMsg for lbMsg.
        
        open query qryMsg preselect 
            each lbMsg where
                 lbMsg.RequestGroupKey = RequestGroupKey and
                 lbMsg.Consumer = poMessageConsumer.
        
        get first qryMsg.
        do while not query-off-end('qryMsg'):
            delete lbMsg.
            get next qryMsg.
        end.
        finally:
            close query qryMsg.
        end finally.
    end method.
    
    /** A response has been received for a given message (by ID).
        
        @param character The unique identifier of the message.
        @param IMessageConsumer The consumer for the message received. */
    method public IMessageConsumer ResponseReceived(input pcMessageId as longchar):
        define variable oMC as IMessageConsumer no-undo.
        define variable cStringId as character no-undo.
        define buffer lbMsg for Messages.
        
        cStringId = pcMessageId.
        find lbMsg where
             lbMsg.RequestGroupKey = RequestGroupKey and
             lbMsg.MessageId = cStringId.
        lbMsg.IsOutstanding = false.
        
        return cast(lbMsg.Consumer, IMessageConsumer).
    end method.

    /** A response has been received for a given message (by ID).
        
        @param character An array of unique identifiers of the message.
        @param IMessageConsumer An attay of the consumers for the messages received. */
    method public IMessageConsumer extent ResponseReceived(input pcMessageId as longchar extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oMC as IMessageConsumer extent no-undo.

        iMax = extent(pcMessageId).
        extent(oMC) = iMax.
        
        do iLoop = 1 to iMax:            
            oMC[iLoop] = ResponseReceived(pcMessageId[iLoop]).
        end.
        
        return oMC.
    end method.
    
    /** Returns an array of the message consumers for the messages bundled herein.
        
        @return IMessageConsumer An array of message consumers the messages. */ 
    method public IMessageConsumer extent GetMessageConsumers():
        define variable oMC as IMessageConsumer extent no-undo.        
        define buffer lbMsg for Messages.
        define query qryMsg for lbMsg.
        
        open query qryMsg preselect 
            each lbMsg where lbMsg.RequestGroupKey = RequestGroupKey.
        
        extent(oMC) = query qryMsg:num-results.
        
        get first qryMsg.
        do while not query-off-end('qryMsg'):
            oMC[current-result-row('qryMsg')] = cast(lbMsg.Consumer, IMessageConsumer). 
            get next qryMsg.
        end.
        
        return oMC.
        finally:
            close query qryMsg.
        end finally.
    end method.
    
    /** Enumerates the number of messages for the requestions
        
        @param integer The requesting object (weak reference)
        @param logical Whether to include all messages or just the outstanding ones. */ 
    method static private integer EnumerateMessages(input pcRequestGroupKey as character,
                                                    input plOutstandingOnly as logical):
        define buffer lbMsg for Messages.
        define query qryMsg for lbMsg.
        
        if plOutstandingOnly then
            open query qryMsg preselect 
                each lbMsg where 
                      lbMsg.RequestGroupKey = pcRequestGroupKey and
                      lbMsg.IsOutstanding = true.        
        else
            open query qryMsg preselect 
                each lbMsg where 
                      lbMsg.RequestGroupKey = pcRequestGroupKey.
        
        return query qryMsg:num-results.
        finally:
            close query qryMsg.
        end finally.
    end method.
    
end class.
