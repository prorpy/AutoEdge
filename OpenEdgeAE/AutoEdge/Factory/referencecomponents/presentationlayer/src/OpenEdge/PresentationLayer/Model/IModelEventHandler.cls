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
    File        : IModelEventHandler
    Purpose     : Interface for Event handlers for events in the Model.
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Oct 25 16:43:05 EDT 2010
    Notes       : * Typical implementers include Presenters and ModelQueries; 
                    can be others too.
  ----------------------------------------------------------------------*/
using OpenEdge.PresentationLayer.Model.IModelEventHandler.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.
using OpenEdge.CommonInfrastructure.Common.IComponent.

interface OpenEdge.PresentationLayer.Model.IModelEventHandler:
          
    /** Fired after a record has been added to the model.
    
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    method public void DataAddHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is added to the model. 
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */        
    method public void DataAddErrorHandler(input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
    /** Fired after a record has been removed
    
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    method public void DataDeleteHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is deleted from the model
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    method public void DataDeleteErrorHandler(input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).

    /** Fired after a record has been saved to the model (local save, 
        not a commit).
        
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    method public void DataSaveHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is saved locally
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    method public void DataSaveErrorHandler(input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
    /** Event fired after the Model received its response from a FetchData() 
        service request. 
    
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    method public void DataCommittedHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs).
    
    /** This event fires when an error occurs when data is saved to a service.
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    method public void DataCommitErrorHandler(input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).    
    
    /** Event fired after the Model received its response from a SaveData() 
        service request. 
        
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    method public void DataFetchedHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is fetched from a service.
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    method public void DataFetchErrorHandler(input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
    /** Event fired after the Model received its response from a service request.
        Individual events like DataFetched above will also fire.
        
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    method public void ServiceRequestCompletedHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs on a service request.
        
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    method public void ServiceRequestErrorHandler(input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
end interface.
