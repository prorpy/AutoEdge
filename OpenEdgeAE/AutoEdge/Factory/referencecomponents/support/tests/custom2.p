DEFINE VARIABLE mptr AS MEMPTR  NO-UNDO.
DEFINE VARIABLE rasw1 AS raw NO-UNDO.
DEFINE VARIABLE cnt  AS INTEGER NO-UNDO.
def var i as int.

def var cvar as char.


cvar = '1165PABLO1115046441163777'.
 
/*ASSIGN                                   */
/*  SET-SIZE(mptr)      = LENGTH(cvar) + 1.*/

i = 1.  
put-byte(rasw1, i) = 116.
i = i + 1.
put-byte(rasw1, i) = 5.
i = i + 1.
put-string(rasw1, i) = 'PABLO'.
i = i + 5.
put-byte(rasw1, i) = 1.
i = i + 1.
put-byte(rasw1, i) = 115.
i = i + 1.
put-byte(rasw1, i) = 0.
i = i + 1.
put-byte(rasw1, i) = 46.
i = i + 1.
put-byte(rasw1, i) = 44.
i = i + 1.
put-byte(rasw1, i) = 116.
i = i + 1.
put-long(rasw1, i) = 3777.
i = i + 4. 

set-size(mptr) = i.
put-bytes(mptr, 1) = rasw1.

message 
get-size(mptr) skip
i
view-as alert-box error.
   
REPEAT cnt = 1 TO get-size(mptr): 
   
    i = GET-BYTE(mptr, cnt).
    
    displ
        i  
        chr(i) 
        . 
END.