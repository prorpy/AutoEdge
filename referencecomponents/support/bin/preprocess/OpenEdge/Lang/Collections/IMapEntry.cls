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
    File        : IMapEntry
    Purpose     : A map entry (key-value pair). 
                  The IMap:EntrySet returns a set-view of the map, 
                  whose elements are of this class. 
                   
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Sun Apr 11 23:46:14 EDT 2010
    Notes       : The only way to obtain a reference to a map entry is 
                  from the iterator of the IEntrySet.
                  The IMapEntry objects are valid only for the duration 
                  of the iteration.                      
  ----------------------------------------------------------------------*/

using Progress.Lang.Object.

interface OpenEdge.Lang.Collections.IMapEntry:  
    define property Key   as Object no-undo get. set.
    define property Value as Object no-undo get. set.
    
end interface.
