/** ****************************************************************************
  Copyright 2012 Progress Software Corporation
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
    http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
**************************************************************************** **/
/** ------------------------------------------------------------------------
    File        : OpenEdge/CommonInfrastructure/Common/start_session.p
    Purpose     :  General / common session bootstrapping procedure.
    Syntax      :
    Description : 
    @author pjudge 
    Created     : Thu Dec 23 14:36:11 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentKernel.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.

using OpenEdge.Core.InjectABL.IKernel.
using OpenEdge.Lang.String.
using OpenEdge.Lang.ABLSession.
using Progress.Lang.Class.

/** -- defs -- **/
define variable cFilePattern as character extent 1 no-undo.
define variable oInjectABLKernel as IKernel no-undo.
define variable oServiceManager as IServiceManager no-undo.
define variable oSession as ABLSession no-undo.

/** -- functions -- **/
/** Loads the config file info into the session properties.

    @param character A string of the format CFGFILE=a/b/c.xml,CFGNAME=default
    @return character The session name, based on the config */
function LoadConfigFileInfo returns character
    (input pcSessionParam as character):
    
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cParam as character no-undo.
    define variable cParamName as character no-undo.
    define variable cParamValue as character no-undo.
    define variable cCfgFileName as character no-undo.
    define variable cFullCfgFileName as character no-undo.
    define variable cCfgName as character no-undo.
    define variable cConfigFile as longchar no-undo.
    
    iMax = num-entries(pcSessionParam).
    do iLoop = 1 to iMax:
        cParam = entry(iLoop, pcSessionParam).
        if num-entries(cParam, '=') eq 2 then
        do:
            assign cParamName = entry(1, cParam, '=')
                   cParamValue = entry(2, cParam, '=').
            case cParamName:
                when 'CFGNAME' then cCfgName = cParamValue.
                when 'CFGFILE' then cCfgFileName = cParamValue.
            end case.
        end.
    end.
    
    if cCfgFileName eq '' or cCfgFileName eq ? then
        cCfgFileName = 'config.xml'.
    
    if cCfgName eq '' or cCfgName eq ? then
        cCfgName = 'default'.
    
    cFullCfgFileName = search(cCfgFileName).
    if cFullCfgFileName ne ? then
    do:
        ABLSession:Instance:SessionProperties:Put(
                new String('Config.CFGNAME'), new String(cCfgName)).

        ABLSession:Instance:SessionProperties:Put(
                new String('Config.CFGFILE'), new String(cCfgFileName)).
    
        copy-lob from file cFullCfgFileName to cConfigFile.
        ABLSession:Instance:SessionProperties:Put(
                new String('Config.CFGCONTENT'), new String(cConfigFile)).
    end.
    
    return cCfgName.
end function.

/** -- main -- **/
/* Set the session code before loading the kernel, in case there are dependencies on the session code */
cFilePattern[1] = 'load_injectabl_modules.p'.
oInjectABLKernel = new ComponentKernel().
oInjectABLKernel:Load(cFilePattern).

ABLSession:Instance:SessionProperties:Put(Class:GetClass('OpenEdge.Core.InjectABL.IKernel'), oInjectABLKernel).

/* Store name, location and contents of the config file in use */
ABLSession:Instance:Name = LoadConfigFileInfo(session:param).

oServiceManager = cast(oInjectABLKernel:Get(ServiceManager:IServiceManagerType), IServiceManager).
ABLSession:Instance:SessionProperties:Put(ServiceManager:IServiceManagerType, oServiceManager).

/** -- eof -- **/
