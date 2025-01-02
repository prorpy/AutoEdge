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
    File        : ITableResponse
    Purpose     :  
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Aug 30 14:05:55 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.
using OpenEdge.Lang.Collections.IMap.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse:
    
    /** (mandatory) The name of the table */  
    define property TableName as char no-undo get.
    
    /** Whether the service request resulted in an error or not. */
    define public property HasError as logical no-undo get. set.
    
    /** The error texts associated with the request, if any.
        There's an entry in the map for each row that has an error,
        keyed on the RowKey. */
    define public property ErrorText as IMap no-undo get.
    
    /** The ITableContext (page size retrieved, etc) for this response, if any.
        Typically only Fetch actions will have one of these; Save not so much.  */
    define public property TableContext as ITableContext no-undo get. set.
    
end interface.
