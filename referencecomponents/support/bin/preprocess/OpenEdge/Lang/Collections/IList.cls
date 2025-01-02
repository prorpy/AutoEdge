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
    File        : IList
    Purpose     : An ordered collection that gives control over where in the 
                  list each element is inserted. 
                  Allows elements to be accessed by their integer index in 
                  addition to by the element. 
    Description : 
    @author hdaniels
    Created     : Wed Jan 09 09:57:42 EST 2008
    Notes       : All methods (and comments) except ToTable are an exact match to Java  
                  List interface. Size is implemented as property                                 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IIterator. 
using OpenEdge.Lang.Collections.IListIterator. 
using OpenEdge.Lang.Collections.IList. 

interface OpenEdge.Lang.Collections.IList:  
   /* Returns the number of elements in this list. */
   define public property Size as integer no-undo get.
    
   /* Inserts the specified element at the specified position in this list 
       (optional operation).*/      
   method public logical Add(i as int, o as Object).
   
   /* Appends the specified element to the end of this list 
       (optional operation). */
   method public logical Add(o as Object).
   
   /* Appends all of the elements in the specified collection to the end 
      of this list, in the order that they are returned by the specified 
      collection's iterator (optional operation). */
   method public logical AddAll(c as ICollection).
   
   /* Inserts all of the elements in the specified collection into this list 
      at the specified position (optional operation).  */
   method public logical AddAll(i as int,c as ICollection).
   
   /** Appends all the elements in the array this list, optionally
       at the specified position. */
   method public logical AddArray(c as Object extent).
   method public logical AddArray(i as int, c as Object extent).
   
   /* Removes all of the elements from this list (optional operation). */
   method public void Clear().
   
   /* Returns true if this list contains the specified element. */
   method public logical Contains (o as Object). 
   
   /* Returns true if this list contains all of the elements of the 
      specified collection. */
   method public logical ContainsAll(c as ICollection). 
   
   /* Returns the element at the specified position in this list. */       
   method public Object Get(i as int). 
 
   /* Returns the index in this list of the first occurrence of the specified 
      element, or 0 if this list does not contain this element.  */       
   method public integer IndexOf(o as Object). 
   
   /* Returns an iterator over the elements in this list in proper sequence. */        
   method public IIterator Iterator().
  
   /* Returns a list iterator over the elements in this list in proper sequence. */        
   method public IListIterator ListIterator().
 
   /* Returns a list iterator of the elements in this list (in proper sequence),
      starting at the specified position in this list. */
   method public IListIterator ListIterator(i as int).
   
   /*  Returns the index in this list of the last occurrence of the 
       specified element, or 0 if this list does not contain this element. */
   method public integer LastIndexOf(o as Object).
  
   /* Returns true if this list contains no elements. */
   method public logical IsEmpty().
   
   /* Removes the element at the specified position in this list
     (optional operation). */
   method public Object Remove (i as integer). 
   
   /* Removes the first occurrence in this list of the specified element 
     (optional operation). */
   method public logical Remove (o as Object). 

   /* Removes from this list all the elements that are contained in the 
      specified collection (optional operation). */
   method public logical RemoveAll (c as ICollection). 
  
   /* Retains only the elements in this list that are contained in the 
      specified collection (optional operation).*/
   method public logical RetainAll (c as ICollection). 
  
   /* Replaces the element at the specified position in this list with the 
      specified element (optional operation). */
   method public Object    Set (i as int, o as Object).
        
   /* Returns a view of the portion of this list between the specified 
      fromIndex, inclusive, and toIndex, exclusive. */
   method public IList SubList(fromIndex as int, toIndex as int).
      
   /* Returns a temp-table containing all of the elements in this list */
   method public void ToTable (output table-handle tt).   
   
   /* returns the contents of the list as an array */
   method public Object extent ToArray ().
    
end interface.
