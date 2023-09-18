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
    File        : UITypeCondition
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Apr 23 15:11:37 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.Core.InjectABL.Binding.Conditions.UITypeCondition.
using OpenEdge.Core.InjectABL.Binding.Conditions.ICondition.
using OpenEdge.Core.InjectABL.Binding.Conditions.Condition.
using OpenEdge.Core.System.UITypeEnum.

class OpenEdge.Core.InjectABL.Binding.Conditions.UITypeCondition: 

    define static public property Chui as ICondition no-undo get. private set. 
    define static public property ABLGui as ICondition no-undo get. private set.
    define static public property RiaGui as ICondition no-undo get. private set.
    define static public property DotNetGui as ICondition no-undo get. private set.
    define static public property Current as ICondition no-undo get. private set.
    
    constructor static UITypeCondition():
        assign UITypeCondition:Chui = new Condition(UITypeEnum:Chui)
               UITypeCondition:ABLGui = new Condition(UITypeEnum:AblGui)
               UITypeCondition:RiaGui = new Condition(UITypeEnum:RiaGui)
               UITypeCondition:DotNetGui = new Condition(UITypeEnum:DotNetGui)
/*               UITypeCondition:Current = new Condition(UITypeEnum:Current)*/
               .
    end constructor.
    
end class.
