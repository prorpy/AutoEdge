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
    File        : IConnectionParameters
    Purpose     : A general interface for AppServer/DB/etc connection parameters 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jan 13 10:41:05 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
interface OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters:
    /** This property contains a nicely-formatted string for use by the
        ABL CONNECT statement or method. */ 
    define public property Options as longchar no-undo get. set.
    
    /** The Connection Manager will call GetConnectionString() on this 
        object, which returns a nicely-formatted string for use by the
        ABL CONNECT statement. 
                
        @return character A useable string of connection parameters. */
    method public longchar GetConnectionString().
    
end interface.
