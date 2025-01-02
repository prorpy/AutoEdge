/* test.p */

DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

cMessage = "Hello, World!".

MESSAGE cMessage VIEW-AS ALERT-BOX INFO BUTTONS OK.
run _edit.p. 