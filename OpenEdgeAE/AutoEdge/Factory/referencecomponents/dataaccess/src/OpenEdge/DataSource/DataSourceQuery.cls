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
    File        : DataSourceQuery
    Purpose     : Specialised query for use with an ABL DATA-SOURCE 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Dec 29 14:39:34 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.System.QueryElementEnum.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.System.Query.
using OpenEdge.Core.System.ITableOwner.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.Collections.TypedCollection.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.LockModeEnum.
using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.

using Progress.Lang.Class.

class OpenEdge.DataSource.DataSourceQuery inherits Query
        implements ITableOwner:
    
    /** The handle to the ABL DATA-SOURCE object that this query operates against.
        
        A case can be made for an OE.DataSource.ABLDatasource that contains
        the DataSourceQuery and a HANDLE property (ie not held here). */
    define public property ABLDataSource as handle no-undo get. set.
    
    /** A collection of QueryFilter objects that act as tokens for the key fields
        in the datasource buffers.
        
        These filters are used when saving rows, where the values are used to identify the 
        DB rows uniquely. */
    define public property SourceKeyFilters as IMap no-undo
        get():
            if not valid-object(SourceKeyFilters) then
                SourceKeyFilters  = new Map().
            return SourceKeyFilters.
        end get.
        private set.

    /** A collection of QueryFilter objects that indicate the tenant filters in the datasource buffers.
        
        These filters are used when saving rows, where the values are used to identify the 
        DB rows uniquely.
        
        This property is protected because Adding and removing filters isn't only done in this collection. */
    define protected property TenantFilters as IMap no-undo
        get():
            if not valid-object(TenantFilters) then
                TenantFilters = new Map().
            return TenantFilters.
        end get.
        private set.
    
    constructor public DataSourceQuery():
        super().
        
        TableOwner = this-object.
    end constructor.
    
    constructor public DataSourceQuery(input phDataSource as handle):
        this-object().
        
        Assert:ArgumentNotNull(phDataSource, 'ABL Data-Source').
        
        assign ABLDataSource = phDataSource
               Definition = new QueryDefinition()
               /* don't try to build a query until we have a definition */
               BuildQuery = false.
    end constructor.
    
    method public void Initialize():
        /* We need a datasource for this object */
        Assert:ArgumentNotNull(ABLDataSource, 'ABL Data-Source').
        
        ParseDataSource().
        
        /* fix (as in finalise or baseline, not as in repair) the definition */
        Rebase().
        
        /* Always prepare this query. */
        QueryElementsChanged = QueryElementsChanged + QueryElementEnum:Buffer:Value.        
        BuildQuery = true.
        BuildQuery(QueryHandle).
    end method.
    
    method protected void ParseDataSource():
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        
        assign iMax = ABLDataSource:num-source-buffers
               hBuffer = ABLDataSource:get-source-buffer(1).
        
        /* top-level buffer */               
        Definition:AddBuffer(hBuffer:name,
                             hBuffer:table,
                             QueryTypeEnum:Each,
                             LockModeEnum:NoLock).
        AddKeyFilters(hBuffer, ABLDataSource:keys(iLoop)).
        
        /* DataSource queries are effectively FIND FIRST's after the top-level buffer */
        do iLoop = 2 to iMax:
            hBuffer = ABLDataSource:get-source-buffer(iLoop).
            Definition:AddBuffer(hBuffer:name,
                                 hBuffer:table,
                                 QueryTypeEnum:First,
                                 LockModeEnum:NoLock).
            AddKeyFilters(hBuffer, ABLDataSource:keys(iLoop)).
        end.
    end method.
    
    method public logical HasTenantFilter(input pcBufferName as character):
        return TenantFilters:ContainsKey(new String(pcBufferName)). 
    end method.
    
    method public void AddTenantFilter(input poFilter as QueryFilter):
        define variable oFilters as ICollection no-undo.
        
        Definition:AddFilter(poFilter).
        
        oFilters = cast(TenantFilters:Get(new String(poFilter:BufferName)), ICollection).
        if not valid-object(oFilters) then
        do:
            oFilters = new TypedCollection(Class:GetClass('OpenEdge.Core.System.QueryFilter')).        
            TenantFilters:Put(new String(poFilter:BufferName), oFilters).
        end.
        
        oFilters:Add(poFilter).
    end.
    
    method public void RemoveTenantFilter(input pcBufferName as character):
        define variable oFilters as ICollection no-undo.
        define variable oQueryFilter as QueryFilter no-undo.
        define variable oIterator as IIterator no-undo.
        
        oFilters = cast(TenantFilters:Remove(new String(pcBufferName)), ICollection).
        oIterator = oFilters:Iterator().
        
        do while oIterator:HasNext():
            oQueryFilter = cast(oIterator:Next(), QueryFilter).
            
            /*remove tenant filters */
            this-object:Definition:RemoveFilter(oQueryFilter).
        end.
    end.
    
    /** Creates and stores query filters for the datasource buffers' keys. */
    method protected void AddKeyFilters(input phBuffer as handle, 
                                        input pcKeys as character):
        define variable iNumKeys as integer no-undo.
        define variable iKeyLoop as integer no-undo.
        define variable cFieldName as character no-undo.
        define variable oDataType as DataTypeEnum no-undo.
        define variable hField as handle no-undo.
        define variable oFilters as ICollection no-undo.
        define variable hABLDataSource as handle no-undo.
        
        assign oFilters = new Collection()
               iNumKeys = num-entries(pcKeys).
               
        do iKeyLoop = 1 to iNumKeys:
            cFieldName = entry(iKeyLoop, pcKeys).
            if cFieldName eq 'rowid' then
                oDataType = DataTypeEnum:Rowid.
            else            
                assign hField = phBuffer:buffer-field(cFieldName)
                       oDataType = DataTypeEnum:EnumFromString(hField:data-type).
            
            oFilters:Add(new QueryFilter(phBuffer:name,
                              cFieldName,
                              OperatorEnum:IsEqual,
                              new String('&1'),         /* for substitutions */
                              oDataType,
                              JoinEnum:And)).
        end.    /* key loop */
        SourceKeyFilters:Put(new String(phBuffer:name), oFilters).
    end method.
    
    
    method override protected handle GetQueryBuffer(input pcTableName as character,
                                                    input pcBufferName as character):
        define variable hBuffer as handle no-undo.
        
        /* First check the buffer name, then the table name. We should always be able to
           find a handle by buffer name, byt just in case we can't, we check the table too.
           
           We start with the buffer because we can have multiple buffers on one table in
           a single query. */    
        hBuffer = GetBufferBuffer(pcBufferName).
        if not valid-handle(hBuffer) then
            hBuffer = GetTableBuffer(pcTableName).
        
        return hBuffer.
    end method.

    /* ITableOwner implementation */
    method public handle GetTableHandle(input pcTableName as character):
        return GetTableBuffer(pcTableName).
    end method.
    
    method public handle GetTableBuffer(input pcTableName as character):
        define variable hBuffer as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        /* We could use a temp-table for storing the table-name/buffer-name/handle values,
           but that would probably be overkill, given that the number of DB buffers per ABL
           data-source is (I assume) small, and so the loop is probably cheaper all round. */                
        iMax = ABLDataSource:num-source-buffers.
        hBuffer = ABLDataSource:get-source-buffer(1).
        do iLoop = 2 to iMax while hBuffer:table ne pcTableName:
            hBuffer = ABLDataSource:get-source-buffer(iLoop).
        end.
        
        if hBuffer:table ne pcTableName then
            hBuffer = ?.
        
        return hBuffer.
    end method.

    method protected handle GetBufferBuffer(input pcBufferName as character):
        define variable hBuffer as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        /* We could use a temp-table for storing the table-name/buffer-name/handle values,
           but that would probably be overkill, given that the number of DB buffers per ABL
           data-source is (I assume) small, and so the loop is probably cheaper all round. */                
        iMax = ABLDataSource:num-source-buffers.
        hBuffer = ABLDataSource:get-source-buffer(1).
        do iLoop = 2 to iMax while hBuffer:name ne pcBufferName:
            hBuffer = ABLDataSource:get-source-buffer(iLoop).
        end.
        
        if hBuffer:name ne pcBufferName then
            hBuffer = ?.
        
        return hBuffer.
    end method.

    method override public character GetBufferTableName(input pcBufferName as character):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        
        /* We could use a temp-table for storing the table-name/buffer-name/handle values,
           but that would probably be overkill, given that the number of DB buffers per ABL
           data-source is (I assume) small, and so the loop is probably cheaper all round. */                
        iMax = ABLDataSource:num-source-buffers.
        hBuffer = ABLDataSource:get-source-buffer(1).
        do iLoop = 2 to iMax while hBuffer:name ne pcBufferName:
            hBuffer = ABLDataSource:get-source-buffer(iLoop).
        end.
        
        if hBuffer:name ne pcBufferName then
            hBuffer = ?.
        
        return hBuffer:table.
    end method.
    
	method public void Prepare(input poAction as ServiceMessageActionEnum):
	    define variable cWhereString as longchar no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oJoin as QueryJoin no-undo.
        define variable cClause as character no-undo.
        define variable cLHS as character no-undo.
        define variable cRHS as character no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData then cWhereString = ABLDataSource:fill-where-string.
            when ServiceMessageActionEnum:SaveData then cWhereString = ABLDataSource:save-where-string.
            otherwise cWhereString = ?.
        end case.
        
        Definition:AllowExternalJoins = not (cWhereString eq ?).
        
        if Definition:AllowExternalJoins then
        do:
            /* WHERE ds_2849_2165_ItemOption.ItemId=eVehicle.ItemId */
            /* WHERE ItemOption_2839-2165.ItemId=eVehicle.ItemId and ItemOption_2839-2165.TenantId=eVehicle.TenantId */
            iMax = num-entries(cWhereString, ' ').
            
            /* loose the WHERE, as well as the 'AND' phrases (we'll add these) */
            do iLoop = 1 to iMax:
                cClause = entry(iLoop, cWhereString, ' ').
                if cClause eq '' or lookup(cClause, 'WHERE,AND') gt 0 then
                    next.
                
                /* ItemOption_2839-2165.ItemId=eVehicle.ItemId  */
                assign /* ItemOption_2839-2165.ItemId */  
                       cLHS = entry(1, cClause, '=')
                       /* eVehicle.ItemId */
                       cRHS = entry(2, cClause, '=').
                
                /* We'll have the buffer name; we want the table name even though we'll go back to
                   the table name later; we do this even entry(1, cLHS, '.') it's wasteful since we want a consistent approach */
                Definition:AddJoin(/*GetBufferTableName(entry(1, cLHS, '.')), entry(2, cLHS, '.'),*/
                                   entry(1, cLHS, '.'), entry(2, cLHS, '.'),
                                   OperatorEnum:IsEqual,
                                   /* These will (typically) be from the entity, and so we use them unchanged */
                                   entry(1, cRHS, '.'), entry(2, cRHS, '.'),
                                   JoinEnum:And).
            end.
        end.
        
        this-object:Prepare().
	end method.
	end class.
