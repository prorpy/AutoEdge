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
/* ------------------------------------------------------------------------
    File        : BinaryOperationsHelper
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jan 15 14:56:25 EST 2010
    Notes       : * This class based on Garry Hall's binop.i utility    
                  * Utilities to perform bitwise logical operations,
                    which the ABL does not provide. All operations are performed
                    by and on INTEGERs.
                  * These are slower than using ABL arithmetic operators,
                    so try to use an arithmetic operation if possible
                    e.g.    (myval & 255) is the same as (myval mod 256)
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

class OpenEdge.Core.Util.BinaryOperationsHelper:
     
    /* BinAnd - returns the bitwise AND of two INTEGERs as an INT
       INPUT ipiOp1 AS INT - first operand to AND operation
       INPUT ipiOp2 AS INT - second operand to AND operation */
    method static public int BinAnd(piOp1 as int, piOp2 as int):
        define variable ires  as integer init 0 no-undo.
        define variable iloop as integer no-undo.
        
        do iloop = 1 to 32:
            if get-bits(piOp1, iloop, 1) + get-bits(piOp2, iloop, 1) ge 2 then
                put-bits(ires,iloop,1) = 1.
        end.
        
        return ires.
    end method.
    
    /* BinOr  - returns the bitwise OR of two INTEGERs as an INT
       INPUT ipiOp1 AS INT - first operand to OR operation
       INPUT ipiOp2 AS INT - second operand to OR operation */
    method static public int BinOr(piOp1 as int, piOp2 as int):
        define variable ires  as integer init 0 no-undo.    
        define variable iloop as integer no-undo.
        
        do iloop = 1 to 32:
            if get-bits(piOp1, iloop, 1) + get-bits(piOp2, iloop, 1) ge 1 then
                put-bits(ires,iloop,1) = 1.
        end.
        
        return ires.
    end method.

    /* Xor - returns the bitwise Xor of two INTEGERs as an INT
       INPUT ipiOp1 AS INT - first operand to Xor operation
       INPUT ipiOp2 AS INT - second operand to Xor operation
       Derivations:
           BinXor - same operation, provided for consistent naming */
    method static public int Xor (piOp1 as int, piOp2 as int):
        define variable ires  as integer init 0 no-undo.    
        define variable iloop as integer no-undo.
        
        do iloop = 1 to 32:
            if get-bits(piOp1, iloop, 1) + get-bits(piOp2, iloop, 1) eq 1 then
                put-bits(ires,iloop,1) = 1.
        end.
        return ires.
    end method.
    
    method static public int BinXor(piOp1 as int, piOp2 as int):
        return Xor(piOp1,piOp2).
    end method.
    
    /* BinNot - returns the bitwise NOT of an INTEGER as an INT
       INPUT ipiOp1 AS INT - the operand to the NOT operation
       Note that this is performed on ALL 32 bits of the int.
       This is also the same as the following arithmetic:
        -1  (ipiOp1 + 1)   */
    method static public int BinNot(piOp1 as int):
        define variable ires  as integer init 0 no-undo.    
        define variable iloop as integer no-undo.
        
        do iloop = 1 to 32:
            if get-bits(piOp1, iloop, 1) eq 0 then
                put-bits(ires,iloop,1) = 1.
        end.
        
        return ires.
    end method.
    
end class.
