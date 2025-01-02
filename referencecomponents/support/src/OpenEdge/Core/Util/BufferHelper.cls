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
    File        : BufferHelper
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 19 15:16:47 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.BufferNotAvailableError.
using OpenEdge.Core.System.BufferFieldMismatchError.

using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.CompareStrengthEnum.
using OpenEdge.Lang.DataTypeEnum.

class OpenEdge.Core.Util.BufferHelper: 
    
    method public static character extent BufferCompare (phSource as handle,
                                                         phTarget as handle):
        define variable iLoop          as integer   no-undo.
        define variable iField         as integer   no-undo.
        define variable hSourceField   as handle    no-undo.
        define variable hTargetField   as handle    no-undo.
        define variable iExtent        as integer   no-undo.
        define variable lExtent        as logical   no-undo.
        define variable iNumItems      as integer   no-undo.
        define variable iNumDiff       as integer   no-undo.
        define variable cChangedFields as character extent no-undo.
        define variable cTempFields    as character extent no-undo.
        
        if not valid-handle(phSource) then
            undo, throw new InvalidValueSpecifiedError('source buffer').
                        
        if not phSource:available then
            undo, throw new BufferNotAvailableError(phSource:name).

        if not valid-handle(phTarget) then
            undo, throw new InvalidValueSpecifiedError('target buffer').
                
        if not phTarget:available then
            undo, throw new BufferNotAvailableError(phTarget:name).
        
        /* max size is num fields in buffer */
        extent(cTempFields) = phSource:num-fields.
        
        do iField = 1 to phSource:num-fields:
            hSourceField = phSource:buffer-field(iField).
            hTargetField = phTarget:buffer-field(hSourceField:name) no-error.
    
            if not valid-handle(hTargetField) then
                undo, throw new BufferFieldMismatchError(phSource:Name, phTarget:Name).
    
            assign lExtent   = hSourceField:extent gt 0
                   iNumItems = if not lExtent then 1 else hSourceField:extent.
            
            do iExtent = 1 to iNumItems:
                if not CompareFieldValues(hSourceField,
                                          if lExtent then iExtent else 0,
                                          OperatorEnum:IsEqual,
                                          hTargetField,
                                          if lExtent then iExtent else 0,
                                          CompareStrengthEnum:Raw ) then 
                    assign iNumDiff = iNumDiff + 1
                           cTempFields[iNumDiff] = hSourceField:name
                                                 + if lExtent then "[" + string(iExtent) + "]" else "".
            end.  /* extent loop */
        end. /* field loop */

        extent(cChangedFields) = iNumDiff.
        do iField = 1 to iNumDiff:
            cChangedFields[iField] = cTempFields[iField].
        end.
                        
        return cChangedFields.
    end method.
        
    method protected static logical CompareFieldValues ( phColumn1  as handle,        
                                                         piExtent1  as integer,
                                                         poOperator as OperatorEnum,
                                                         phColumn2  as handle,
                                                         piExtent2  as integer,
                                                         poStrength as CompareStrengthEnum):
        define variable lSame   as logical no-undo.
        define variable iExtent as integer no-undo.
             
        if DataTypeEnum:Clob:Equals(phColumn1:data-type) then
            lSame = CompareClobValues(phColumn1,
                                      poOperator,
                                      phColumn2,
                                      poStrength).   
        else
        if DataTypeEnum:Character:Equals(phColumn1:data-type) then
            lSame = compare(phColumn1:buffer-value(piExtent1),
                            poOperator:ToString(),
                            phColumn2:buffer-value(piExtent2),
                            poStrength:ToString()).
        else
        do:
            case poOperator:
                when OperatorEnum:IsEqual then
                    lSame = phColumn1:buffer-value(piExtent1) eq phColumn2:buffer-value(piExtent2).
                when OperatorEnum:LessThan then
                    lSame = phColumn1:buffer-value(piExtent1) lt phColumn2:buffer-value(piExtent2).
                when OperatorEnum:LessEqual then
                    lSame = phColumn1:buffer-value(piExtent1) le phColumn2:buffer-value(piExtent2).
                when OperatorEnum:GreaterEqual then
                    lSame = phColumn1:buffer-value(piExtent1) ge phColumn2:buffer-value(piExtent2).
                when OperatorEnum:GreaterThan then
                    lSame = phColumn1:buffer-value(piExtent1) gt phColumn2:buffer-value(piExtent2).
                when OperatorEnum:NotEqual then
                    lSame = phColumn1:buffer-value(piExtent1) ne phColumn2:buffer-value(piExtent2).
            end case.
        end.
                        
        return lSame.
    end method.
              
    method protected static logical CompareClobValues ( phColumn1  as handle,                
                                                        poOperator as OperatorEnum,
                                                        phcolumn2  as handle,
                                                        poStrength as CompareStrengthEnum) :
        define variable cLong1    as longchar no-undo.
        define variable cLong2    as longchar no-undo.
        define variable lUnknown1 as logical  no-undo.
        define variable lUnknown2 as logical  no-undo.
        define variable lEqual    as logical  no-undo.
        define variable lCompare  as logical  no-undo.
    
        assign lEqual    = poOperator eq OperatorEnum:IsEqual
               lUnknown1 = (phColumn1:buffer-value eq ?)
               lUnknown2 = (phColumn2:buffer-value eq ?).
    
        if lUnknown1 and lUnknown2 then
            lCompare = lEqual.
        else
        if lUnknown1 or lUnknown2 then
            lCompare = not lEqual.
        else
        if length(phColumn1:buffer-value) ne length(phColumn2:buffer-value) then
            lCompare = not lEqual.
        else
        do:
            copy-lob from phColumn1:buffer-value to cLong1.
            copy-lob from phColumn2:buffer-value to cLong2.
            lCompare = compare(cLong1,
                               poOperator:ToString(),
                               cLong2,
                               poStrength:ToString()).
        end.
            
        return lCompare.
    end method.
end class.
