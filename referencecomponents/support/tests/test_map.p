/*------------------------------------------------------------------------
    File        : test_map.p
    Purpose     : 

    Syntax      :

    Description : 

    @author pjudge
    Created     : Wed Apr 21 11:01:37 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
using OpenEdge.Test.*.
using OpenEdge.Lang.Collections.*.
using Progress.Lang.*.

def var okey as MapKey.
def var oval as MapValue.
def var okeepkey as MapKey.
def var okeepval as MapValue.

def var i as int.

def var omap as Map.

omap = new Map().

do i = 1 to 10:
    okey = new MapKey(i, "key for " + string(i)).
    oval = new MapValue(i, "value for " + string(i)).
    omap:put(okey, oval).
    
    if i eq 6 then
    assign okeepkey = okey
            okeepval = oval.

    okey = new MapKey(i, "key for " + string(i)).
    oval = new MapValue(i, "value for " + string(i)).
    omap:put(okey, oval).
end.

oval = cast(omap:Get(okeepkey), MapValue).
oval = cast(omap:Get(new MapKey(6, 'key for 6')), MapValue).

message 
omap:Size skip
'from map=' oval skip 
'equal?' okeepval:Equals(oval) skip
view-as alert-box error title '[PJ DEBUG]'.

catch ea as AppError:
    message 
    ea:ReturnValue skip(2)
    ea:CallStack
    view-as alert-box error title '[PJ DEBUG]'.
end.    


catch es as SysError:
    message 
    es:GetMessage(1) skip(2)
    es:CallStack
    view-as alert-box error title '[PJ DEBUG]'.
end.    

/* eof */