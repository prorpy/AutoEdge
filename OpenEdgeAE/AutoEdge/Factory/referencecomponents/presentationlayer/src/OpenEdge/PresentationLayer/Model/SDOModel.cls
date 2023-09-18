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
/*------------------------------------------------------------------------
    File        : SDOModel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue May 19 12:19:42 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.Model.
using OpenEdge.PresentationLayer.Model.IModelQuery.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.

using OpenEdge.CommonInfrastructure.Common.IServiceManager. 
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.ValueNotSpecifiedError.

class OpenEdge.PresentationLayer.Model.SDOModel abstract
        inherits Model :
    
    define abstract protected property SmartDataObject as character no-undo get. set.
    
    define private variable mhSdo as handle no-undo.
    
     method public logical CloseQuery( input pcQuery as character ):
        return dynamic-function('closeQuery' in mhSdo).
    end method.

     method override protected handle GetBufferHandle( input pcTable as character ):
        /* SDO only has ever one table. */
        return dynamic-function('GetRowObject' in mhSdo).
    end method.

	constructor public SDOModel ( input pcServiceName as character, input poComponentInfo as IComponentInfo ):
		super (input pcServiceName, input poComponentInfo).
	end constructor.
    
    method public logical GetFirst( input pcQuery as character ):
        define variable oQuery as IQuery no-undo.
        
        run fetchFirst in mhSDO.
        
        oQuery = cast(ModelQueries:Get(pcQuery), IQuery).
        oQuery:Reposition(oQuery:GetCurrentRowKey()).
        
        return (dynamic-function('rowAvailable' in mhSdo, ?)).
    end method.
    
    method  public logical GetLast( input pcQuery as character ):
        define variable oQuery as IQuery no-undo.
        
        run fetchLast in mhSDO.

        oQuery = cast(ModelQueries:Get(pcQuery), IQuery).
        oQuery:Reposition(oQuery:GetCurrentRowKey()).
        
        return (dynamic-function('rowAvailable' in mhSdo, ?)).
    end method.
    
    method  public logical GetNext( input pcQuery as character ):
        define variable oQuery as IQuery no-undo.
        
        run fetchNext in mhSDO.

        oQuery = cast(ModelQueries:Get(pcQuery), IQuery).
        oQuery:Reposition(oQuery:GetCurrentRowKey()).
        
        return (dynamic-function('rowAvailable' in mhSdo, ?)).
    end method.
    
    method  public logical GetPrev( input pcQuery as character ):
        define variable oQuery as IQuery no-undo.
        
        run fetchPrev in mhSDO.
        
        oQuery = cast(ModelQueries:Get(pcQuery), IQuery).
        oQuery:Reposition(oQuery:GetCurrentRowKey()).
        
        return (dynamic-function('rowAvailable' in mhSdo, ?)).
    end method.
    
    method override public IModelQuery CreateQuery(poQueryDefinition as IQueryDefinition,
                                            phQuery as handle,
                                            pcQuery as char):
        define variable oQueryDefinition as IQueryDefinition no-undo.
        
        phQuery = dynamic-function('GetDataHandle' in mhSdo).
        pcQuery = string(phQuery).
        
        oQueryDefinition = new QueryDefinition().
        oQueryDefinition:AddBuffer('RowObject').
        
        /* we still need to register this query as a ModelQuery */        
        return super:CreateQuery(oQueryDefinition, phQuery, pcQuery).
    end method.
                
    method override public void Initialize():
        define variable cSdoFile as character no-undo.
        define variable cServerFileName as character no-undo.
        
        /* We kinda need the SDO name ... */        
        if this-object:SmartDataObject eq '' then
            undo, throw new ValueNotSpecifiedError('SmartDataObject').
        
        super:Initialize().
        
        /* start SDO */
        cSDOFile = entry(1, this-object:SmartDataObject, '.') + '_cl.w'.
        run value(this-object:SmartDataObject) persistent set mhSDO no-error.
    
        dynamic-function('setOpenOnInit' in mhSdo, false).
        dynamic-function('setLogicalObjectName' in mhSDO, this-object:SmartDataObject). 
        
        run initializeObject in mhSDO.
                
    end method.
    
    method  public void OpenQuery( input pcQuery as character ):
       dynamic-function('openQuery' in mhSdo).    
    end method.
    
    method override public void DestroyComponent ():
        super:DestroyComponent().
                
        run destroyObject in mhSdo no-error.
        if valid-handle(mhSdo) then
            delete object mhSdo no-error.
        mhSdo = ?.
    end method.
            
    method override public void FetchData():
        dynamic-function('openQuery' in mhSdo).
    end method.
                    
    /* Operations */
    method override protected char DoAddRecord(pcBufferName as char):
        define variable cNewRecordKey as character no-undo.
        
        dynamic-function('addRow' in mhSdo, '').
        
/*        cast(ModelQueries:Get(pcQuery), IQuery):GetCurrentRowKey().*/
        return cNewRecordKey. 
    end method.
    
    method override public void CommitData():
        define variable cUndoRowids                 as character     no-undo.
        define variable cErrorList                  as character     no-undo.
        
        /*
            OUTPUT cMessages - a CHR(3) delimited string of accumulated messages from
                       server.
            OUTPUT cUndoIds  - list of any RowObject ROWIDs whose changes need to be 
                       undone as the result of errors in the form of:
               "RowNumCHR(3)ADM-ERROR-STRING,RowNumCHR(3)ADM-ERROR-STRING,..."
        */
        run bufferCommit in mhSDO (output cErrorList, output cUndoRowids) no-error.
    end method.
                    
    method override protected void DoDeleteRecord(pcBufferName as char, pcRecordKey as char):
        dynamic-function('deleteRow' in mhSdo, dynamic-function('getRowIdent' in mhSdo) ).
    end method.
    
end class.
