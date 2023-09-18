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
    File        : SaxWriterError
    Purpose     : Application error raised when errors are raised by the SaxWriter / SAX-WRITER
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Nov 22 16:04:57 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

class OpenEdge.Core.XML.SaxWriterError inherits ApplicationError: 
    define override protected property ErrorText as longchar no-undo get. set. 
    define override protected property ErrorTitle as character no-undo get. set. 

    constructor public SaxWriterError(input poInnerError as Error):
        super(poInnerError).
        
        this-object:ErrorTitle = 'Sax Writer Error'.
        this-object:ErrorText = 'Error &1 &2'.
    end constructor.

    constructor public SaxWriterError(input poErr as Error,
                                      input pcArgs1 as character,
                                      input pcArgs2 as character):
        this-object(poErr).
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.

    constructor public SaxWriterError(input pcArgs1 as character,
                                      input pcArgs2 as character):
        this-object(?).
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.

end class.
