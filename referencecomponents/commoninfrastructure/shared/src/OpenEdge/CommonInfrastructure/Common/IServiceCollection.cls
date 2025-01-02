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
    File        : IServiceCollection
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 20 14:40:52 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.IServiceCollection.
using OpenEdge.CommonInfrastructure.Common.ComponentInfo.
using OpenEdge.Lang.Collections.TypedMap.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Common.IServiceCollection inherits TypedMap:
    constructor public IServiceCollection(poMap as IServiceCollection):
        super(poMap).
    end constructor.
    
    constructor public IServiceCollection():
        super(ComponentInfo:IComponentInfoType,
              Class:GetClass('OpenEdge.CommonInfrastructure.Common.IService')).
    end constructor.
    
end class.
