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
    File        : Query
    Purpose     : General query object/wrapper
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jul 31 16:34:19 EDT 2009
    Notes       : The buffers this query uses could also theoretically
                  be encapsulated. This is left as an exercise for the
                  reader :) 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.Query.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryDefinitionEventArgs.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.ITableOwner.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.RowPositionEnum.
using OpenEdge.Core.System.QueryElementEnum.
using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.UnsupportedOperationError.

using OpenEdge.Core.System.EventArgs.
using OpenEdge.Core.System.QueryElementEnum.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.Collections.ObjectStack.

using OpenEdge.Lang.FlagsEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.FindTypeEnum.
using OpenEdge.Lang.LockModeEnum.
using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.String.
using Progress.Lang.Error.

class OpenEdge.Core.System.Query use-widget-pool 
        implements IQuery:

    /** Fired when the query is opened or reopened. This event only fires on query represented by the public QueryHandle.
        
        @param IQuery The query being operated on
        @param EventArgs Arguments pertaining to the operation. */
    define public event QueryOpened signature void (input poQuery as IQuery, input poArgs as EventArgs).

    /** Allows raising of the QueryOpened event by derived classes. 
        
        @param EventArgs Arguments for the event.  */
    method protected void OnQueryOpened(input poArgs as EventArgs):
        this-object:QueryOpened:Publish(this-object, poArgs).
    end method.
    
    /** Fired when the query is closed. This event only fires on query represented by the public QueryHandle.
        
        @param IQuery The query being operated on
        @param EventArgs Arguments pertaining to the operation. */
    define public event QueryClosed signature void (input poQuery as IQuery, input poArgs as EventArgs).

    /** Allows raising of the QueryClosed event by derived classes. 
        
        @param EventArgs Arguments for the event.  */
    method protected void OnQueryClosed(input poArgs as EventArgs):
        this-object:QueryClosed:Publish(this-object, poArgs).
    end method.

    /** Fired when the query is repositioned. This even only fires on query represented by the public QueryHandle.
            
        @param IQuery The query being operated on
        @param EventArgs Arguments pertaining to the operation. */
    define public event QueryRepositioned signature void (input poQuery as IQuery, input poArgs as EventArgs).
    
    /** Allows raising of the QueryRepositioned event by derived classes. 
        
        @param EventArgs Arguments for the event.  */
    method protected void OnQueryRepositioned(input poArgs as EventArgs):
        this-object:QueryRepositioned:Publish(this-object, poArgs).
    end method.

    /* The model or other component that holds this query. We need it in case of callbacks. */ 
    define public property TableOwner as ITableOwner no-undo  get. protected set.
    
    define public property QueryHandle as handle no-undo get. protected set.
    
    /** (derived) Is the query open? */
    define public property IsOpen as logical no-undo
        get():
            return (valid-handle(QueryHandle) and QueryHandle:is-open).
        end get.
    
    /* Query only has one this-object:Definition associated with it. Once it's created, we can
       manipulate to our hearts' content, but the object instance stays the same. */
    define public property Definition as IQueryDefinition no-undo get. protected set.

    /* This is the base or initial definition used to create this query. It's 
       a copy of the QueryDef passed in to the ctor, and should not be changed. */
/*    define protected property BaseDefinition as IQueryDefinition no-undo get. set.*/
    define protected property BaseDefinition as ObjectStack no-undo
        get():
            if not valid-object(BaseDefinition) then
                BaseDefinition = new ObjectStack().
            
            return BaseDefinition.
        end get.
        set.
    
    define public property NumRows as int no-undo
        get():
            define variable iNumRows as int no-undo.
            
            if valid-handle(QueryHandle) and QueryHandle:is-open then
                iNumRows = QueryHandle:num-results.
            else
                iNumRows = -1.
            
            return iNumRows.
        end get.
    
    define public property CurrentRow as integer no-undo 
        get():
            define variable iCurrentRow as int no-undo.
            
            if valid-handle(QueryHandle) and QueryHandle:is-open then
                iCurrentRow = QueryHandle:current-result-row.
            else
                iCurrentRow = -1.
            
            return iCurrentRow.
        end get.
        
    define public property RowPosition as RowPositionEnum no-undo
        get():
            define variable oRowPosition as RowPositionEnum no-undo.
                
            if not valid-handle(QueryHandle) or 
               not QueryHandle:is-open or
               QueryHandle:current-result-row eq 0 then
                oRowPosition = RowPositionEnum:None.
            else
                if QueryHandle:current-result-row eq 1 then
                    oRowPosition = RowPositionEnum:IsFirst. 
                else
                    if QueryHandle:current-result-row eq QueryHandle:num-results then
                        if oRowPosition eq RowPositionEnum:IsFirst then
                            oRowPosition = RowPositionEnum:IsFirstAndLast.
                        else
                            oRowPosition = RowPositionEnum:IsLast. 
                    else
                        oRowPosition = RowPositionEnum:NotFirstOrLast.
            
            return oRowPosition.
        end get.
    
    /** Contains the query elements changed since the last time the query was built. */
    define protected property QueryElementsChanged as integer no-undo get. set.
    
    define protected property BuildQuery as logical no-undo
        get.
        set(input plBuildQuery as logical):
            if plBuildQuery eq false then
                QueryElementsChanged = 0.
            
            BuildQuery = plBuildQuery.
        end set.

    constructor protected Query():
        create query QueryHandle.
        
        /* Obviously, we'll need to build the query at some point. */
        BuildQuery = true.
        QueryElementsChanged = QueryElementsChanged + QueryElementEnum:Buffer:Value.
    end constructor.
    
    constructor public Query(input poTableOwner as ITableOwner,
                             input poDefinition as IQueryDefinition):
        this-object().
        
        Assert:ArgumentNotNull(poDefinition, 'Query Definition').

        assign this-object:Definition = poDefinition
               TableOwner = poTableOwner.
        Rebase().
        
        /* If someone changes the query, we want to know about it so that when we
           (re)open a query, we know whether to rebuild the query string again (or 
           not). */
        this-object:Definition:QueryDefinitionChanged:Subscribe(QueryDefinitionChangedHandler).
    end constructor.
    
    method public void Open():
        this-object:Open(QueryHandle).
    end method.
    
    method protected void Open(input phQuery as handle):
        /* Build called since the defs may have changed.
           Build checks whether it needs to do anything. */
        Prepare(phQuery).
        
        if valid-handle(phQuery) then
        do:
            if phQuery:is-open then
                phQuery:query-close().
            phQuery:query-open().
            
            if phQuery eq QueryHandle then
                OnQueryOpened(EventArgs:Empty).
        end.
    end method.
    
    method public logical Close():
        return this-object:Close(QueryHandle).
    end method.
    
    method protected logical Close(input phQuery as handle):
        define variable lOk as logical no-undo.
        
        if valid-handle(phQuery) and phQuery:is-open then
            lOk = phQuery:query-close().
        else 
            lOK = false.
        
        if phQuery eq QueryHandle then
            OnQueryClosed(EventArgs:Empty).
        
        return lOK.
    end method.
    
    method public logical Reposition(input piRow as integer):
        return this-object:Reposition(QueryHandle, piRow).
    end method.
    
    method protected logical Reposition(input phQuery as handle, input piRow as integer):
        define variable lOk as logical no-undo.
        
        if piRow gt 0 then
        do:
            phQuery:reposition-to-row(piRow).
            
            /* deal with non-scrolling queries */
            if not phQuery:get-buffer-handle(phQuery:num-buffers):available then
                phQuery:get-next().
            lOK = phQuery:get-buffer-handle(1):available.           
        end.
        else
            lOK = false.
        
        if phQuery eq QueryHandle then
            OnQueryRepositioned(EventArgs:Empty).
        
        return lOK.
    end method.
    
    /** Repositions a query.  
        
        @param handle The query handle to reposition
        @param rowid[] An array of rowids used to reposition the query.
        @return logical Returns true if the query successfully repositioned to the
                row specified by the rowid array.   */
    method static public logical Reposition (input phQuery as handle,
                                                 input prRecord as rowid extent):
        define variable lOk as logical no-undo.
                                                     
        if prRecord[1] ne ? then
        do:
            /* Workaround for bug */
            if extent(prRecord) eq 1 then
                phQuery:reposition-to-rowid(prRecord[1]).
            else
                phQuery:reposition-to-rowid(prRecord).
            
            /* deal with non-scrolling queries */
            if not phQuery:get-buffer-handle(phQuery:num-buffers):available then
                phQuery:get-next().
                    
            lOK = phQuery:get-buffer-handle(1):available.
        end.
        else
            lOK = false.
           
/*        if phQuery eq QueryHandle then           */
/*            OnQueryRepositioned(EventArgs:Empty).*/
/*                                                 */
        return lOK.
    end method.
    
    method public logical Reposition (input pcRowKey as char extent):
        define variable lOk as logical no-undo.
        
        lOK = Query:Reposition(QueryHandle, pcRowKey).
        OnQueryRepositioned(EventArgs:Empty).
        
        return lOk. 
    end method.
    
    /** Repositions a query.  
        
        @param handle The query handle to reposition
        @param character[] An array of character row keys (either where clauses or rowids)
        @return logical Returns true if the query successfully repositioned to the
                row specified by the rowid array.   */            
    method static public logical Reposition(input phQuery as handle,
                                            input pcRowKey as char extent):
        define variable rCurrentRow as rowid extent no-undo.
        define variable iExtent as integer no-undo.
        define variable hBuffer as handle no-undo.
                extent(rCurrentRow) = extent(pcRowKey).
        rCurrentRow = ?.
        
        do iExtent = 1 to extent(pcRowKey):
            if pcRowKey[iExtent] eq '' or 
               pcRowKey[iExtent] eq ? then
                next.
            
            if pcRowKey[iExtent] begins 'where' then
            do:
                hBuffer = phQuery:get-buffer-handle(iExtent).
                hBuffer:find-unique(pcRowKey[iExtent]) no-error.
                if hBuffer:available then
                    rCurrentRow[iExtent] = hBuffer:rowid.
            end.
            else
                rCurrentRow[iExtent] = to-rowid(pcRowKey[iExtent]).
        end.    /* loop through where */
        
        return Query:Reposition(phQuery, rCurrentRow).
    end method.
            
    method public logical Reopen():
        return this-object:Reopen(QueryHandle).
    end method.
    
    method protected logical Reopen(input phQuery as handle):
        return this-object:Reopen(Query:GetCurrentRowKey(phQuery)).
    end method.
    
    method public logical Reopen(input pcRowKey as char extent):
        return this-object:Reopen(QueryHandle, pcRowKey).
    end method.
    
    method protected logical Reopen(input phQuery as handle, input pcRowKey as char extent):
        this-object:Open(phQuery).
        return Query:Reposition(phQuery, pcRowKey).
    end method.
    
    method public logical Reopen(input piRow as integer):
        return this-object:Reopen(QueryHandle, piRow).
    end method.
    
    method protected logical Reopen(input phQuery as handle, input piRow as integer):
        this-object:Open(phQuery).
        return this-object:Reposition(phQuery, piRow).
    end method.
    
    method public character extent GetCurrentRowKey():
        return Query:GetCurrentRowKey(QueryHandle).
    end method.

    method static public character GetBufferRowKey(input phBuffer as handle):
        define variable cKeyWhere as character no-undo.
        define variable iLoop as integer no-undo.
        define variable cKeys as character no-undo.
        define variable iMax as integer no-undo.
        /** single space for building query strings. Note the init value must be at least one space */
        define variable cSpacer as character no-undo init ' '.
        
        if not phBuffer:available then
            return ?.

        cKeys = phBuffer:keys. 
        if cKeys eq 'Rowid' then
            return string(phBuffer:rowid).
        
        iMax = num-entries(cKeys).
        do iLoop = 1 to iMax:
            cKeyWhere = cKeyWhere + cSpacer
                      + (if iLoop eq 1 then 'where ' else ' and ') + cSpacer
                      + phBuffer:name + '.' + entry(iLoop, cKeys) + cSpacer
                      + OperatorEnum:IsEqual:ToString() + cSpacer 
                      + quoter(phBuffer:buffer-field(entry(iLoop, cKeys)):buffer-value).
        end.    /* key fields */
        
        return cKeyWhere.
    end method.
                
    method static public character extent GetCurrentRowKey(input phQuery as handle):
        define variable cKeyWhere as character extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iFields as integer no-undo.
        define variable cKeys as character no-undo.
        define variable hBuffer as handle no-undo.
        
        if valid-handle(phQuery) and phQuery:is-open then
        do:
            extent(cKeyWhere) = phQuery:num-buffers.
            
            do iLoop = 1 to phQuery:num-buffers:
                cKeyWhere[iLoop] = Query:GetBufferRowKey(phQuery:get-buffer-handle(iLoop)).
            end.
        end.
        else
            assign extent(cKeyWhere) = 1
                   cKeyWhere = ?.
        
        return cKeyWhere.
    end method.
    
    method static public QueryFilter extent GetCurrentRowKeyElements(input phQuery as handle):
        define variable oFilters as ICollection no-undo.
        define variable iLoop as integer no-undo.
        define variable iFields as integer no-undo.
        define variable cKeys as character no-undo.
        define variable hBuffer as handle no-undo.
        
        if valid-handle(phQuery) and phQuery:is-open then
        do:
            oFilters = new Collection().
            
            do iLoop = 1 to phQuery:num-buffers:
                hBuffer = phQuery:get-buffer-handle(iLoop).
                if not hBuffer:available then
                do:
                    oFilters:Add(?).
                    leave.
                end.
                
                cKeys = hBuffer:keys.
                if cKeys eq 'Rowid' then
                    oFilters:Add(new QueryFilter(
                                            hBuffer:name,
                                            cKeys,
                                            OperatorEnum:IsEqual,
                                            new String(string(hBuffer:rowid)),
                                            DataTypeEnum:Rowid,
                                            JoinEnum:And)).
                else
                do iFields = 1 to num-entries(cKeys):
                    oFilters:Add(new QueryFilter(
                                            hBuffer:name,
                                            entry(iFields, cKeys),
                                            OperatorEnum:IsEqual,
                                            new String(hBuffer:buffer-field(entry(iFields, cKeys)):buffer-value),
                                            DataTypeEnum:Rowid,
                                            JoinEnum:And)).
                end.    /* key fields */
            end.
        end.
        
        return cast(oFilters:ToArray(), QueryFilter).
    end method.    
    
    method public character extent GetFirstRowKey().
        define variable hQuery as handle no-undo.
        
        hQuery = CloneQuery(QueryHandle).
        
        GetFirst(hQuery).
        
        return Query:GetCurrentRowKey(hQuery).
        
        finally:
            this-object:Close(hQuery).
            delete object hQuery no-error.
        end finally.
    end method.
    
    method public character extent GetNextRowKey().
        define variable hQuery as handle no-undo.
        
        hQuery = CloneQuery(QueryHandle).
        
        GetNext(hQuery).
                
        return Query:GetCurrentRowKey(hQuery).
        
        finally:
            this-object:Close(hQuery).
            delete object hQuery no-error.
        end finally.
    end method.
    
    method public character extent GetLastRowKey().
        define variable hQuery as handle no-undo.
        
        hQuery = CloneQuery(QueryHandle).
        
        GetLast(hQuery).
                
        return Query:GetCurrentRowKey(hQuery).
        
        finally:
            this-object:Close(hQuery).
            delete object hQuery no-error.
        end finally.
    end method.
    
    method public character extent GetPrevRowKey().
        define variable hQuery as handle no-undo.
        
        hQuery = CloneQuery(QueryHandle).
        
        GetPrev(hQuery).
                
        return Query:GetCurrentRowKey(hQuery).
        
        finally:
            this-object:Close(hQuery).
            delete object hQuery no-error.
        end finally.
    end method.
    
    method public character extent GetRowKey(input piPosition as int):
        define variable hQuery as handle no-undo.
        
        hQuery = CloneQuery(QueryHandle).
        
        this-object:Reposition(hQuery, piPosition).
                
        return Query:GetCurrentRowKey(hQuery).
        
        finally:
            this-object:Close(hQuery).
            delete object hQuery no-error.
        end finally.
    end method.
    
    method public character extent GetRowKeyWhere(input poDefinition as IQueryDefinition,
                                                  input poFindType as FindTypeEnum):
        define variable hQuery as handle no-undo.
        define variable cFirstRowKey as character extent no-undo.
        define variable cRowKey as character extent no-undo.
        define variable cAltRowKey as character extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        hQuery = CloneQuery(QueryHandle).
        hQuery:query-prepare(string(poDefinition:GetQueryString())).
        hQuery:query-open().
        
        case poFindType:
            when FindTypeEnum:Next or when FindTypeEnum:Prev then
                /*
                return error new UnsupportedOperationError(
                    FindTypeEnum:Next:ToString() + ' or ' + FindTypeEnum:Prev:ToString(),
                    'Query:GetRowKeyWhere()').
                */ .                    
            when FindTypeEnum:First then
            do:
                hQuery:get-first().
                cRowKey = GetCurrentRowKey(hQuery).
            end.
            when FindTypeEnum:Last then
            do:
                hQuery:get-last().
                cRowKey = GetCurrentRowKey(hQuery).
            end.
            when FindTypeEnum:Unique then
            do:
                hQuery:get-first().
                cRowKey = GetCurrentRowKey(hQuery).
                iMax = extent(cRowKey). 

                hQuery:get-last().
                cAltRowKey = GetCurrentRowKey(hQuery).
                
                @todo(task="implement", action="errors").
                if extent(cAltRowKey) eq iMax then
                do iLoop = 1 to iMax:
                    if cRowKey[iLoop] ne cAltRowKey[iLoop] then
                        return error.
                end.
                else
                    return error.
            end.
        end case.
        
        return cRowKey.
        
        finally:
            this-object:Close(hQuery).
            delete object hQuery no-error.
        end finally.
    end method.
    
    /* We may clone this query in order to get row keys from a result without
       causing the 'real' query to reposition. This may be used when performing
       multi-select operations in the UI, where we don't want to move off the
       current record. Note that these actions may be expensive, because of the
       cost of creating, opening, etc the query. */
    method protected handle CloneQuery(input phSource as handle):
        define variable hQueryClone as handle no-undo.        
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        create query hQueryClone.
        iMax = phSource:num-buffers.
        
        do iLoop  = 1 to iMax:
            hQueryClone:add-buffer(phSource:get-buffer-handle(iLoop)).
        end.
        hQueryClone:query-prepare(phSource:prepare-string).
        
        return hQueryClone.
    end method. 
        
    destructor public Query():
        this-object:Definition:QueryDefinitionChanged:Unsubscribe(QueryDefinitionChangedHandler).
        
        DeleteQuery().
    end destructor.
    
    method public void QueryDefinitionChangedHandler(input poSender as IQueryDefinition, input poArgs as QueryDefinitionEventArgs):
        /* Ignore prebult PDS queries wrt buffer changes. We only want
           to react to filter, sort, join changes.
           
           Don't touch the buffers if we aren't able to create them via a TableOwner.
           
           This is a shortcut, since BuildQuery checks for this
           sort of thing. */
        if poArgs:Element:Equals(QueryElementEnum:Buffer) and
           not valid-object(TableOwner) then
            BuildQuery = false.
        else
        do:
            BuildQuery = true.
            QueryElementsChanged = QueryElementsChanged + poArgs:Element:Value.
        end.
    end.
    
    method protected void DeleteQuery():
        define variable iLoop as integer no-undo.
                
        /* don't delete PDS auto queries */
        if valid-object(TableOwner) and
           valid-handle(QueryHandle) then
        do:
            do iLoop = 1 to QueryHandle:num-buffers:
                delete object QueryHandle:get-buffer-handle(iLoop).
            end.
            
            delete object QueryHandle.
        end.        
    end method.
    
    /** Resets the query definition to it's original state */
    method public void Reset():
        this-object:Close().
        
        Definition = cast(BaseDefinition:Pop(), IQueryDefinition). 
/*        Prepare().*/
    end method.
    
    /** Sets the base query definition to the current query definition. */
    method public void Rebase():
        BaseDefinition:Push(cast(Definition:Clone(), IQueryDefinition)).
    end method.
    
    method public void Prepare():
        Prepare(QueryHandle).
    end method.
    
    method protected void Prepare(input phQuery as handle):
        /* keep separate variable for debugging */
        define variable cPrepareString as character no-undo.
        
        /* Always prepare this query. */
        BuildQuery = true.
        BuildQuery(phQuery).
        
        cPrepareString = this-object:Definition:GetQueryString().
        
        phQuery:query-prepare(cPrepareString).                                      
    end method.
    
    method protected void RemoveQueryBuffers(input phQuery as handle):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = phQuery:num-buffers. 
        
        /* Clean up after ourselves. Note that this only removes the
           named buffer used for the query, and not the underlying buffer
           itself. */
        do iLoop = 1 to iMax:
            delete object phQuery:get-buffer-handle(iLoop).
        end.
    end method.
    
    /** Construct and prepare a query based on the current query definition.
            
        @param handle The query handle being built. This may be an invalid handle, hence the
                      return value of a handle. */
    method protected void BuildQuery(input phQuery as handle):
        define variable cBuffers as character extent no-undo.
        define variable cTables as character extent no-undo.
        define variable oQueryTypes as QueryTypeEnum extent no-undo.
        define variable oLockModes as LockModeEnum extent no-undo.
        define variable hBuffer as handle no-undo.
        define variable iExtent as integer no-undo.
        define variable hTable as handle no-undo.
        
        /* nothing to do here. */
        if not BuildQuery then
            return.
        
        /* (re)build the query's buffers.
           don't delete the query since the consumer of this query may use the 
           handle as a name (and probably does, in fact) so we don't want to mess 
           with that.
           
           Don't touch the buffers if we aren't able to create them via a TableOwner.
           
           If any of the buffers in the definition have changed, remove all the buffers 
           and re-create. */
        if valid-object(TableOwner) and 
           FlagsEnum:IsA(QueryElementsChanged, QueryElementEnum:Buffer) then
        do:
            RemoveQueryBuffers(phQuery).
            
            /* And now add the new buffer(s) */
            cBuffers = this-object:Definition:GetBufferList(output cTables,
                                                            output oQueryTypes,
                                                            output oLockModes).
            do iExtent = 1 to extent(cBuffers):
                hBuffer = GetQueryBuffer(cTables[iExtent], cBuffers[iExtent]).
                
                Assert:ArgumentNotNull(hBuffer, 'Buffer Handle for ' + cBuffers[iExtent]).
                
                if iExtent eq 1 then
                    phQuery:set-buffers(hBuffer).
                else
                    phQuery:add-buffer(hBuffer).
            end.
        end.
        
        /* for this query, we're at rest and ready to go */
        BuildQuery = false.
    end method.
    
    /** Returns a buffer handle for use in the query.
        
        Note: this is method makes Query a candidate for abstraction, since we
              use(d) the ITableOwner construct for determining the buffer. However,
              since there are now different deriviatives of the Query class which
              supply the buffer handle in different ways (eg. DataSourceQuery and/or
              ModelQuery), it can be argues that this functionality doesn't really belong 
              in this base Query class.
              
              However, the ITableOwner code will remain in place for now, barring
              refactoring.
        
        @param character The table name        
        @param character The buffer name for the buffer
        @return handle The buffer handle for use in the query.  */
    method protected handle GetQueryBuffer(input pcTableName as character,
                                           input pcBufferName as character):
        define variable hBuffer as handle no-undo.
        
        create buffer hBuffer
                    for table TableOwner:GetTableHandle(pcTableName)  
                    buffer-name pcBufferName.
                    
        return hBuffer.                    
    end method. 
    
    method public logical GetFirst():
        return GetFirst(QueryHandle).
    end method.
    
    method protected logical GetFirst(input phQuery as handle):
        this-object:Reposition(phQuery, 1).
                                        
        return phQuery:get-buffer-handle(1):available.
    end method.
                
    method public logical GetNext():
        return GetNext(QueryHandle).
    end method.
    
    method protected logical GetNext(input phQuery as handle):
        this-object:Reposition(phQuery, phQuery:current-result-row + 1).
        
        return phQuery:get-buffer-handle(1):available.
    end method.
    
    method public logical GetLast():
        return GetLast(QueryHandle).
    end method.
    
    method protected logical GetLast(input phQuery as handle):
        this-object:Reposition(phQuery:num-results).
        
        return phQuery:get-buffer-handle(1):available.            
    end method.
        
    method public logical GetPrev():
        return GetPrev(QueryHandle).
    end method.
    
    method protected logical GetPrev(input phQuery as handle):
        this-object:Reposition(max(phQuery:current-result-row - 1, 1)).
        
        return phQuery:get-buffer-handle(1):available.
    end method.
    
    method public character extent GetRowKeyWhere(input poDefinition as IQueryDefinition):
        return GetRowKeyWhere(poDefinition, FindTypeEnum:First).
    end method.
    
    method public character GetCurrentBufferKey(input pcBufferName as char):
        define variable cRowKey as char extent no-undo.
        define variable cKey as char no-undo.
        define variable cBuffers as char extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        assign cRowKey = GetCurrentRowKey()
               iMax = QueryHandle:num-buffers
               cKey = ?.
        
        /* Unable to determine row key (query might not be open) */
        if extent(cRowKey) eq 1 and cRowKey[1] eq ? then
            cKey = ?.
        else
        do iLoop = 1 to iMax while cKey eq ?:
            if QueryHandle:get-buffer-handle(iLoop):name eq pcBufferName then
                cKey = cRowKey[iLoop].
        end.
        
        return cKey.        
    end method.
    
    method public character GetBufferTableName(pcBufferName as char):
        define variable cTable as character no-undo. 
        cTable = QueryHandle:get-buffer-handle(pcBufferName):table.

        @todo(task="improve message in unsupported Error  or create new Error").
        catch e as Error:
              if valid-handle(QueryHandle) then 
                  undo, throw new InvalidValueSpecifiedError(e,"buffer name","~"" + pcBufferName + "~"").    
                else
                  undo, throw new UnsupportedOperationError(e,"buffer name","~"" + pcBufferName + "~"").   
        end catch.
        finally:
           return cTable.
        end.
    end method.
    
end class.
