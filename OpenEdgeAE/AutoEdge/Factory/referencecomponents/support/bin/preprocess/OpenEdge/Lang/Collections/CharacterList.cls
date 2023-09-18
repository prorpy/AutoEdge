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
/*---------------------------------------------------------------------------------------
    File        : CharacterList
    Purpose     : lightweight class for character entries 
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Tue Sep 29 21:48:14 EDT 2009
    Notes       : Does NOT implement IList (kind of IList<character>) and has no iterator 
  --------------------------------------------------------------------------------------*/
 
using Progress.Lang.*.
using OpenEdge.Lang.Collections.IList.

routine-level on error undo, throw.

class OpenEdge.Lang.Collections.CharacterList /*implements IList*/: 
    define variable mList as character no-undo.
    define variable mDlm  as character no-undo.
    
    define public property Size as integer no-undo 
    get():
       return num-entries(mList,mDlm).
    end.
    
    constructor CharacterList():
        mdlm = chr(1).
    end constructor.    
    
    constructor CharacterList(dlm as char):
        mDlm = dlm.
    end constructor. 
        
    method public logical Add(  i as integer,  c as character ):
        define variable oldVal as character no-undo. 
        if i > Size + 1 then 
            return false.
        if i = Size + 1 then 
            return this-object:Add(c).
        else do:
            oldVal = Get(i).
            entry(i,mList,mDlm) = mDlm + oldVal.
            entry(i,mList,mdlm) = c.
            return true.
        end.              
    end method.
   
    method public logical Add(  c as character ):
        mList = (if mList = "" then "" else mList + mDlm) 
              + c. 
        return true.      
    end method.
    
    method public void Clear(  ):
        mList = "".
    end method.

    method public logical Contains( c as character ):
        return lookup(c,mList,mDlm) > 0. 
    end method.
     
    method public character Get( i as integer ):
        if i <= Size and i > 0 then
           return entry(i,mList,mDlm).
         return ?.      
    end method.
    
    method public integer IndexOf(c as character):
        return lookup(c,mList,mDlm).
    end method.

    method public logical IsEmpty(  ):
        return mList = "".
    end method.

    method public character Remove(  i as integer ):
        define variable oldVal  as character.
        oldVal = Get(i). 
        if oldVal <> ? then 
        do:
            entry(i,mList,mDlm) = "".
            mList = trim(mList,mDlm).
            mList = replace(mList,mDlm + mdlm,mDlm).
        end.
        return oldVal.          
    end method.
    
    method public logical Remove(  c as character ):
        define variable i as integer no-undo.
        i = IndexOf(c).
        if i > 0 then
           return Remove(i) <> ?.
        return false.    
    end method.

    method public character Set(  i as integer,  c as character ):
        define variable oldVal  as character.
        oldVal = Get(i). 
        if oldVal <> ? then 
            entry(i,mList,mDlm) = c.
        return oldVal.
    end method.
 
end class.
