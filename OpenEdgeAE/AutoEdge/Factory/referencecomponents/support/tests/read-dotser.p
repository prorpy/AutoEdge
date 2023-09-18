def var lc1 as longchar.
def var mm as memptr.

copy-lob from file 'C:\Devarea\views\pjudge_AUTOEDGE20\vobs_autoedge\uia\system\S1.ser' to mm.


def var i as int.
def var i2 as int.

output to c:\temp\dotser.out.
DO  i = 1 to get-size(mm) with down:
    i2 = get-byte(mm,i).
    
    display    
        i 
        i2
        chr(i2) 
        OpenEdge.Core.System.ObjectStreamConstants:ToString(i2) format 'x(30)'
        skip
        with width 128.        
        
END.
output close.