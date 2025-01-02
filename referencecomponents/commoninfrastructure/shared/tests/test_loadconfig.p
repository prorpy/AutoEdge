
/*------------------------------------------------------------------------
    File        : test_loadconfig.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon May 02 16:25:33 EDT 2011
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

routine-level on error undo, throw.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
def temp-table ttConfiguration no-undo serialize-name 'config'
    field ConfigName as character serialize-name 'name'
    index idx1 as primary unique ConfigName.
    
def temp-table ttProperty no-undo serialize-name 'property'
    field ConfigName as character
    field PropertyName as character serialize-name 'name' 
    field PropertyValue as character serialize-name 'value' 
    index idx1 as primary unique  ConfigName PropertyName.


def temp-table ttServerConnection no-undo serialize-name 'serverconnection'
    field ConfigName as character
    field ServerType as character serialize-name 'type'     
    field ServerName as character serialize-name 'name'
    index idx1 as primary unique ConfigName ServerType ServerName.
    
def temp-table ttServerParameter no-undo serialize-name 'connectionparameter'
    field ConfigName as character
    field ServerType as character
    field ServerName as character
    field ParameterName as character serialize-name 'name'
    field ParameterValue as character serialize-name 'value'
    index idx1 as primary unique ConfigName ServerType ServerName ParameterName.

def dataset dsConfig serialize-name 'configs' for ttConfiguration, ttProperty, ttServerConnection, ttServerParameter
    data-relation for ttConfiguration, ttProperty relation-fields(ConfigName, ConfigName) nested foreign-key-hidden
    data-relation for ttConfiguration, ttServerConnection relation-fields(ConfigName, ConfigName) nested foreign-key-hidden
    data-relation for ttServerConnection, ttServerParameter relation-fields(ConfigName, ConfigName, ServerType, ServerType, ServerName, ServerName) nested foreign-key-hidden
    .


def var c as chara.
def var lcjson as longchar.
def var hpds as handle.

c = 'test_config.json'.
c = search(c).

copy-lob from file c to lcjson.

create dataset hpds.
hpds:read-json ('file', c, 'empty').
dataset dsConfig:read-json ('file', c, 'empty').

dataset dsConfig:write-xml('file', 'test_config.xml', yes).

for each ttConfiguration:
    displ ttConfiguration.
end.





