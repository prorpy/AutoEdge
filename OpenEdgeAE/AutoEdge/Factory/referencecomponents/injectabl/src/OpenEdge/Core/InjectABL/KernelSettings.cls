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
    File        : KernelSettings
    Purpose     : Flags/settings for the InjectABL kernel
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 11 12:05:46 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.KernelSettings.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.DateTimeAddIntervalEnum.

class OpenEdge.Core.InjectABL.KernelSettings inherits Map:
    
    define static public property NO_PRUNE_INTERVAL as integer init -1 no-undo get. private set.
    
    define public property CachePruningInterval as integer no-undo get. set.    
    define public property CachePruningUnit as DateTimeAddIntervalEnum no-undo get. set.
    
    constructor public KernelSettings():

        CachePruningInterval = KernelSettings:NO_PRUNE_INTERVAL.
        CachePruningUnit = DateTimeAddIntervalEnum:Default.
    end constructor.
    
end class.
