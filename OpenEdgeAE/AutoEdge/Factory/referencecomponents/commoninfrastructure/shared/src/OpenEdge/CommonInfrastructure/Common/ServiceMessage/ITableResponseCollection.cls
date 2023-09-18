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
    File        : ITableResponseCollection
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Aug 30 20:50:42 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponseCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.String.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponseCollection inherits TypedMap: 
    
    constructor public ITableResponseCollection():
        super(String:Type,
              Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse')).
    end constructor.
    
    constructor public ITableResponseCollection(c as ITableResponseCollection):
        super(c).
    end constructor.

    method public ITableResponse Get(input pcKey as character):
        return this-object:Get(new String(pcKey)).
    end method.
    
    method public ITableResponse Get(input poKey as String):
        return cast(super:Get(poKey), ITableResponse).
    end method.
    
    method public String Put(input poKey as String, input poValue as ITableResponse):        
        return cast(super:Put(poKey, poValue), String).
    end method.

    method public String Put(input pcKey as character, input poValue as ITableResponse):     
        return this-object:Put(new String(pcKey), poValue). 
    end method.
    
    method public String Remove(input poKey as String):
        return cast(super:Remove(input poKey), String).
    end method.
    
    method public String Remove(input pcKey as character):
        return this-object:Remove(new String(pcKey)).
    end method.

end class.
