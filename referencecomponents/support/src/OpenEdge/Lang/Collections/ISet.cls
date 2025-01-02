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
    File        : ISet
    Purpose     : A collection that contains no duplicate elements.
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Wed Jan 09 09:57:42 EST 2008
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IIterator.

interface OpenEdge.Lang.Collections.ISet:  
   /* Returns the number of elements in this list. */
   define public property Size as integer no-undo get.
    
   /* Appends the specified element to list if not already present
      (optional operation). */
   method public logical Add(o as Object).
   
   /* Appends all of the elements in the specified collection if not already 
     present (optional operation). */
   method public logical AddAll(c as ICollection).
    
   /* Removes all of the elements from this list (optional operation). */
   method public void Clear().
   
   /* Returns true if this list contains the specified element. */
   method public logical Contains (o as Object). 
   
   /* Returns true if this list contains all of the elements of the 
      specified collection. */
   method public logical ContainsAll(c as ICollection). 
   
   /*  method override public logical equals (o as Object). */
   
   /* Returns true if this list contains no elements. */
   method public logical IsEmpty().
     
   /* Returns an iterator over the elements in this list in proper sequence. */        
   method public IIterator Iterator().
   
   /* Removes the first occurrence in this list of the specified element 
     (optional operation). */
   method public logical Remove (o as Object). 

   /* Removes from this list all the elements that are contained in the 
      specified collection (optional operation). */
   method public logical RemoveAll (c as ICollection). 
  
   /* Retains only the elements in this list that are contained in the 
      specified collection (optional operation).*/
   method public logical RetainAll (c as ICollection). 
      
   /* Returns a temp-table containing all of the elements in this list */
   method public void ToTable (output table-handle tt).   
   
   /* retruns the contents of the set as an array */
   method public Object extent ToArray (). 
end interface.
