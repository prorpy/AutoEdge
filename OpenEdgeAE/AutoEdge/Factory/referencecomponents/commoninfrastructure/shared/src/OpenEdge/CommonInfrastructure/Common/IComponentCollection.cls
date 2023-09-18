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
    File        : IComponentCollection
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 07 15:01:31 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.TypedList.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.IComponentCollection inherits TypedList:
    constructor public IComponentCollection():
        super(Class:GetClass('OpenEdge.CommonInfrastructure.Common.IComponent')).
    end constructor.

    constructor public IComponentCollection(poType as class Class):
        super(Class:GetClass('OpenEdge.CommonInfrastructure.Common.IComponent')).
    end constructor.
    
    constructor public IComponentCollection(poTypedCollection as TypedList):
        super(poTypedCollection).
        
        /* Can't do this before the super call, sorry. */
        Assert:ArgumentIsType(poTypedCollection, this-object:GetClass()).
    end constructor.
    
end class.
