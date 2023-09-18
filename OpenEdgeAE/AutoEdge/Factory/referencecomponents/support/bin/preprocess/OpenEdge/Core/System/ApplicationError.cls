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
    File        : OpenEdge.Core.System.ApplicationError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Mar 09 10:37:02 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.ErrorSeverityEnum.

using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.IOModeEnum.
using OpenEdge.Lang.FlagsEnum.
using OpenEdge.Lang.Assert.
using Progress.Lang.ParameterList.
using Progress.Lang.AppError.
using Progress.Lang.Object.
using Progress.Lang.Class.
using Progress.Lang.Error.

class OpenEdge.Core.System.ApplicationError abstract inherits AppError
        implements IExternalizable:
    
    define static public property ShowDebugMessages as logical no-undo init false get. set.
    
    define public property InnerError as Error no-undo get. protected set.
    
    define abstract protected property ErrorTitle as character no-undo get.         
    define abstract protected property ErrorText as longchar no-undo get.
    
    define protected property LogFileName as character no-undo get. set.
    
    define private stream sLog.
    
    constructor public ApplicationError():               
        super().
        
    /* OE00218181  
    /* can/will be overwritten by individual Error */
        this-object:Severity = ErrorSeverityEnum:Default:Value.
        this-object:ReturnValue = ResolvedMessageText().
    */
        
        LogFileName = session:temp-directory + '/' + 'error.log'.
        this-object:ReturnValue = ResolvedMessageText().
    end constructor.
    
    constructor public ApplicationError(poInnerError as Error):               
        this-object().
        
        this-object:InnerError = poInnerError.
        this-object:ReturnValue = ResolvedMessageText().
    end constructor.
    
    method public void LogError():
        output stream sLog to value(LogFileName) append.
            put stream sLog unformatted iso-date(now) ' : ' ResolvedMessageText().
        output stream sLog close.
    end method.

    method public void ShowError():
        /** This method should probably use a 'proper' message dialog; this
            might be a complete MVP application. For now, we simply use
            the MESSAGE statement. **/

        if FlagsEnum:IsA(this-object:Severity, ErrorSeverityEnum:Fatal) or
           FlagsEnum:IsA(this-object:Severity, ErrorSeverityEnum:Critical) or
           FlagsEnum:IsA(this-object:Severity, ErrorSeverityEnum:Error)then
            message ResolvedMessageText() view-as alert-box error title ResolvedTitle().
        else
        if FlagsEnum:IsA(this-object:Severity, ErrorSeverityEnum:Info) or
           FlagsEnum:IsA(this-object:Severity, ErrorSeverityEnum:Debug) then
            message ResolvedMessageText() view-as alert-box information title ResolvedTitle().
        else
        if FlagsEnum:IsA(this-object:Severity, ErrorSeverityEnum:Message) then
            message ResolvedMessageText() view-as alert-box message title ResolvedTitle().
        else
            message ResolvedMessageText() view-as alert-box warning title ResolvedTitle().
    end method.
    
    method public character ResolvedTitle():
        return substitute('&1', this-object:ErrorTitle).
    end method.
    
    @todo(task="implement", action="needs refactoring sans formatting").            
    method public character ResolvedMessageText():
        define variable cMsg      as character no-undo.        
        
        cMsg = substitute(this-object:ErrorText,
                               GetMessage(1),
                               GetMessage(2),
                               GetMessage(3),
                               GetMessage(4),
                               GetMessage(5),
                               GetMessage(6),
                               GetMessage(7),
                               GetMessage(8),
                               GetMessage(9)).
        if CallStack gt "" then 
            cMsg = cMsg 
                 + "~n~n"
                 + "Call Stack:"
                 + "~n------------~n"
                 + CallStack.            
        
        cMsg = ResolveInnerErrorText(cMsg).
        
        return cMsg.                 
    end method.
    
    method protected character ResolveInnerErrorText(input pcMessageText as character):
        define variable cInnerMsg as character no-undo.
        
        if valid-object(InnerError) then 
        do:
            if type-of(InnerError, ApplicationError) then
                cInnerMsg = cast(InnerError, ApplicationError):ResolvedMessageText().
            else if type-of(InnerError,AppError) then
                cInnerMsg = CoreErrorMessageText(cast(InnerError, AppError)).
            else 
                cInnerMsg = CoreErrorMessageText(InnerError).
            if cInnerMsg gt "" then
            do:
               pcMessageText = pcMessageText 
                    + (if pcMessageText eq "" then "" 
                       else "~n~n" 
                            + "Caused by:" 
                            + "~n") 
                    + cInnerMsg.
               if InnerError:CallStack gt "" then 
                  pcMessageText = pcMessageText 
                       + "~n~n"
                       + "Call Stack:"
                       + "~n------------~n"
                       + InnerError:CallStack.
            end.       
        end.         
        
        return pcMessageText.
    end method.
    
    /* returns text for an AppError 
       If there is a ReturnValue then NumMessages will not be checked or used  */  
    method protected character CoreErrorMessageText (poErr as AppError):
        if type-of(poErr, AppError) then 
            return poErr:ReturnValue.
        else  
            return CoreErrorMessageText(cast(poErr,Error)).   
    end method.
    
    method protected character CoreErrorMessageText (poErr as Error):
        define variable cMsg as character no-undo.
        define variable i as integer no-undo. 
       
        do i = 1 to poErr:NumMessages:
            cMsg = cMsg 
                 + (if cMsg = "" then "" else "~n~n") 
                 + poErr:GetMessage(i).
        end.    
       
        return cMsg.
    end method.
         
    method public override Object Clone():
        define variable oParams as ParameterList no-undo.
        define variable oClone as ApplicationError no-undo.
        define variable oClass as class Class no-undo. 
        define variable iLoop  as integer no-undo.
        
        oClass = this-object:GetClass().
        oParams = new ParameterList(1).
        oParams:SetParameter(1,
                             substitute(DataTypeEnum:Class:ToString(), 'Progress.Lang.Error'),
                             IOModeEnum:Input:ToString(),
                             this-object:InnerError).
        oClone = cast(oClass:New(oParams), ApplicationError).
        do iLoop = 1 to NumMessages:
            oClone:AddMessage(GetMessage(iLoop), iLoop).
        end.
        oClone:Severity = this-object:Severity.
        oClone:ReturnValue = this-object:ReturnValue.
        
        return oClone.
    end method.

    method public void WriteObject(input poStream as IObjectOutput):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = NumMessages.
        poStream:WriteInt(iMax).
        do iLoop = 1 to iMax:
            poStream:WriteLongchar(GetMessage(iLoop)).
        end.
                        
        poStream:WriteInt(this-object:Severity).
        poStream:WriteObject(InnerError).
    end method.

    method public void ReadObject(input poStream as IObjectInput):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = poStream:ReadInt().
        do iLoop = 1 to iMax:
            this-object:AddMessage(string(poStream:ReadLongchar()), iLoop).
        end.
        
        this-object:Severity = poStream:ReadInt().
        InnerError = cast(poStream:ReadObject(), Error).
    end method.
    
end class.
