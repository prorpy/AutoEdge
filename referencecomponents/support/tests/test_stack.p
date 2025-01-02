/*------------------------------------------------------------------------
    File        : test_stack.p
    Purpose     : 

    Syntax      :

    Description : 

    @author pjudge
    Created     : Fri Feb 12 16:41:04 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
using OpenEdge.Lang.Collections.*.
using Progress.Lang.*.

def var o as CharacterStack.

o = new CharacterStack().

o:Push('a').
o:Push('b').
o:Push('c').
o:Push('d').
o:Push('e').
o:Push('f').

message 
'depth= ' o:Depth skip
'size=' o:Size skip
view-as alert-box.

o:Depth = 5.

message 
'depth= ' o:Depth skip
'size=' o:Size skip
view-as alert-box.


catch e as Error:
    message 
    e:GetMessage(1)
    view-as alert-box.
end catch.
/* eof */