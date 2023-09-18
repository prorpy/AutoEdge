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
    File        : DataSourceEventArgs
    Purpose     : Event Args for Datasource events (fill, save, etc).
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Aug 27 16:52:41 EDT 2010
    Notes       : * These event args are unlikely to be used for cases
                    where built-in ProDataSet callbacks are used, but the 
                    DataSource does support manual fill/fetch operations too.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.DataSourceEventEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.Core.System.EventArgs.

class OpenEdge.DataSource.DataSourceEventArgs inherits EventArgs:
    
    /** The data format type fpr the DataTarget data.  */
    define public property DataTargetFormat as DataFormatEnum no-undo get. set.
    
    /** The data type of the data stored in the DataTarget */
    define public property DataTargetType as DataTypeEnum no-undo get. set.
    
    /** Handle of the buffer/dataset being operated on, and to which the even applies. */
    define public property DataTarget as longchar no-undo get. set.
    
    /** The event that caused this argument to be fired. */    
    define public property DataSourceEvent as DataSourceEventEnum no-undo get. private set.
    
    /** The row key used to identify the row being operated on in the data target. */
    define public property RowKey as character extent no-undo get. set.
    
    constructor public DataSourceEventArgs(input poEvent as DataSourceEventEnum):
        super().
        
        assign DataSourceEvent = poEvent.
    end constructor.
            
    constructor public DataSourceEventArgs(input poEvent as DataSourceEventEnum,
                                           input poFormat as DataFormatEnum,
                                           input poDataType as DataTypeEnum,
                                           input pcData as longchar,
                                           input pcRowKey as character extent):
        super().        
        assign DataSourceEvent = poEvent
               DataTargetFormat = poFormat
               DataTargetType = poDataType
               DataTarget = pcData
               RowKey = pcRowKey.
    end constructor.

end class.
