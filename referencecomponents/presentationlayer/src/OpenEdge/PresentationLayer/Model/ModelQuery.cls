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
    File        : ModelQuery
    Purpose     : Specialisation of Query class for MVP Model
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 26 15:05:18 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.IModelQuery.
using OpenEdge.PresentationLayer.Model.IModelEventHandler.
using OpenEdge.PresentationLayer.Model.IModel.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.

using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.ITableOwner.
using OpenEdge.Core.System.Query.
using OpenEdge.Core.System.EventArgs.

class OpenEdge.PresentationLayer.Model.ModelQuery inherits Query
        implements IModelQuery, IModelEventHandler:
    
    define public property Model as IModel no-undo get. protected set.
    define public property QueryName as character no-undo get. protected set.
    
    @todo(task="implement", action="replace with SelectedRowCollection").
    define public property NumSelectedRows as integer no-undo get. protected set. 
    
    /** Does this query object require a Reopen() call? A query might be flagged as such 
        by a Model when new data is added from a busines entity (or even locally) in 
        batch/bundle mode. */
    define public property RequiresReopen  as logical no-undo get. set.
    
    define private variable mhBaseQueryHandle as handle no-undo. 
    
    /* In some cases we use this object to store prebuilt queries, such as a 
       ProDataSet's top-nav-query; in this case, we have a query handle already 
       and this is considereed prebuilt. We can change and (re)open the query,
       but the handle stays the same, and cannot be changed, nor can the buffers 
       in the query.
       
       The Query object does not support the changing of the QueryHandle. */
    constructor public ModelQuery (poModel as IModel,
                                   pcName as character,
                                   phQueryHandle as handle,
                                   poQueryDefinition as IQueryDefinition):
        
        /* A Model is always aTableOwner */
        super(cast(poModel, ITableOwner), poQueryDefinition).
        
        if (pcName eq ? or pcName = '') then
        do: 
           if valid-handle(phQueryHandle) then
               pcName = string(phQueryHandle).
           else 
               /* need /something/ */
               pcName = string(int(this-object)).
        end.
        assign Model = poModel
               mhBaseQueryHandle = phQueryHandle 
               QueryHandle = phQueryHandle
               QueryName = pcName 
               
               /* we already have a working query */
               BuildQuery = not valid-handle(phQueryHandle).
        
        OpenEdge.PresentationLayer.Model.Model:SubscribeModelEvents(
                this-object:Model, this-object).               
    end constructor.
    
    constructor public ModelQuery (poModel as IModel,
                                   pcName as character,
                                   poQueryDefinition as IQueryDefinition):
        this-object(poModel,pcName,?,poQueryDefinition).  
    end constructor.
    
    destructor public ModelQuery():
        OpenEdge.PresentationLayer.Model.Model:UnsubscribeModelEvents(
                this-object:Model, this-object).
    end destructor.
    
    /* parameter is number of row selection, not query ordinal */
    method public char extent GetSelectedRowKey(piRow as int):
    end method.
        
    method public void ClearSelection():
    end method.
            
    method public void SelectRow(pcRowKey as char extent).
    end method.
    
    method public void SelectCurrentRow().    
    end method.
    
    method public void DeselectRow(pcRowKey as char extent).
    end method.
    
    method public void DeselectCurrentRow().
    end method.
    
    /** Allows the DatasetModel to use the queries created by
       the ProBindingSource if it needs to. DatasetModel:CreateDefaultQUeries()
       creates a bunch of queries based on the relations; the PBS uses the same
       queries (the PDS' relation queries) as a basis for its' own 'smaller'/individual
       queries when its working in a heirachical grid like the UlraControls' UltraGrid.
       
       The query definitions will stay the same for all queries on a relation - so you won't be able
       to sort customer 1's orders differently from customer 2's in the same grid - but we're
       going to use that single query def for all the individual queries, and will do so by pushing 
       the actual query in use in to this object.
       
       @param handle An ABL query handle        */
    method public void SetQueryHandle(phQuery as handle):
        QueryHandle = phQuery.
    end method.
    
    method public void ResetQueryHandle():
        QueryHandle = mhBaseQueryHandle.
    end method.

    /* Event handlers for events in the Model, so that the ModelQuery can listen to local (create, update, delete) or
       service (fetch, commit) events and reopen. The Model will in all likelihood perform any subscriptions, although
       the ModelQuery class may do this too.    */    

    /** Fired after a record has been created in the model (local)
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    method public void DataAddHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        RequiresReopen = QueryRequiresReopen(poEventArgs:TableName).
    end method.
    
    /** Fired after a record has been removed (local)
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    method public void DataDeleteHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        RequiresReopen = QueryRequiresReopen(poEventArgs:TableName).
    end method.

    /** Fired after a record has been saved to the model (local save, 
        not a commit).
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    method public void DataSaveHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        RequiresReopen = QueryRequiresReopen(poEventArgs:TableName).
    end method.
    
    /** Event fired after the Model received its response from a FetchData() 
        service request. 
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */        
    method public void DataCommittedHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        RequiresReopen = QueryRequiresReopen(poEventArgs:TableName).
    end method.
    
    /** Event fired after the Model received its response from a SaveData() 
        service request. 
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    method public void DataFetchedHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        RequiresReopen = QueryRequiresReopen(poEventArgs:TableName).
    end method.
    
    /** Event fired after the Model received its response from a service request.
        Individual events like DataFetched above will also fire.
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    method public void ServiceRequestCompletedHandler(input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        RequiresReopen = QueryRequiresReopen(poEventArgs:TableName).
    end method.

    method override protected void Open( input phQuery as handle ):
        super:Open(phQuery).
        RequiresReopen = false.
    end method.
    
    /** Assume query requries a reopen if any of the tables in the Model Action are in the
        query itself. 
        
        @param character An array of tables being checked
        @return logical Whether the query needs to be reopened.    */
    method protected logical QueryRequiresReopen (input pcActionTables as character extent):
        define variable cQueryTables as character extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iLoop2 as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iMax2 as integer no-undo.
        define variable lContainsTable as logical no-undo.
        define variable lReopen as logical no-undo.
        
        /* If we already require a reopen, then go no further. */
        lReopen = RequiresReopen.
        if not lReopen then
        do:
            cQueryTables = Definition:GetBufferList().
            lContainsTable = false.
            
            iMax = extent(pcActionTables).
            iMax2 = extent(cQueryTables).
            do iLoop = 1 to iMax while not lContainsTable:
                do iLoop2 = 1 to iMax2 while not lContainsTable:
                    lContainsTable = cQueryTables[iLoop2] eq pcActionTables[iLoop]. 
                end.
            end.
            lReopen = IsOpen and lContainsTable.
        end.
        
        return lReopen.
    end method.

    method public void DataAddErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void DataDeleteErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void DataSaveErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void DataCommitErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void DataFetchErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void ServiceRequestErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    
end class.
