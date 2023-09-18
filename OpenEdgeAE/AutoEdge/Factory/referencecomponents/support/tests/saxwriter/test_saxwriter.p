/* ------------------------------------------------------------------------
    File        : test_saxwriter.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Tue Nov 23 10:11:08 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
using OpenEdge.Core.XML.SaxWriter. 
using OpenEdge.Core.System.ApplicationError.
 
define variable cInputParam    as longchar  no-undo.
define variable cOutputParam   as longchar  no-undo.
define variable cWholeDSI      as longchar  no-undo.
define variable cDSI           as longchar  no-undo.
define variable moSaxWriter    as SaxWriter no-undo.
def    var      pcSessionId    as character init '112233'.
def    var      pcWorkItemName as character init 'DoSomeWork'.
def var lok as logical.

function StartSoapMessage returns log (input pcName as character, pcNS as char):
    if not moSaxWriter:Reset() then
        moSaxWriter:Initialize().
    moSaxWriter:IsStrict = false.
    
    moSaxWriter:WriteTo(session:temp-dir + 'test.xml').
    moSaxWriter:StartDocument().
    moSaxWriter:StartElement(substitute('&1:&2', pcns, pcName )).
    moSaxWriter:DeclareNamespace("http://OpenEdge.Lang.BPM.savvion.com", pcns).
end.

function EndSoapMessage returns logical (input pcName as character, pcNS as char):
    moSaxWriter:EndElement(substitute('&1:&2', pcns, pcName)).
end.

/* ***************************  Main Block  *************************** */
moSaxWriter = new SaxWriter().
moSaxWriter:IsFragment = true.
        
/* for debugging */
moSaxWriter:IsFormatted = true.


StartSoapMessage('completeWorkItem', 'ns0').
moSaxWriter:StartElement('ns0:session').
moSaxWriter:WriteValue(pcSessionId).
moSaxWriter:EndElement('ns0:session').

moSaxWriter:StartElement('ns0:wiName').
moSaxWriter:WriteValue(pcWorkItemName).
moSaxWriter:EndElement('ns0:wiName').

EndSoapMessage('completeWorkItem', 'ns0').
lok = moSaxWriter:EndDocument().

message 
    'ok?=' lok skip
    string(coutputparam)
    view-as alert-box info buttons ok.

        
        /*
        cWholeDSI = DataSlotInstance:ArrayToXML(dsi, 'dsi').
        cInputParam = substitute('<ns0:completeWorkItem xmlns:ns0="http://OpenEdge.Lang.BPM.savvion.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ns0:session>&1</ns0:session><ns0:wiName>&2</ns0:wiName>&3</ns0:completeWorkItem>'
                        , pcSessionId, wiName, cWholeDSI).
        
        cOutputparam = ExecuteOperation(mcPortType, 'completeWorkItem', cInputParam).
        */        

    

/** ----------------- **/
catch oException as ApplicationError:
    oException:LogError().
    oException:ShowError().
end catch.

catch oError as Progress.Lang.Error:
    message
        oError:GetMessage(1)      skip
        '(' oError:GetMessageNum(1) ')' skip(2)        
        oError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.Error'.
end catch.
