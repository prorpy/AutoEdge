using OpenEdge.Test.*.
using OpenEdge.Core.Util.*.
using OpenEdge.Core.System.*.
using OpenEdge.Lang.*.
using Progress.Lang.*.

def var lc1 as longchar.
def var m1 as memptr.
def var os1 as Object.
def var os3 as Object.

def var oos as IObjectOutput.
def var ois as IObjectInput.

os1 = new S3().
/*os1:Init().*/

oos  = new ObjectOutputStream().
oos:WriteObject(os1).

set-byte-order(m1) = ByteOrderEnum:BigEndian:Value.
oos:Write(output m1).

copy-lob m1 to file 'S1.ser'.

/*
message '[DEBUG]' skip(2)
'written m1 is ' get-size(m1)
view-as alert-box error.
*/

/* clean out */
set-size(m1) = 0.

copy-lob from file 'S1.ser' to object m1.

/*
message '[DEBUG]' skip(2)
'read m1 is ' get-size(m1)
view-as alert-box error.
**/

def var i as int.
def var i2 as int.

/***
do i = 1 to get-size(m1) with down:
    i2 = get-byte(m1, i).
     
    displ
        i
        i2         
        chr(i2).
end. 
  ***/

ois  = new ObjectInputStream().
ois:Read(m1).
os3 = ois:ReadObject().

catch eISE as ObjectInputError:

    eISE:ShowError().
        
end catch.

catch e as AppError:
    message '[DEBUG]' skip(2)
    e:ReturnValue skip
    e:GetMessage(1) skip
    e:CallStack
    view-as alert-box error.
end catch.

finally:
    set-size(m1) = 0.
end finally.

