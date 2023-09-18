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
    File        : IExternalizable
    Purpose     : Interface for Externalisable objects.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Nov 25 12:42:41 EST 2009
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IExternalizable.

interface OpenEdge.Core.Util.IExternalizable:   /* inherits ISerializable */

    /** Serialization method for an object.
        
        @param IObjectOutput The object that's performing the serialization */   
    method public void WriteObject(input poStream as IObjectOutput).
    
    /** Deserialization method for an object.
        
        @param IObjectInput The object that's performing the deserialization */
    method public void ReadObject(input poStream as IObjectInput).
    
end interface.
