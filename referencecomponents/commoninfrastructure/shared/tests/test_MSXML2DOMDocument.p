def var serverConfigXML as com-handle.
def var parentnode as com-handle.
def var childnode as com-handle.


create "MSXML2.DOMDocument.6.0" serverConfigXML.

serverConfigXML:async = False.
serverConfigXML:resolveExternals = False.
        
    ParentNode = serverConfigXML:createElement('configs').
    ParentNode:setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance').    
    serverConfigXML:documentElement = ParentNode.
  
    ChildNode = serverConfigXML:createElement('config').
    ParentNode:appendChild(ChildNode).
    ParentNode = ChildNode.
    
    ChildNode = serverConfigXML:createElement('name').
    ChildNode:text = 'default'.
    ParentNode:appendChild(ChildNode).
           
    /*//Get the config node.*/
    /*ParentNode = serverConfigXML:selectSingleNode("/configs/config[name = 'default']").*/
    ParentNode = serverConfigXML:selectSingleNode("/configs/config/name").
    
    MESSAGE valid-handle(ParentNode)
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
    ParentNode = serverConfigXML:selectSingleNode('/configs/config').
    MESSAGE valid-handle(ParentNode)
        
        
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
    /*ParentNode:appendChild(ChildNode).*/

serverConfigXML:save(session:temp-dir + 'test.xml').

release object ChildNode.
    release object ParentNode.
        release object serverConfigXML.
