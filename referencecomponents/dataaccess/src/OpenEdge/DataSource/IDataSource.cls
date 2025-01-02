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
    File        : IDataSource
    Purpose     : General Datasource interface.
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Wed Feb 10 01:30:45 EST 2010
    Notes       : * A DataSource can only service one message/request at a time
  ---------------------------------------------------------------------- */
using OpenEdge.DataSource.IDataSource.
using OpenEdge.DataSource.DataSourceEventArgs.
using OpenEdge.DataAccess.IDataAccess.  

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.FillModeEnum.
using Progress.Lang.Object.

interface OpenEdge.DataSource.IDataSource:
    /** The default Page or batch size for this datasource. Can be overridden by the TableRequest in Prepare(). */ 
    define property PageSize as integer no-undo get. set.
    
    /** The default FillMode for fetch requests. Can be overridden by the TableRequest in Prepare(). */
    define property FillMode as FillModeEnum no-undo get. set.
    
    /** DataSource Fetch/Fill events. These map to ProDataSet callbacks, although the events below are only fired
       in cases where PerformFetch() is called. This is typically not the case for ProDataSets, since the PDS:Fill()
       method will be called from the DataAccess, rather than the Datasource. 
       */
    define public event BeforeFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event BeforeRowFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterRowFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    
    /** DataSource Save/Commit events */
    define public event BeforeSaveTransaction signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event BeforeSave            signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterSave             signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterSaveTransaction  signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    
    /** The SetDataTarget() method is called by the DataAccess object, to specify 
        the target for the DataSource's operations (usually the fill/fetch). 
        
        This data is formatted per the MessageDataFormat above; and is stored 
        in the message as either LONGCHAR, MEMPTR, HANDLE or P.L.O.
        
        The method performs the conversion from longchar to one of the other types,
        using ABL methods like COPY-LOB or WIDGET-HANDLE() or the 
        OpenEdge.Lang.WeakReference object.
        
        @param lonchar Stores a handle, values or memptr contents 
        @param DataFormatEnum The format of the data target value
        @param DataTypeEnum The data type of the value, for conversion.     */
    method public void SetDataTarget(input pcData as longchar,
                                     input poDataTargetFormat as DataFormatEnum,
                                     input poDataTargetType as DataTypeEnum).
    
    /** This SetDataTarget override is provided since the bulk of datatargets in ABL
        will be buffers (possibly datasets).
        
        An exception will be thrown if the handle has a type of anything other than 
        'buffer' or 'dataset'.
        
        @param handle A buffer or dataset handle that is the data target. */
    method public void SetDataTarget(input phData as handle).

    /** Clears the Datatarget and associated properties */
    method public void ClearDataTarget().

    /** A helper for retrieving the data target in longchar form again. Performs
        the inverse of the SetDataTarget() method; this is basically just a STRING()
        of the value or reference.

        @return longchar The value of the datatarget property (not necessarily its contents). */
    method public longchar GetDataTarget().

    /** Prepare with query, batchsize and more.
        
        @param ServiceMessageActionEnum The action that we're preparing the datasource for. 
               We may have different actions based on whether this is a Fetch or a Save.
        @param ITableRequest Parameters for the fetch (query modifications, page size etc).
        @param IDataAccess The DataAccess object making this request. The DAO can be used to
               resolve table- or field name mappings (from the Business Entity names to the 
               Data Source names. */
    method public void Prepare(input poAction as ServiceMessageActionEnum,
                               input poRequest as ITableRequest,
                               input poDAO as IDataAccess).
    
    /** Perform fetch: populate the previously-passed buffer from the
        physical data store.
        
        The caller needs to call GetData() afterwards if they want 
        any additional information about the fetch call (stuff that's
        in ITableContext). */
    method public void FetchData().    
    
    /** Retrieves the results of a fetch 
        @return ITableResponse The response to the fetch operation. */
    method public ITableResponse GetData().
    
    /** Saves all data in the DataTarget
        
        @return ITableResponse The response to the save operation. */
    method public ITableResponse SaveData().    
    
end interface.
