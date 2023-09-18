/*------------------------------------------------------------------------
    File        : test_buildvehicle.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Aug 16 11:56:15 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/

def var cOrder as char.
def var piid as int64.

piid = 2165.
corder = 'AE_TF_REL_V3#2165'.

run service_buildvehicle.p ( corder, piid).