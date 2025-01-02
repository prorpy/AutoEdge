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
    File        : IListIterator
    Purpose     : An iterator for lists that can traverse the list in 
                  both directions
    Syntax      : 
    Description : 
    @author hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.Object.

interface OpenEdge.Lang.Collections.IListIterator:  
  method public logical HasNext().
  method public Object Next().
  method public integer NextIndex().
  method public logical Remove ().
  method public logical HasPrevious().
  method public Object Previous().   
  method public integer PreviousIndex().
 /* method public void set(o as Object).     */
end interface.

 
