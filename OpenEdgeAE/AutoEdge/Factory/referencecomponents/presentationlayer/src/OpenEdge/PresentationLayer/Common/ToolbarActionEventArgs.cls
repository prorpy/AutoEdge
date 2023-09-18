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
    File        : ToolbarActionEventArgs
    Purpose     : Event args passed on selection of a toolbar action/item
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu May 14 13:18:11 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Common.ToolbarActionTypeEnum.
using OpenEdge.Core.System.EventArgs.
using OpenEdge.Lang.DataTypeEnum.
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.Common.ToolbarActionEventArgs inherits EventArgs  :
    define public property ActionKey as character no-undo get. protected set.
    define public property ActionType as ToolbarActionTypeEnum no-undo get. protected set.
    define public property ActionTarget as character no-undo
        get.
        set (pcTarget as char):
            SetArgValue('ResolvedTarget', pcTarget, DataTypeEnum:Character).
            ActionTarget = pcTarget.
        end set.
    
    define private temp-table eActionArgs no-undo        
        field ArgName   as char
        field ArgValue  as char
        field ArgType   as Object /* OpenEdge.Core.System.DataTypeEnum */
        index idx1 as primary unique ArgName
        .
    
    constructor ToolbarActionEventArgs():
        super().
    end constructor.        
    
    constructor ToolbarActionEventArgs(pcKey as char, poType as ToolbarActionTypeEnum):
        this-object().
                        
        ActionKey = pcKey.
        ActionType = poType.
    end constructor.
                
    method public void SetArgValue (pcArgName as char,
                                    pcArgValue as char,
                                    poArgType as DataTypeEnum):
        define buffer lbArgs for eActionArgs.
        find lbArgs where lbArgs.ArgName = pcArgName no-error.
        if not available lbArgs then
        do:
            create lbArgs.
            lbArgs.ArgName = pcArgName.
        end.
                               
        assign lbArgs.ArgValue = pcArgValue
               lbArgs.ArgType = poArgType.
    end method.
    
    method public char GetArgumentValue (pcArgName as char, output poType as DataTypeEnum):
        define buffer lbArgs for eActionArgs.
                
        find lbArgs where lbArgs.ArgName = pcArgName no-error.
        if available lbArgs then
        do:
            poType = cast(lbArgs.ArgType, DataTypeEnum).
            return lbArgs.ArgValue.
        end.
        else
            return ?.
    end method.
    
    method public void GetArgValue (pcArgName as char, output pcValue as char):
        define variable oType as DataTypeEnum no-undo.
        pcValue = GetArgumentValue(pcArgName, output oType).
    end method.
    
    method public void GetArgValue (pcArgName as char, output piValue as int):
        define variable cValue as character no-undo.
        define variable oType as DataTypeEnum no-undo.
        
        cValue = GetArgumentValue(pcArgName, output oType).
        if oType eq DataTypeEnum:Integer then
            piValue = int(cValue).
        else
            piValue = ?.            
    end method.
        
    method public void GetArgValue (pcArgName as char, output plValue as log):
        define variable cValue as character no-undo.
        define variable oType as DataTypeEnum no-undo.
        
        cValue = GetArgumentValue(pcArgName, output oType).
        if oType eq DataTypeEnum:Logical then
            plValue = logical(cValue).
        else
            plValue = ?.
    end method.

    method public void GetArgValue (pcArgName as char, output pdValue as dec):
        define variable cValue as character no-undo.
        define variable oType as DataTypeEnum no-undo.
        
        cValue = GetArgumentValue(pcArgName, output oType).
        if oType eq DataTypeEnum:Decimal then
            pdValue = dec(cValue).
        else
            pdValue = ?.
    end method.
    
end class.
