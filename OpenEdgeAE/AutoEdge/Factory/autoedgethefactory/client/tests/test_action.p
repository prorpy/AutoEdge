    
define temp-table eAction no-undo xml-node-name 'action'
        field Key            as char xml-node-type 'attribute'
        field ActionType     as int     /* ActionTypeEnum:Group,Label,Launch etc */
        field ActionText     as char    /* label */
        field SmallImagePath as char
        field LargeImagePath as char
        field HelpText       as char
        index idx1 as primary unique Key.
            
    /* ActionGroup always has ActionStructure */
    define temp-table eActionStructure no-undo xml-node-name 'actionstructure'
        field ParentKey as char    /* Always ActionTypeEnum:Group */
        field ChildKey  as char    /* Any ActionTypeEnum. If Group then recurse. */
        field Order     as int
        index idx1 as primary unique ParentKey Order
        .
    
    define temp-table eActionArgs no-undo xml-node-name 'ToolbarActionEventArgs'
        field ActionKey as char xml-node-type 'attribute'
        field ArgName   as char
        field ArgValue  as char
        field ArgType   as int  /* Base.System.DataTypeEnum */
        index idx1 as primary unique ActionKey ArgName
        .
            
    define dataset dsAction xml-node-name 'action' for eAction, eActionStructure, eActionArgs
        data-relation for eAction, eActionArgs relation-fields (Key, ActionKey).


run OERA/Components/load_action.p (input-output dataset dsAction).

def var hq as handle.
def var h1 as handle.
def var h2 as handle.
def var h3 as handle.

function getnext returns logical ():
    def var irow as int.
    
    iRow = hQ:current-result-row.
/*    hQ:reposition-to-row(iRow + 1).*/

    hq:get-next().
    
    return hq:get-buffer-handle(1):available.
end function.
    
function getFirst returns logical ():
    hq:get-first().
    
    return hq:get-buffer-handle(1):available.
end function.    



create query hq.

create buffer h1 for table buffer eAction:handle buffer-name 'lbGroup'.
create buffer h2 for table buffer eActionStructure:handle buffer-name 'lbStructure'.
create buffer h3 for table buffer eAction:handle buffer-name 'lbAction'.

hq:add-buffer(h1).
hq:add-buffer(h2).
hq:add-buffer(h3).

hq:query-prepare(
'preselect each lbGroup where   
    lbGroup.ActionType EQ "3" and lbGroup.Key EQ "AG-FileMenu" 
    no-lock ,  
  each lbStructure where   
    lbStructure.ParentKey EQ lbGroup.Key 
    no-lock ,  
  each lbAction where   
    lbAction.Key EQ lbStructure.ChildKey 
    no-lock   
    by lbStructure.Order '
).


hq:query-open().

def var hb1 as handle.

define frame f1
    with 
        width 100
        down.

create browse hb1
    assign query = hq
        frame = frame f1:handle
        width = 80 .
hb1:add-columns-from(h1).

hq:query-open().
        
enable all with frame f1.

getnext().
getnext().

wait-for close of this-procedure.        
    
/***
def var lok as log.

lok = getfirst().

do while lok:
    MESSAGE '[DEBUG]' skip
        skip(2)
        h1::Key skip
        h3::Key    
    view-as alert-box error.
    
    lok = getnext().
end .    

***/
