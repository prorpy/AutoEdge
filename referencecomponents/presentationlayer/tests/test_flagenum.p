using OpenEdge.PresentationLayer.Model.DataRequestFlagsEnum.

def var o as int.

o = DataRequestFlagsEnum:IgnoreContextForFetch:Value.
o = 0.

MESSAGE '[DEBUG]' skip
    'IgnoreContextForFetch=' DataRequestFlagsEnum:IsA(o, DataRequestFlagsEnum:IgnoreContextForFetch) skip
    /*
    'AntoherTHing=' DataRequestFlagsEnum:IsA(o, DataRequestFlagsEnum:AntoherTHing) skip
    'AFlag=' DataRequestFlagsEnum:IsA(o, DataRequestFlagsEnum:AFlag) skip
    */
view-as alert-box error.   
