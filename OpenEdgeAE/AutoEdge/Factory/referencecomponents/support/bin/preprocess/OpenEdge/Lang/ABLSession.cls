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
    File        : ABLSession
    Purpose     : An extension of the SESSION system handle. 
    Syntax      : 
    Description : ABLSession object : this object lives for the lifespan of 
                  an AVM Session. 
    @author pjudge
    Created     : Fri Jun 04 15:00:56 EDT 2010
    Notes       : * Store customer properties for a session in the SessionProperties 
                    IMap property
                  * Discover handle- and object- references for given names
                  * Resolves weak references
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.  
using Progress.Lang.Class. 
using Progress.Lang.Object.

class OpenEdge.Lang.ABLSession:
    
    /** Information regarding session lifespan. */    
    define public property ActiveSince as datetime-tz no-undo get. private set.
    
    /** A unique identifier for this session. The SESSION:HANDLE tends to be the
        same every time; this gives us the opportunity to identify this session across all time and space */
    define public property Id as character no-undo get. private set.
    
    /** A collection of user-defined properties. These
        can be any key/value set of objects. */
    define public property SessionProperties as IMap no-undo get. private set.

    /** An optional session type identifier. Defaults to SESSION:CLIENT-TYPE, but we have
        need for more complex session identifiers ('Development' or 'ClientRuntime'), which
        are not limited to simple client types. */
    define public property Name as character no-undo
        get():
            /* Simple default to client type */
            if this-object:Name eq '' or this-object:Name  eq ? then
                this-object:Name = session:client-type.
            
            return this-object:Name.
        end get.
        set.
    
    define static public property Instance as ABLSession no-undo  
        get():
            if not valid-object(Instance) then
                Instance = new ABLSession().
            
            return Instance.
        end get.
        private set.
    
    constructor private ABLSession():
        assign this-object:Id = guid(generate-uuid)
               ActiveSince = now
               SessionProperties = new Map().
        
        CacheStartupProperties().               
    end constructor.
    
    method private void CacheStartupProperties():
        /* cache the value of -param on startup */
        SessionProperties:Put(new String('SESSION:PARAM'), new String(session:parameter)). 
        SessionProperties:Put(new String('SESSION:ICFPARAM'), new String(session:parameter)).
    end method.
    
    /** Returns the first running persistent procedure instance found
        for a given name.
        
        @param character The (relative) path name for a procedure.
        @return handle The handle to that procedure, if any. Unknown value if
                       there's no running instance of that name. */
    method public handle GetFirstRunningProc (input pcName as character):
        define variable hProc as handle no-undo.
        
        hProc = session:first-procedure.
        do while valid-handle(hProc) and hProc:file-name ne pcName:
            hProc = hProc:next-sibling. 
        end.
        
        return hProc.
    end method.

    /** Returns all the running persistent procedure instances found
        for a given name.
        
        @param character The (relative) path name for a procedure.
        @return handle An array of handles to that procedure, if any.
                       If there's no running instance of that name, then
                       the array has an extent of 1 (one) which contains the 
                       unknown value.       */ 
    method public handle extent GetAllRunningProcs (input pcName as character):
        define variable hProc as handle extent no-undo.
        define variable hTemp as handle no-undo.
        define variable cProcs as character no-undo.
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        hTemp = session:first-procedure.
        do while valid-handle(hTemp):         
            if hTemp:file-name eq pcName then
                cProcs = cProcs + ',' + string(hTemp).
            
            hTemp = hTemp:next-sibling. 
        end.
        
        iMax = max((num-entries(cProcs) - 1), 0).
        if iMax eq 0 then
            assign extent(hProc) = 1
                   hProc[1] = ?.
        else        
        do iLoop = 1 to iMax:
            hProc[iLoop] = widget-handle(entry(iLoop, cProcs)).
        end.
        
        return hProc.        
    end method.
    
    /** Resolves a weak reference into an object instance. A weak reference is an integer
        representation of an object reference. This method is analogous to the WIDGET-HANDLE()
        function.
        
        Notes: * Based on http://msdn.microsoft.com/en-us/library/ms404247(v=VS.90).aspx
               * Performance of ResolveWeakReference() will probably suck.
               * An ABL statement "OBJECT-REFERENCE(int)" would entirely replace this method.    
        @param integer A weak reference to an object.
        @return Object The object instance corresponding to that reference. The unknown value/null
                is returned if the referecen cannot be resolved.  */
    method public Object ResolveWeakReference(input piReference as integer):
        define variable oInstance as Object no-undo.
        define variable oReference as Object no-undo.
        
        oInstance = session:first-object.
        do while valid-object(oInstance) and not valid-object(oReference):
            if piReference eq int(oInstance) then
                oReference = oInstance.
            oInstance = oInstance:Next-Sibling.
        end.
        
        return oReference.        
    end method.
    
    /** Returns the first object instance found that is of the type given.
        
        @param character The type name. This can be a class or an interface. 
        @return Object The reference to that type, if any. Unknown value if
                       there's no running instance of that name. */
    method public Object GetFirstClassInstance(input pcName as character):
        define variable oInstance as Object no-undo.
        
        Assert:ArgumentIsValidType(pcName).
        
        oInstance = session:first-object.
        do while valid-object(oInstance) and oInstance:GetClass():IsA(pcName):
            oInstance = oInstance:next-sibling. 
        end.
        
        return oInstance.
    end method.
    
    /** Returns all the object instances found that are of the type given.
        
        @param character The type name. This can be a class or an interface.
        @return Object The reference to that type, if any. Unknown value if
                       there's no running instance of that name. */
    method public Object extent GetAllInstances(input pcName as character):
        define variable oInstance as Object extent no-undo.
        define variable oTemp as Object no-undo.
        define variable oCollection as ICollection no-undo.
        
        Assert:ArgumentIsValidType(pcName).
        
        oCollection = new Collection().
        
        oTemp = session:first-object.
        do while valid-object(oTemp):
            if oTemp:GetClass():IsA(pcName) then
                oCollection:Add(oTemp).
            
            oTemp = oTemp:next-sibling. 
        end.
        
        if oCollection:Size gt 0 then        
            oInstance = oCollection:ToArray().
        else
        do:
            extent(oInstance) = 1.
            oInstance[1] = ?.
        end.
        
        return oInstance.
        finally:
            oCollection:Clear().
        end finally.
    end method.
    
end class.
