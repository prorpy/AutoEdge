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
    File        : RoutineTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Nov 18 15:25:50 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.RoutineTypeEnum. 
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.RoutineTypeEnum inherits EnumMember: 
    
    define static public property Constructor as RoutineTypeEnum no-undo get. private set.
    define static public property Destructor as RoutineTypeEnum no-undo get. private set.
    define static public property Method as RoutineTypeEnum no-undo get. private set.
    define static public property PropertySetter as RoutineTypeEnum no-undo get. private set.
    define static public property PropertyGetter as RoutineTypeEnum no-undo get. private set.
    define static public property UserDefinedFuntion as RoutineTypeEnum no-undo get. private set.
    define static public property Procedure as RoutineTypeEnum no-undo get. private set.

    constructor static RoutineTypeEnum():
        RoutineTypeEnum:Constructor = new RoutineTypeEnum('Constructor').
        RoutineTypeEnum:Destructor = new RoutineTypeEnum('Destructor').
        RoutineTypeEnum:Method = new RoutineTypeEnum('Method').
        RoutineTypeEnum:PropertySetter = new RoutineTypeEnum('PropertySetter').
        RoutineTypeEnum:PropertyGetter = new RoutineTypeEnum('PropertyGetter').
        
        RoutineTypeEnum:UserDefinedFuntion = new RoutineTypeEnum('Function').
        RoutineTypeEnum:Procedure = new RoutineTypeEnum('Procedure').
    end constructor.
    
    constructor public RoutineTypeEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
    method public static RoutineTypeEnum EnumFromString(input pcName as character):
        define variable oEnum as RoutineTypeEnum no-undo.
        
        case pcName:
            when RoutineTypeEnum:Constructor:ToString() then oEnum = RoutineTypeEnum:Constructor.
            when RoutineTypeEnum:Destructor:ToString() then oEnum = RoutineTypeEnum:Destructor.
            when RoutineTypeEnum:Method:ToString() then oEnum = RoutineTypeEnum:Method.
            when RoutineTypeEnum:PropertySetter:ToString() then oEnum = RoutineTypeEnum:PropertySetter.
            when RoutineTypeEnum:PropertyGetter:ToString() then oEnum = RoutineTypeEnum:PropertyGetter.
            when RoutineTypeEnum:UserDefinedFuntion:ToString() then oEnum = RoutineTypeEnum:UserDefinedFuntion.
            when RoutineTypeEnum:Procedure:ToString() then oEnum = RoutineTypeEnum:Procedure.
        end case.
        
        return oEnum.
    end method.
    
end class.
