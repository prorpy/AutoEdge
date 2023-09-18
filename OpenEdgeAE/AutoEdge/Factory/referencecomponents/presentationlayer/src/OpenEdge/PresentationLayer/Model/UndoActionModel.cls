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
    File        : UndoActionModel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Mar 31 11:47:10 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.DatasetModel.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.Model.UndoActionModel inherits DatasetModel :
    define temp-table eAction no-undo before-table eActionBefore
        field RecordKey as character extent 18
        field QueryName as character
        field BufferName as character 
        field ModelService as Object    /* IComponentInfo */
        field UndoActionType as Object /* OpenEdge.CommonInfrastructure.Common.UpdateActionEnum:EnumMember */
        field Order as integer
        index idx1 as primary unique ModelService QueryName BufferName Order
        .
    
    define dataset dsUndoAction for eAction.
                
	constructor public UndoActionModel(input pcServiceName as character, input poComponentInfo as IComponentInfo):
		super(input pcServiceName, input poComponentInfo).
	end constructor.

    method override protected void CreateMasterDataset():
        /* no service adapter - all data is local */
        MasterDataset = dataset dsUndoAction:handle.
    end method.
    
    method override public void CommitData():
        /* all data is local */
        MasterDataset:write-xml('file', 'UndoActionModel.xml', 
                                yes, /*formatted*/
                                ?,?,?,
                                yes).   /* write BI */
    end method.
    
    method override protected void SetBufferCallbacks(pcBufferName as char, phBuffer as handle):
    end method.

    /*
    method override protected handle GetBufferField( input pcBufferName as character, input pcFieldName as character ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
*/

    method override protected void AssignDefaultValues( input pcTableName as character, input phBuffer as handle ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method override protected logical FindTableByKey( input pcTableName as character, input pcRecordKey as character ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

end class.
