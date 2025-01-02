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
    File        : QueryDefinition
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 27 16:02:48 EDT 2009
    Notes       : * Is IExternalizable because its derived TableRequest is
                    potentially passed across the wire. 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.QueryBuffer.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.System.QuerySort.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.QueryDefinitionEventArgs.
using OpenEdge.Core.System.QueryDefinitionOperationEnum.
using OpenEdge.Core.System.QueryElementEnum.

using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.
using OpenEdge.Core.Util.IObjectInput.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.

using OpenEdge.Lang.QueryBlockTypeEnum.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Lang.CompareStrengthEnum.
using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.LockModeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.SortDirectionEnum.
using OpenEdge.Lang.EnumMember.
using OpenEdge.Lang.String.
using Progress.Lang.Object.

class OpenEdge.Core.System.QueryDefinition
        implements IQueryDefinition, IExternalizable :
    
    define public event QueryDefinitionChanged signature void (poQueryDefinition as IQueryDefinition,
                                                               poEventArgs as QueryDefinitionEventArgs).
    
    define public property QueryBlockType as QueryBlockTypeEnum no-undo
        get ():
            if not valid-object(QueryBlockType) then
                QueryBlockType = QueryBlockTypeEnum:Default.
                            
            return QueryBlockType.
        end get.
        set.

    /** Indicates whether the query can join to tables outside of this query definition. This may
        happen in some cases; for instance when dealing with DataSourceQuery objects which are used
        for DATA-SOURCE queries for ProDataSets.
        
        An external join is assumed to apply only to the 2nd (JoinBuffer) buffer in the QueryJoin. */        
    define public property AllowExternalJoins as logical no-undo initial false get. set.
    
    /* Only ever set by AddBuffer(). */
    define public property NumBuffers as integer no-undo get. protected set.
    
    define private temp-table ttBuffer no-undo
        field BufferName as character 
        field Order as integer
        field TableName as character 
        field QueryType as Object   /* OpenEdge.Lang.QueryTypeEnum */
        field LockMode as Object    /* OpenEdge.Lang.LockModeEnum */
        /* field JoinMode as Object    OpenEdge.Lang.BufferJoinModeEnum */
        index idx1 as unique BufferName
        index idx2 as primary unique Order.
    
    define private temp-table ttFilter no-undo
        field BufferName as character
        field FieldName as character 
        field Operator as Object        /* OpenEdge.Lang.OperatorEnum */
        field FieldValue as Object      /*OE.Lang.String */
        field FieldType as Object       /* OpenEdge.Lang.DataTypeEnum */
        field JoinType as Object        /* OpenEdge.Lang.JoinEnum */
        index idx1 as primary unique BufferName FieldName Operator FieldValue.
    
    define private temp-table ttJoin no-undo
        field BufferName as character
        field FieldName as character 
        field Operator as Object   /* OpenEdge.Lang.OperatorEnum */
        field JoinBufferName as character 
        field JoinFieldName as character 
        field JoinType as Object       /* OpenEdge.Lang.JoinEnum */
        index idx1 as primary unique BufferName FieldName Operator JoinBufferName JoinFieldName
        index idx2 JoinBufferName
        index idx3 BufferName.
    
    define private temp-table ttSort no-undo
        field BufferName as char
        field FieldName as char
        field Direction as Object /* OpenEdge.Lang.SortDirectionEnum */
        field Order as int
        index idx1 as primary unique BufferName FieldName.

    /** single space for building query strings. Note the init value must be at least one space */
    define private variable mcSpacer as character no-undo init ' '.
    
    method public void AddFilter (pcBufferName as character,
                                  pcFieldName as character,
                                  poOperator as OperatorEnum,
                                  poFieldValue as String,
                                  poFieldType as DataTypeEnum,
                                  poJoinType as JoinEnum):
        define buffer lbFilter for ttFilter.
        
        create lbFilter.
        assign lbFilter.BufferName = pcBufferName
               lbFilter.FieldName = pcFieldName
               lbFilter.Operator = poOperator
               lbFilter.FieldValue = poFieldValue
               lbFilter.FieldType = poFieldType
               lbFilter.JoinType = poJoinType.
        
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Filter, QueryDefinitionOperationEnum:Create)).
    end method.
    
    method public void AddFilter(input poQueryFilter as QueryFilter):
        AddFilter(poQueryFilter:BufferName,
                  poQueryFilter:FieldName,
                  poQueryFilter:Operator,
                  poQueryFilter:FieldValue,
                  poQueryFilter:FieldType,
                  poQueryFilter:JoinType).
    end method.
    
    /** Removes a filter clause from then definition.
        
        @param QueryFilter The query filter used to filter the query. */
    method public void RemoveFilter (input poQueryFilter as QueryFilter):
        define buffer lbFilter for ttFilter.
        
        for each lbFilter where
                 lbFilter.BufferName = poQueryFilter:BufferName and
                 lbFilter.FieldName = poQueryFilter:FieldName and
                 lbFilter.Operator = poQueryFilter:Operator
                 no-lock:                     
            
            /* We may be using a different QuerySort object to the original, so use
               Equals() instead of reference */
            if cast(lbFilter.FieldValue, String):Equals(poQueryFilter:FieldValue) then
            do:
                delete lbFilter.
                
                OnQueryDefinitionChanged(
                    new QueryDefinitionEventArgs(
                            QueryElementEnum:Filter,
                            QueryDefinitionOperationEnum:Delete)).
                leave.
            end.
        end.
    end method.
            
    method public void ClearFilters():
        empty temp-table ttFilter.
        
        OnQueryDefinitionChanged(
            new QueryDefinitionEventArgs(
                    QueryElementEnum:Filter,
                    QueryDefinitionOperationEnum:Empty)).
    end method.
        
    method public void ClearSort():
        empty temp-table ttSort.
        
        OnQueryDefinitionChanged(
            new QueryDefinitionEventArgs(
                    QueryElementEnum:Filter,
                    QueryDefinitionOperationEnum:Empty)).
    end method.

    method public void ClearJoins():
        empty temp-table ttJoin.
        
        OnQueryDefinitionChanged(
            new QueryDefinitionEventArgs(
                    QueryElementEnum:Join,
                    QueryDefinitionOperationEnum:Empty)).
    end method.
    
    method public void ClearBuffers():
        empty temp-table ttBuffer.
        NumBuffers = 0.
        
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Buffer, QueryDefinitionOperationEnum:Empty)).
    end method.
    
    method public void ClearAll():
        this-object:QueryBlockType = ?.
        
        this-object:ClearBuffers().
        this-object:ClearFilters().
        this-object:ClearJoins().
        this-object:ClearSort().
    end method.
    
    method public character extent GetBufferList():
        define variable cTables as character extent no-undo.
        define variable oDummy as EnumMember extent no-undo.
        
        return GetBufferList(output cTables, output oDummy, output oDummy).
    end method.
    
    method public character extent GetBufferList(output pcTables as character extent,
                                                 output poQueryTypes as QueryTypeEnum extent,
                                                 output poLockModes as LockModeEnum extent):
        
        define variable cBuffer as character extent no-undo.
        define variable iExtentSize as integer no-undo.
        define variable iExtent as integer no-undo.
        
        define buffer lbBuffer for ttBuffer.
        define query qryBuffer for lbBuffer.
        
        open query qryBuffer preselect each lbBuffer.
        
        iExtentSize = max(1, query qryBuffer:num-results).
        
        extent(cBuffer) = iExtentSize.
        extent(pcTables) = iExtentSize.
        extent(poQueryTypes) = iExtentSize.
        extent(poLockModes) = iExtentSize.
         
        query qryBuffer:get-first().
        iExtent = 1.
        do while not query qryBuffer:query-off-end:
            assign cBuffer[iExtent] = lbBuffer.BufferName
                   pcTables[iExtent] = lbBuffer.TableName
                   poQueryTypes[iExtent] = cast(lbBuffer.QueryType, QueryTypeEnum)
                   poLockModes[iExtent] = cast(lbBuffer.LockMode, LockModeEnum)
                   iExtent = iExtent + 1.
            
            query qryBuffer:get-next().
        end.
        
        close query qryBuffer.
        
        return cBuffer.        
    end method.
    
    method public QueryBuffer extent GetQueryBuffers():
        define variable oQB as QueryBuffer extent no-undo.
        
        define buffer lbBuffer for ttBuffer.
        define query qryBuffer for lbBuffer.
        
        open query qryBuffer preselect each lbBuffer by lbBuffer.Order.
        
        if query qryBuffer:num-results gt 0 then
        do:
            extent(oQB) = query qryBuffer:num-results.
            query qryBuffer:get-first().
            do while not query qryBuffer:query-off-end:
                oQB[query qryBuffer:current-result-row] =
                        new QueryBuffer(lbBuffer.BufferName,
                                        lbBuffer.TableName,
                                        cast(lbBuffer.QueryType, QueryTypeEnum),
                                        cast(lbBuffer.LockMode, LockModeEnum)).
                query qryBuffer:get-next().
            end.
            close query qryBuffer.
        end.
                
        return oQB.
    end method.
    
    method public void AddBuffer(pcBuffer as character):
        AddBuffer(pcBuffer, pcBuffer).
    end method.
            
    method public void AddBuffer(pcBuffer as character, pcTable as char):        
        AddBuffer(pcBuffer,
                  pcTable,
                  QueryTypeEnum:Default,
                  LockModeEnum:Default).
    end method.
    
    method public void AddBuffer(input poQueryBuffer as QueryBuffer):
        AddBuffer(poQueryBuffer:Name,
                  poQueryBuffer:TableName,
                  poQueryBuffer:QueryType,
                  poQueryBuffer:LockMode).
    end method.
    
    /** Removes a buffer and related records. Note that only one
        QueryDefinitionChanged event first, for the buffer. The 
        child records are simply removed.
        
        @param QueryBuffer The buffer being removed */
    method public void RemoveBuffer(input poQueryBuffer as QueryBuffer):
        RemoveBuffer(poQueryBuffer:Name).
    end method.
    
    /** Removes a buffer and related records. Note that only one
        QueryDefinitionChanged event first, for the buffer. The 
        child records are simply removed.
        
        @param character The buffer being removed */        
    method public void RemoveBuffer(input pcBufferName as character):
        define buffer lbBuffer for ttBuffer.
        define buffer lbJoin for ttJoin.
        define buffer lbFilter for ttFilter.
        define buffer lbSort for ttSort.
        
        find lbBuffer where lbBuffer.BufferName = pcBufferName no-error.
        if available lbBuffer then
        do:
            for each lbFilter where lbFilter.BufferName = lbBuffer.BufferName:
                delete lbFilter.
            end.
            
            for each lbJoin where
                     lbJoin.BufferName = lbBuffer.BufferName or
                     lbJoin.JoinBufferName = lbBuffer.BufferName:
                delete lbJoin.                         
            end.
            
            for each lbSort where lbSort.BufferName = lbBuffer.BufferName:
                delete lbSort.
            end.
            ReorderSort().
            
            delete lbBuffer.
            ReorderBuffers().
            
            /* Only one event fires */
            OnQueryDefinitionChanged(
                new QueryDefinitionEventArgs(
                        QueryElementEnum:Buffer,
                        QueryDefinitionOperationEnum:Delete)).
        end.
    end method.    
    
    method protected void ReorderBuffers():
        define buffer lbBuffer for ttBuffer.
        define query qryBuffer for lbBuffer.
        define variable iOrder as integer no-undo.
        
        open query qryBuffer
            preselect each lbBuffer by lbBuffer.Order.
        get first qryBuffer.

        do while not query-off-end('qryBuffer'):
            assign iOrder = iOrder + 1 
                   lbBuffer.Order = iOrder.
        end.
        close query qryBuffer.
    end method.
    
    method public void AddBuffer(pcBuffer as character,
                                 pcTable as character,
                                 poQueryType as QueryTypeEnum,
                                 poLockMode as LockModeEnum):
        define buffer lbBuffer for ttBuffer.
        
        if not can-find(lbBuffer where lbBuffer.BufferName = pcBuffer) then
        do:
            create lbBuffer.
            assign lbBuffer.BufferName = pcBuffer
                   lbBuffer.TableName = (if pcTable eq '' then pcBuffer else pcTable)
                   NumBuffers = NumBuffers + 1 
                   lbBuffer.Order = NumBuffers
                   lbBuffer.LockMode = poLockMode
                   lbBuffer.QueryType = poQueryType.
                   
            OnQueryDefinitionChanged(
                new QueryDefinitionEventArgs(
                        QueryElementEnum:Buffer,
                        QueryDefinitionOperationEnum:Create)).
        end.
    end method.
    
    method public void SetBuffers(pcBuffer as character extent, pcTable as character extent):
        define variable iLoop as integer no-undo.
                       
        do iLoop = 1 to extent(pcBuffer):
            /* Let AddBuffer figure order out */
            AddBuffer(pcBuffer[iLoop], pcTable[iLoop]).
        end.
    end method.
            
    method public void SetBuffers(pcBuffer as character extent):
        SetBuffers(pcBuffer, pcBuffer).
    end method.
        
    method public void SetBufferTable(pcBuffer as character, pcTable as char):
        define buffer lbBuffer for ttBuffer.
        
        find lbBuffer where lbBuffer.BufferName = pcBuffer no-error.
        if not available lbBuffer then
            AddBuffer(pcBuffer, pcTable).
        else
            lbBuffer.TableName = pcTable.
        
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Buffer, QueryDefinitionOperationEnum:Update)).
    end method.
    
    method public void SetBufferLockMode(pcBuffer as character, poLockMode as LockModeEnum):
        define buffer lbBuffer for ttBuffer.
        
        find lbBuffer where lbBuffer.BufferName = pcBuffer no-error.
        if not available lbBuffer then
            AddBuffer(pcBuffer).
        else
            lbBuffer.LockMode = poLockMode.
            
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Buffer, QueryDefinitionOperationEnum:Update)).
    end method.
    
    method public void SetBufferQueryType(pcBuffer as character, poQueryType as QueryTypeEnum):
        define buffer lbBuffer for ttBuffer.
        
        find lbBuffer where lbBuffer.BufferName = pcBuffer no-error.
        if not available lbBuffer then
            AddBuffer(pcBuffer).
        else
            lbBuffer.QueryType = poQueryType.
        
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Buffer, QueryDefinitionOperationEnum:Update)).
    end method.
            
    method public QueryTypeEnum GetBufferQueryType(pcBuffer as char):
        define variable oType as QueryTypeEnum no-undo.
        define buffer lbBuffer for ttBuffer.
        
        find lbBuffer where lbBuffer.BufferName = pcBuffer no-error.        
        if available lbBuffer then 
            oType = cast(lbBuffer.QueryType, QueryTypeEnum).
        
        return oType.
    end method.
    
    method public LockModeEnum GetBufferLockMode(pcBuffer as char):
        define variable oMode as LockModeEnum no-undo.
        define buffer lbBuffer for ttBuffer.
        
        find lbBuffer where lbBuffer.BufferName = pcBuffer no-error.        
        if available lbBuffer then 
            oMode = cast(lbBuffer.LockMode, LockModeEnum).
        
        return oMode.
    end method.
    
    method public character GetBufferTable(pcBuffer as char):
        define variable cTable as char no-undo.
        define buffer lbBuffer for ttBuffer.
        
        find lbBuffer where lbBuffer.BufferName = pcBuffer no-error.        
        if available lbBuffer then 
            cTable = lbBuffer.TableName.
        
        return cTable.        
    end method.
    
    constructor public QueryDefinition():
        super ().
    end constructor.
    
    /** Create a join between 2 buffers in this definition.
    
        @param QueryJoin Parameters for the join. */    
    method public void AddJoin(input poQueryJoin as QueryJoin):
        AddJoin(poQueryJoin:BufferName,
                poQueryJoin:FieldName,
                poQueryJoin:Operator,
                poQueryJoin:JoinBufferName,
                poQueryJoin:JoinFieldName,
                poQueryJoin:JoinType).
    end method.
    
    /** Removes a join between 2 buffers in this definition.
    
        @param QueryJoin Parameters for the join. */    
    method public void RemoveJoin(input poQueryJoin as QueryJoin):
        define buffer lbJoin for ttJoin.
        
        find lbJoin where
             lbJoin.BufferName = poQueryJoin:BufferName and
             lbJoin.FieldName  = poQueryJoin:FieldName and
             lbJoin.Operator = poQueryJoin:Operator and 
             lbJoin.JoinBufferName = poQueryJoin:JoinBufferName and 
             lbJoin.JoinFieldName = poQueryJoin:JoinFieldName
             no-error.
        if available lbJoin then
        do:
            delete lbJoin.             

            OnQueryDefinitionChanged(
                new QueryDefinitionEventArgs(
                        QueryElementEnum:Join,
                        QueryDefinitionOperationEnum:Delete)).                    
        end.
    end method.
    
    /** Create a join between 2 buffers in this definition.
        
        @param character The first buffer name in the join
        @param character The first buffer field in the join
        @param OperatorEnum The operator (=,>, etc)
        @param character The second buffer name in the join
        @param character The second buffer field in the join
        @param JoinEnum The join type (and/or etc) for the filter. */        
    method public void AddJoin (pcBufferName as character,
                                pcFieldName as character,
                                poOperator as OperatorEnum,
                                pcJoinBufferName as character,
                                pcJoinFieldName as character,
                                poJoinType as JoinEnum):
        define buffer lbJoin for ttJoin.
        
        create lbJoin.
        assign lbJoin.BufferName = pcBufferName
               lbJoin.FieldName = pcFieldName
               lbJoin.Operator = poOperator
               lbJoin.JoinBufferName = pcJoinBufferName
               lbJoin.JoinFieldName = pcJoinFieldName
               lbJoin.JoinType = poJoinType.
        
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Join, QueryDefinitionOperationEnum:Create)).
    end method.
    
    method public logical Equals(poQuery as QueryDefinition):
        define variable lEquals as logical no-undo.
        define variable cThis as longchar no-undo.
        define variable cThat as longchar no-undo.
        
        if not valid-object(poQuery) then
            lEquals = false.            
        else
        /* if this is exactly the same object reference, then it's
           exactly the same object (ahem). */
        if int(poQuery) eq int(this-object) then
            lEquals = true.
        else
            lEquals = super:Equals(poQuery).
        
        /* the super call might do way more simple checks, but if we're not equal at that point, 
           we certainly won't pass this test. */
        if lEquals then
            lEquals = compare(this-object:GetMD5(),
                              OperatorEnum:IsEqual:ToString(),
                              poQuery:GetMD5(),
                              CompareStrengthEnum:Raw:ToString()).
        
        return lEquals.
    end method.
    
    method public char GetMD5():
        define variable oOOS as IObjectOutput no-undo.
        define variable mStream as memptr no-undo.
        
        oOOS = new ObjectOutputStream().
        oOOS:WriteObject(this-object).
        oOOS:Write(output mStream).
        
        return string(md5-digest(mStream)).
        
        finally:
            set-size(mStream) = 0.
        end finally.
    end method.
    
    method protected void OnQueryDefinitionChanged (poEventArgs as QueryDefinitionEventArgs):
        this-object:QueryDefinitionChanged:Publish(
                this-object,
                new QueryDefinitionEventArgs(QueryElementEnum:Join, QueryDefinitionOperationEnum:Create)).
    end method.
    
    method public void WriteObject(input po as IObjectOutput):
        po:WriteEnum(QueryBlockType).
        po:WriteLogical(AllowExternalJoins).
        
        po:WriteTable(buffer ttBuffer:handle).
        po:WriteTable(buffer ttFilter:handle).
        po:WriteTable(buffer ttJoin:handle).
        po:WriteTable(buffer ttSort:handle).
    end method.
    
    method public void ReadObject(input po as IObjectInput):
        QueryBlockType = cast(po:ReadEnum(), QueryBlockTypeEnum).
        AllowExternalJoins = po:ReadLogical().
        
        po:ReadTable(table ttBuffer by-reference).
        po:ReadTable(table ttFilter by-reference).
        po:ReadTable(table ttJoin by-reference).
        po:ReadTable(table ttSort by-reference).
    end method.
    
    method public override Object Clone():
        define variable oClone as IQueryDefinition no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oBuffer as QueryBuffer extent no-undo.
        define variable oFilter as QueryFilter extent no-undo.
        define variable oJoin as QueryJoin extent no-undo.
        define variable oSort as QuerySort extent no-undo.
        
        oClone = cast(this-object:GetClass():New(), IQueryDefinition).
        oClone:QueryBlockType = this-object:QueryBlockType.
        oClone:AllowExternalJoins = this-object:AllowExternalJoins.
        
        oBuffer = this-object:GetQueryBuffers().
        iMax = extent(oBuffer).
        do iLoop = 1 to iMax:
            oClone:AddBuffer(oBuffer[iLoop]).
        end.
        
        oFilter = this-object:GetQueryFilters().
        iMax = extent(oFilter).
        do iLoop = 1 to iMax:
            oClone:AddFilter(oFilter[iLoop]).
        end.
        
        oJoin = this-object:GetQueryJoins().
        iMax = extent(oJoin).
        do iLoop = 1 to iMax:
            oClone:AddJoin(oJoin[iLoop]).
        end.
        
        oSort = this-object:GetQuerySort().
        iMax = extent(oSort).
        do iLoop = 1 to iMax:
            oClone:AddSort(oSort[iLoop]).
        end.
        
        return oClone.
    end method.
    
    /** Returns all of the query elements for the query.
        
        @return Object[] An array of the elements that make up this query. */
    method public Object extent GetQueryElements().
        define variable oElements as ICollection no-undo.
        
        oElements = new Collection().
        oElements:Add(QueryBlockType).
        oElements:AddArray(GetQueryBuffers()).
        oElements:AddArray(GetQueryFilters()).
        oElements:AddArray(GetQueryJoins()).
        oElements:AddArray(GetQuerySort()).
        
        return oElements:ToArray().    
    end method.
    
    method public longchar GetQueryString():
        return GetQueryString(GetBufferList()). 
    end.
        
    /** Returns the complete query string (ready for QUERY-PREPARE).
        
        @param character[] An array of buffer names for which 
               return a where clause that filters and joins between all
               buffers.
        @return longchar The query clause string. */
    method public longchar GetQueryString(pcBuffers as character extent):
        define variable cTables as character extent no-undo.
        define variable iExtent as integer no-undo.
        define variable cJoin as character no-undo.
        define variable cFilter as character no-undo.
        define variable cWhere as character no-undo.
        define variable cSortBy as character no-undo.
        define variable cBufferName as character no-undo.
        define variable cQueryBufferList as character no-undo.
        
        define buffer lbBuffer for ttBuffer.  
        
        cWhere = this-object:QueryBlockType:ToString().
        do iExtent = 1 to extent(pcBuffers):
            cBufferName = pcBuffers[iExtent].
            find lbBuffer where lbBuffer.BufferName = cBufferName no-error.
            
            assign cQueryBufferList = cQueryBufferList + ',' + lbBuffer.BufferName 
                   cJoin = GetJoin(cQueryBufferList, cBufferName)
                   cFilter = GetFilter(cBufferName)
                   
                   cSortBy = cSortBy + mcSpacer + GetSort(cBufferName)
                   
                   /* Note: where string broken up for readability. */
                   cWhere = cWhere + mcSpacer 
                          + cast(lbBuffer.QueryType, EnumMember):ToString() + mcSpacer 
                          + lbBuffer.BufferName.
           
            
            if cJoin ne '' then
            do:
                cWhere = cWhere             + mcSpacer 
                        + 'where'           + mcSpacer 
                        + '(' + cJoin + ') '.
                if cFilter ne '' then
                    cWhere = cWhere                     + mcSpacer 
                           + JoinEnum:And:ToString()    + mcSpacer 
                           + '(' + cFilter + ') '.
            end.
            else
            if cFilter ne '' then
                cWhere = cWhere + mcSpacer + 'where' + mcSpacer + cFilter.
            
            /* lock status and terminate */
            cWhere = cWhere + mcSpacer 
                   + cast(lbBuffer.LockMode,EnumMember):ToString() + mcSpacer
                   + (if iExtent ne extent(pcBuffers) then ', ' else '').
        end.
        
        return cWhere + mcSpacer + cSortBy.
    end method.

/** SORT CRITERIA **/
    /** Add a sort condition to the definition.
    
        @param character The buffer being sorted
        @param character The field being sorted
        @param SortDirection The direction of the sort. */
    method public void AddSort (pcBufferName as character,
                                pcFieldName as character,
                                poSortDirection as SortDirectionEnum):
        define variable iOrder as integer no-undo.

        define buffer lbSort for ttSort.
        define query qrySort for lbSort.
        
        open query qrySort 
            preselect each lbSort by lbSort.Order.
        
        iOrder = query qrySort:num-results + 1.
        
        AddSort(pcBufferName, pcFieldName, poSortDirection, iOrder).                                
    end method.
    
    /** Add a sort condition to the definition.
        
        @param character The buffer being sorted
        @param character The field being sorted
        @param SortDirection The direction of the sort.
        @param integer The ordinal position of the sort phrase for the buffer. */    
    method public void AddSort (pcBufferName as character,
                                pcFieldName as character,
                                poSortDirection as SortDirectionEnum,
                                piOrder as integer ):
        define buffer lbSort for ttSort.
        
        find lbSort where
             lbSort.BufferName = pcBufferName and
             lbSort.FieldName = pcFieldName
             no-error.
        if not available lbSort then
        do:
            create lbSort.
            assign lbSort.BufferName = pcBufferName
                   lbSort.FieldName = pcFieldName.
        end.
        
        assign lbSort.Direction = poSortDirection
               lbSort.Order     = piOrder.
        
        OnQueryDefinitionChanged(new QueryDefinitionEventArgs(QueryElementEnum:Sort, QueryDefinitionOperationEnum:Create)).
    end method.
    
    /** Add a sort condition to the definition.
        
        @param QuerySort Parameters for the sort. */     
    method public void AddSort(input poQuerySort as QuerySort):
        define variable iOrder as integer no-undo.

        define buffer lbSort for ttSort.
        define query qrySort for lbSort.
        
        open query qrySort 
            preselect each lbSort by lbSort.Order.
        
        iOrder = query qrySort:num-results + 1.
        
        AddSort(poQuerySort:BufferName,
                poQuerySort:FieldName,
                poQuerySort:Direction,
                iOrder).
    end method.
    

    /** Removes a sort condition from the definition.
        
        @param QuerySort Parameters for the sort. */ 
    method public void RemoveSort(input poQuerySort as QuerySort).
        define buffer lbSort for ttSort.
        
        find lbSort where
             lbSort.BufferName = poQuerySort:BufferName and
             lbSort.FieldName = poQuerySort:FieldName
             no-error.
        if available lbSort then
        do:
            delete lbSort.
        
            ReorderSort().
            
            OnQueryDefinitionChanged(
                new QueryDefinitionEventArgs(
                        QueryElementEnum:Sort,
                        QueryDefinitionOperationEnum:Delete)).                    
        end.
    end method.
    
    method protected void ReorderSort():
        define buffer lbSort for ttSort.
        define query qrySort for lbSort.
        define variable iOrder as integer no-undo.
        
        open query qrySort 
            preselect each lbSort by lbSort.Order.
        get first qrySort.
        
        do while not query-off-end('qrySort'):
            assign iOrder = iOrder + 1 
                   lbSort.Order = iOrder.
        end.
        close query qrySort.
    end method.
    
    /** Returns sort information for all buffers in the definition.
        
        @return longchar A complete sort string for all buffers in the definition. */
    method public longchar GetSort():
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cBuffers as character extent no-undo.
        define variable cSortBy as longchar no-undo.
        
        cBuffers = GetBufferList().
        iMax = extent(cBuffers).
        
        do iLoop = 1 to iMax:
            cSortBy = cSortBy + mcSpacer + GetSort(cBuffers[iLoop]).
        end.
        
        return cSortBy.
    end method.
    
    /** Returns sort information.
        
        @param character The buffer name for which to retrieve sort information
        @return longchar A complete sort string for the specified buffer. */
    method public longchar GetSort(input pcBufferName as character):
        define variable cSortBy as longchar no-undo.
        define variable oSortDirection as EnumMember no-undo.
        
        define buffer lbSort for ttSort.
        
        for each lbSort where
                 lbSort.BufferName = pcBufferName
                 by lbSort.Order:
            assign oSortDirection = cast(lbSort.Direction, EnumMember)
                   cSortBy = cSortBy + ' by '
                         + lbSort.BufferName + '.' + lbSort.FieldName + mcSpacer 
                         + (if oSortDirection:Equals(SortDirectionEnum:Ascending) then '' 
                            else oSortDirection:ToString() ).
        end.
        
        return cSortBy.
    end method.
    
    /** Returns the Sort information for the given buffer.
           
        @param character The buffer name for which to retrieve sort information
        @return QuerySort[] An ordered array of sort parameters */    
    method public QuerySort extent GetQuerySort(input pcBufferName as character):
        define buffer lbSort for ttSort.
        define query qrySort for lbSort.
        
        open query qrySort 
            preselect each lbSort where
                           lbSort.BufferName = pcBufferName
                           by lbSort.Order.
        return FillQuerySort(query qrySort:handle).
    end method.

    /** Returns the Sort information for all buffers. 
        
        @return QuerySort[] An ordered array of sort parameters */    
    method public QuerySort extent GetQuerySort():
        define buffer lbBuffer for ttBuffer.
        define buffer lbSort for ttSort.
        
        define query qrySort for lbBuffer, lbSort.
        
        open query qrySort
            preselect each lbBuffer,
                      each lbSort where
                           lbSort.BufferName = lbBuffer.BufferName
                      by lbBuffer.Order
                      by lbSort.Order.
        
        return FillQuerySort(query qrySort:handle).            
    end method.
    
    /** Creates QuerySort objects based on a query.
        
        @param handle The open query used to filter sort records.
        @return QuerySort[] An ordered array of sort parameter objects. */
    method protected QuerySort extent FillQuerySort(input phQuery as handle):
        define variable oQS as QuerySort extent no-undo.
        define variable hBuffer as handle no-undo.
        
        if valid-handle(phQuery) and 
           phQuery:is-open and 
           phQuery:num-results gt 0 then
        do:
            extent(oQS) = phQuery:num-results.
            hBuffer = phQuery:get-buffer-handle('lbSort') no-error.
            if not valid-handle(hBuffer) then
                hBuffer = phQuery:get-buffer-handle('ttSort').
            
            phQuery:get-first().
            do while not phQuery:query-off-end:
                oQS[phQuery:current-result-row] =
                        new QuerySort(hBuffer::BufferName,
                                      hBuffer::FieldName,
                                      cast(hBuffer::Direction, SortDirectionEnum)).
                phQuery:get-next().
            end.
            phQuery:query-close().
        end.
        
        return oQS.        
    end method.
    
    /** Returns the filter criteria for a buffer, in string form. This
        could be used as-is for a WHERE clause.
        
        @param character The buffer name 
        @return longchar The where-clause-compatible string. */    
    method public longchar GetFilter(input pcBufferName as character):
        define variable cWhereClause as longchar no-undo.
        define variable cValue as character no-undo.
        
        define buffer lbFilter for ttFilter.
        
        for each lbFilter where lbFilter.BufferName = pcBufferName:
            if cWhereClause <> '' then
                cWhereClause = cWhereClause                                     + mcSpacer
                              + cast(lbFilter.JoinType, EnumMember):ToString()  + mcSpacer.
            
            cValue = string(cast(lbFilter.FieldValue, String):Value).
            if cast(lbFilter.FieldType, DataTypeEnum):Equals(DataTypeEnum:Rowid) then
                cWhereClause = cWhereClause                                     + mcSpacer
                             + 'rowid(' + quoter(lbFilter.BufferName) + ')'     + mcSpacer 
                             + cast(lbFilter.Operator, EnumMember):ToString()   + mcSpacer
                             + 'to-rowid(' + quoter(cValue) + ')'.
            else
                cWhereClause = cWhereClause                                     + mcSpacer
                             + lbFilter.BufferName + '.' + lbFilter.FieldName   + mcSpacer 
                             + cast(lbFilter.Operator, EnumMember):ToString()   + mcSpacer
                             + quoter(cValue).
        end.
        
        return cWhereClause. 
    end method.
    
    /** Returns the filters applicable to a buffer.
       
        @param character The buffer name
        @return QueryFilter[] An array of query filter objects that
                apply to this buffer. */    
    method public QueryFilter extent GetQueryFilter(input pcBufferName as character):
        define buffer lbFilter for ttFilter.
        define query qryFilter for lbFilter.
        
        open query qryFilter 
            preselect each lbFilter where
                           lbFilter.BufferName = pcBufferName.
        
        return FillQueryFilter(query qryFilter:handle).
    end method.
    
    /** Returns the filters applicable to all the buffers in the query.
       
        @return QueryFilter[] An array of query filter objects that apply 
                to all the buffers. The filters are ordered by buffer order. */
    method public QueryFilter extent GetQueryFilters():
        define buffer lbBuffer for ttBuffer.
        define buffer lbFilter for ttFilter.
        
        define query qryFilter for lbBuffer, lbFilter.
        
        open query qryFilter
            preselect each lbBuffer, 
                      each lbFilter where
                           lbFilter.BufferName = lbBuffer.BufferName
                           by lbBuffer.Order.
        
        return FillQueryFilter(query qryFilter:handle).
    end method.    

    /** Returns the joins applicable to a buffer.
        
        @param character The buffer name
        @return QueryJoin[] An array of query filter objects that
                apply to this buffer. */
    method public QueryJoin extent GetQueryJoin(input pcBufferName as character):
        define buffer lbBuffer for ttBuffer.
        define buffer lbJoin for ttJoin.
        
        define query qryJoin for lbBuffer, lbJoin.
        
        open query qryJoin
            preselect each lbBuffer where
                           lbBuffer.BufferName = pcBufferName, 
                      each lbJoin where
                           lbJoin.BufferName = lbBuffer.BufferName.
        
        return FillQueryJoin(query qryJoin:handle, pcBufferName).        
    end method.
    
    /** Returns the joins applicable to all the buffers in the query.
       
        @return QueryJoin[] An array of query join objects that apply 
                to all the buffers. The joins are ordered by buffer order. */
    method public QueryJoin extent GetQueryJoins():
        define buffer lbBuffer for ttBuffer.
        define buffer lbJoin for ttJoin.
        
        define query qryJoin for lbBuffer, lbJoin.
        
        open query qryJoin
            preselect each lbBuffer, 
                      each lbJoin where
                           lbJoin.BufferName = lbBuffer.BufferName
                           by lbBuffer.Order.
        
        return FillQueryJoin(query qryJoin:handle, '*').
    end method.
    
    /** Creates QueryJoin objects based on a query.
        
        @param handle The open query used to filter sort records.
        @param character The name of the buffers that will be used in the 
               query. This allows us to join from and to a buffer.
        @return QueryJoin[] An ordered array of sort parameter objects. */
    method protected QueryJoin extent FillQueryJoin(input phQuery as handle,
                                                    input pcBuffersInQuery as character):
        define variable oQJ as QueryJoin extent no-undo.
        define variable hBuffer as handle no-undo.
        
        if valid-handle(phQuery) and 
           phQuery:is-open and 
           phQuery:num-results gt 0 then
        do:
            extent(oQJ) = phQuery:num-results.
            hBuffer = phQuery:get-buffer-handle('lbJoin') no-error.
            if not valid-handle(hBuffer) then
                hBuffer = phQuery:get-buffer-handle('ttJoin').
            
            phQuery:get-first().
            do while not phQuery:query-off-end:
                if can-do(pcBuffersInQuery, hBuffer::BufferName) and 
                   can-do(pcBuffersInQuery, hBuffer::JoinBufferName) then
                do:
                    oQJ[phQuery:current-result-row] =
                        new QueryJoin(hBuffer::BufferName,
                                      hBuffer::FieldName,
                                      cast(hBuffer::Operator, OperatorEnum),
                                      hBuffer::JoinBufferName,
                                      hBuffer::JoinFieldName,
                                      cast(hBuffer::JoinType, JoinEnum)).
                end.
                phQuery:get-next().
            end.
            phQuery:query-close().
        end.
        
        return oQJ.        
    end method.    
    /** Creates QuerySort objects based on a query.
        
        @param handle The open query used to filter sort records.
        @return QuerySort[] An ordered array of sort parameter objects. */
    method protected QueryFilter extent FillQueryFilter(input phQuery as handle):
        define variable oQF as QueryFilter extent no-undo.
        define variable hBuffer as handle no-undo.
        
        if valid-handle(phQuery) and 
           phQuery:is-open and 
           phQuery:num-results gt 0 then
        do:
            extent(oQF) = phQuery:num-results.
            hBuffer = phQuery:get-buffer-handle('lbFilter') no-error.
            if not valid-handle(hBuffer) then
                hBuffer = phQuery:get-buffer-handle('ttFilter').
            
            phQuery:get-first().
            do while not phQuery:query-off-end:
                oQF[phQuery:current-result-row] =
                        new QueryFilter(hBuffer::BufferName,
                                        hBuffer::FieldName,
                                        cast(hBuffer::Operator, OperatorEnum),
                                        cast(hBuffer::FieldValue, String),
                                        cast(hBuffer::FieldType, DataTypeEnum),
                                        cast(hBuffer::JoinType, JoinEnum)).
                phQuery:get-next().
            end.
            phQuery:query-close().
        end.
        
        return oQF.        
    end method.
        
    method protected longchar GetJoin(pcBuffersInQuery as character, pcBufferName as character):
        define variable cWhereClause as longchar no-undo.
        define variable iExtent as integer no-undo.
        define buffer lbJoin for ttJoin.
        
        for each lbJoin where 
                 lbJoin.BufferName = pcBufferName or
                 lbJoin.JoinBufferName = pcBufferName:
            if lookup(lbJoin.BufferName, pcBuffersInQuery) gt 0 and 
               (AllowExternalJoins or lookup(lbJoin.JoinBufferName, pcBuffersInQuery) gt 0) then
            do:
                if cWhereClause <> '' then
                    cWhereClause = cWhereClause + mcSpacer
                                  + cast(lbJoin.JoinType, EnumMember):ToString() + mcSpacer.
                cWhereClause = cWhereClause
                             + lbJoin.BufferName + '.' + lbJoin.FieldName + mcSpacer 
                             + cast(lbJoin.Operator, EnumMember):ToString() + mcSpacer
                             + lbJoin.JoinBufferName + '.' + lbJoin.JoinFieldName.
            end.
        end.
        
        return cWhereClause. 
    end method.
    
end class.
