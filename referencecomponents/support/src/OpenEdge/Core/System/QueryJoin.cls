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
    File        : QueryJoin
    Purpose     : Parameter object for query join clauses, used in IQueryDefinition 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Dec 10 10:16:46 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.
using Progress.Lang.Object.

class OpenEdge.Core.System.QueryJoin
        implements IExternalizable:
    
    define public property BufferName as character no-undo get. set.
    define public property FieldName as character no-undo get. set.
    define public property Operator as OperatorEnum no-undo get. set.
    define public property JoinBufferName as character no-undo get. set.
    define public property JoinFieldName as character no-undo get. set.
    define public property JoinType as JoinEnum no-undo get. set.
    
    /** Indicates that the JoinBuffer is an external (to this definition anyway)
        join. This may be the case in queries used on ProDataSets' Data-sources,
        where the where string is generated between a DB table and a temp-table in the
        PDS. The query in that case doesn't know about the temp-table 
    @todo(task="refactor", action="create DatasourceQueryDef?").     
    define public property JoinBufferIsExternal as logical no-undo get. set.
        */
    
    constructor public QueryJoin(input pcBufferName as character,
                                 input pcFieldName as character,
                                 input poOperator as OperatorEnum,
                                 input pcJoinBufferName as character,
                                 input pcJoinFieldName as character,
                                 input poJoinType as JoinEnum):
        
        Assert:ArgumentNotNullOrEmpty(pcBufferName, 'Buffer Name').
        Assert:ArgumentNotNullOrEmpty(pcFieldName, 'Field Name').
        Assert:ArgumentNotNull(poOperator, 'Operator').
        Assert:ArgumentNotNull(poJoinType, 'Join type').
        Assert:ArgumentNotNullOrEmpty(pcJoinBufferName, 'Join Buffer Name').
        Assert:ArgumentNotNullOrEmpty(pcJoinFieldName, 'Join Field Name').
        
        assign BufferName = pcBufferName
               FieldName = pcFieldName
               Operator = poOperator
               JoinBufferName = pcJoinBufferName
               JoinFieldName = pcJoinFieldName
               JoinType = poJoinType.
    end constructor.
    
    method override public logical Equals(input p0 as Object):
        define variable lEquals as logical no-undo.
        define variable oQB as QueryJoin no-undo.
                
        lEquals = super:Equals(input p0).

        if not lEquals and type-of(p0, QueryJoin) then
            assign oQB = cast(p0, QueryJoin)
                   lEquals = oQB:BufferName eq this-object:BufferName
                         and oQB:FieldName eq this-object:FieldName                    
                         and oQB:Operator:Equals(this-object:Operator)
                         and oQB:JoinBufferName eq this-object:JoinBufferName
                         and oQB:JoinFieldName eq this-object:JoinFieldName.
        
        return lEquals.
    end method.
    
    method public void WriteObject( input poStream as IObjectOutput):
        poStream:WriteChar(BufferName).
        poStream:WriteChar(FieldName).
        poStream:WriteEnum(Operator).
        poStream:WriteChar(JoinBufferName).
        poStream:WriteChar(JoinFieldName).
        poStream:WriteEnum(JoinType).
    end method.

    method public void ReadObject( input poStream as IObjectInput ):
        assign BufferName = poStream:ReadChar()
               FieldName = poStream:ReadChar()
               Operator = cast(poStream:ReadEnum(), OperatorEnum)
               JoinType =  cast(poStream:ReadEnum(), JoinEnum)
               JoinBufferName = poStream:ReadChar()
               JoinFieldName = poStream:ReadChar().
    end method.
    
end class.
