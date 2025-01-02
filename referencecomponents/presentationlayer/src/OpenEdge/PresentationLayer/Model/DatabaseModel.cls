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
    File        : DatabaseModel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu May 21 11:41:31 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.Model.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
 
class OpenEdge.PresentationLayer.Model.DatabaseModel  abstract 
        inherits Model:
    
    constructor public DatabaseModel(input pcServiceName as character, input poComponentInfo as IComponentInfo ):
        super(input pcServiceName, input poComponentInfo).
    end constructor.
    
    method override protected handle GetBufferHandle(input pcTableName as character):
       define variable hBuffer as handle no-undo.
       
       create buffer hBuffer for table pcTableName buffer-name pcTableName.
       
       return hBuffer.
    end method.
    
 end class.
