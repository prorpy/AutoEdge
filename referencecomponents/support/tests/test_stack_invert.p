
using OpenEdge.Lang.Collections.*.

def var oMyStack as CharacterStack.
def var i as int.

oMyStack = new CharacterStack(12).

oMyStack:Push('a').
oMyStack:Push('b').
oMyStack:Push('c').
oMyStack:Push('d').
oMyStack:Push('e').
oMyStack:Push('f').
oMyStack:Push('g').
oMyStack:Push('h').
oMyStack:Push('i').
oMyStack:Push('j').

def var c as char.
def var cExpected as char.

cExpected = ' a b c d e f g h i j'.

oMyStack:Invert().

do while oMyStack:Size gt 0:
    c = c + ' ' + oMyStack:Pop().
end.  

message 
'right?' (cExpected eq c) skip
c skip
cExpected 
view-as alert-box.




catch e as Progress.Lang.Error:
    message
    e:GetMEssage(1) skip 
    e:CallStack
    view-as alert-box.
end.


/* eof */ 
