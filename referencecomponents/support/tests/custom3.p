def var m1 as memptr.
def var r1 as raw.
def var i as int.
def var i2 as int.

copy-lob from file 'S1.ser' to object m1.
/*copy-lob from file 'S1.ser' to object r1.*/

message '[DEBUG]' skip(2)
'read m1 is ' get-size(m1)
view-as alert-box error.


do i = 1 to get-size(m1) with down:
    i2 = get-byte(m1, i).
     
    displ
        i
        i2         
        chr(i2).
end. 

