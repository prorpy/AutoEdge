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
    
def temp-table ttServerParameter no-undo serialize-name 'parameter'
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


create ttConfiguration.
ttConfiguration.ConfigName = 'default'.

create ttProperty.
ttProperty.ConfigName = ttConfiguration.ConfigName. 
ttProperty.PropertyName = 'propath'.
ttProperty.PropertyValue = 'propath value'.

create ttProperty.
ttProperty.ConfigName = ttConfiguration.ConfigName. 
ttProperty.PropertyName = 'session:date-format'.
ttProperty.PropertyValue = 'dmy'.

create ttServerConnection.
ttServerConnection.ConfigName = ttConfiguration.ConfigName.
ttServerConnection.ServerType = 'appserver'.
ttServerConnection.ServerName = 'aetf'.

create ttServerParameter.
ttServerParameter.ConfigName = ttServerConnection.ConfigName.
ttServerParameter.ServerType = ttServerConnection.ServerType.
ttServerParameter.ServerName = ttServerConnection.ServerName.
ttServerParameter.ParameterName = 'appservice'.
ttServerParameter.ParameterValue = 'asAutoEdgeTheFactory'.

create ttServerParameter.
ttServerParameter.ConfigName = ttServerConnection.ConfigName.
ttServerParameter.ServerType = ttServerConnection.ServerType.
ttServerParameter.ServerName = ttServerConnection.ServerName.
ttServerParameter.ParameterName = 'host'.
ttServerParameter.ParameterValue = ''.

create ttServerConnection.
ttServerConnection.ConfigName = ttConfiguration.ConfigName.
ttServerConnection.ServerType = 'bpmserver'.
ttServerConnection.ServerName = 'aetf'.

create ttServerParameter.
ttServerParameter.ConfigName = ttServerConnection.ConfigName.
ttServerParameter.ServerType = ttServerConnection.ServerType.
ttServerParameter.ServerName = ttServerConnection.ServerName.
ttServerParameter.ParameterName = 'host'.
ttServerParameter.ParameterValue = 'localhost'.

create ttServerParameter.
ttServerParameter.ConfigName = ttServerConnection.ConfigName.
ttServerParameter.ServerType = ttServerConnection.ServerType.
ttServerParameter.ServerName = ttServerConnection.ServerName.
ttServerParameter.ParameterName = 'port'.
ttServerParameter.ParameterValue = '18793'.


dataset dsConfig:write-json('file', 'test_config.json', true).
dataset dsConfig:write-xml('file', 'test_config.xml', true).

dataset dsConfig:empty-dataset().

def var c as chara.
def var lcjson as longchar.
def var hpds as handle.

c = 'test_config.xml'.
c = search(c).

copy-lob from file c to lcjson.

create dataset hpds.
/*hpds:read-json ('file', c, 'empty').*/
/*dataset dsConfig:read-json ('file', c, 'empty').*/
dataset dsConfig:read-xml('file', c, 'empty', ?, ?).

dataset dsConfig:copy-dataset (hpds, ?, ?, true).


for each ttConfiguration:
    displ ttConfiguration.
end.
