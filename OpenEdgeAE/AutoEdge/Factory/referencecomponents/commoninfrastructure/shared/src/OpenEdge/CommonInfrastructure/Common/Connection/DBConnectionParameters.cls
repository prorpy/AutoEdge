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
    File        : DBConnectionParameters
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 20 09:19:47 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionParameters.
using OpenEdge.Lang.Assert.

class OpenEdge.CommonInfrastructure.Common.Connection.DBConnectionParameters inherits ConnectionParameters:    
    define public property LogicalName as character no-undo get. protected set.
    define public property PhysicalName as character no-undo get. protected set.
    
	constructor public DBConnectionParameters(input pcPhysicalName as character,
	                                          input pcLogicalName as character,
	                                          input pcOptions as longchar):
		super(pcOptions).
		
        Assert:ArgumentNotNullOrEmpty(pcPhysicalName, 'Database physical name').
		Assert:ArgumentNotNullOrEmpty(pcLogicalName, 'Database logical name').
		
        assign PhysicalName = pcPhysicalName
               LogicalName = pcLogicalName.
	end constructor.
	
	method override public longchar GetConnectionString():
	    return substitute(' -db &1 ', PhysicalName)
	         + substitute(' -ld &1 ', LogicalName)
	         + super:GetConnectionString().
	end method.
	
end class.
