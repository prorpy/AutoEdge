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
    File        : TableContext
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 27 15:01:35 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.

using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Lang.Assert.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableContext
        implements ITableContext, IExternalizable: 
    
    /** protected set - not changeable - provide with constructor  */  
    define public property TableName as character no-undo get. private set.
    
    /** The buffer/table handle corresponding to the tableName */
    define public property TableHandle as handle no-undo get. set.
    
    /** num rows in resultset (on server if paging) */
    define public property PageSize as integer no-undo get. set.
    
    /** Indicates whether the PageSize property is accurate or not. For instance, if the
        underlying query used PRESELECT we can be fairly sure it's accurate. Otherwise, not 
        so much. */
    define public property FuzzyPageSize as logical no-undo get. set.
        
    /** The number of remaining pages to retrieve. If this is zero, then
        all data has been retrieved. If it is negative, then we haven't yet
        retrieved any pages and don't know how many there are. */
    define public property NumRemainingPages as integer no-undo get. set.
     
    /** Context info/key for where to start appending next page */
    define public property NextPosition as character extent no-undo get. set.
    
    /** context info/key for where to start appending next page */
    define public property PrevPosition as character extent no-undo get. set.
    
    /** Whether paging/batching is enabled for this table. If false,
       the the PageSize property is ignored. */
    define public property PagingEnabled as logical no-undo get. set.
    
    /** The last time that a request was made for the table to be updated 
        (either fetched or saved). */
    define public property LastUpdateAt as datetime-tz no-undo get. set.
    
    constructor public TableContext(input pcTableName as character, input phTable as handle):
        Assert:ArgumentNotNullOrEmpty(pcTableName, 'Table Name').
        
        assign TableName = pcTableName
               TableHandle = phTable
               
               /* default to no paging */
               PageSize = -1
               
               NumRemainingPages = -1
               LastUpdateAt = now.
    end constructor.
    
    method override public Object Clone():
        define variable oClone as TableContext no-undo.
        
        oClone = new TableContext(this-object:TableName, ?).
        assign oClone:PageSize = PageSize
               oClone:NumRemainingPages = NumRemainingPages 
               oClone:NextPosition = NextPosition
               oClone:PrevPosition = PrevPosition
               oClone:PagingEnabled = PagingEnabled
               oClone:LastUpdateAt = LastUpdateAt.
        
        return oClone.
    end method.

    method public void ReadObject( input poStream as IObjectInput):
        assign TableName = poStream:ReadChar()
               PageSize = poStream:ReadInt()
               NumRemainingPages = poStream:ReadInt()
               NextPosition = poStream:ReadCharArray()
               PrevPosition = poStream:ReadCharArray()
               PagingEnabled = poStream:ReadLogical()
               LastUpdateAt = poStream:ReadDateTimeTz().
    end method.

    method public void WriteObject( input poStream as IObjectOutput ):
        poStream:WriteChar(TableName).
        poStream:WriteInt(PageSize).
        poStream:WriteInt(NumRemainingPages).
        poStream:WriteCharArray(NextPosition).
        poStream:WriteCharArray(PrevPosition).
        poStream:WriteLogical(PagingEnabled).
        poStream:WriteDateTimeTz(LastUpdateAt).        
    end method.
    
end class.
