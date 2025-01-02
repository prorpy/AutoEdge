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
/*------------------------------------------------------------------------
    File        : TaskDetailForm
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Nov 24 11:43:26 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Lang.BPM.Task.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.Assert.

using Progress.Windows.Form.
using Progress.Lang.Error. 

class AutoEdge.Factory.Client.Order.PresentationLayer.TaskDetailForm inherits Form: 
    
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable savvionTaskDetailUC1 as AutoEdge.Factory.Client.Common.PresentationLayer.SavvionTaskDetailUC no-undo.

    define public property CurrentTask as Task no-undo get. private set.
    define protected property BpmServer as IBizLogicAPI no-undo get. set.
    
    constructor public TaskDetailForm(input poBpmServer as IBizLogicAPI,
                                      input poCurrentTask as Task):
        this-object().
        
        Assert:ArgumentNotNull(poCurrentTask, 'Current task').
        Assert:ArgumentNotNull(poBpmServer, 'BPM Server').
        
        assign BpmServer = poBpmServer
               CurrentTask = poCurrentTask.
        savvionTaskDetailUC1:SetTask(CurrentTask, BpmServer).
        
        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
    end constructor.
        
    constructor public TaskDetailForm (  ):
        super().
        InitializeComponent().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end constructor.

    method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:savvionTaskDetailUC1 = new AutoEdge.Factory.Client.Common.PresentationLayer.SavvionTaskDetailUC().
        this-object:SuspendLayout().
        /*  */
        /* savvionTaskDetailUC1 */
        /*  */
        this-object:savvionTaskDetailUC1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:savvionTaskDetailUC1:Location = new System.Drawing.Point(0, 0).
        this-object:savvionTaskDetailUC1:Name = "savvionTaskDetailUC1".
        this-object:savvionTaskDetailUC1:Size = new System.Drawing.Size(595, 344).
        this-object:savvionTaskDetailUC1:TabIndex = 1.
        /*  */
        /* TaskDetailForm */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(595, 344).
        this-object:Controls:Add(this-object:savvionTaskDetailUC1).
        this-object:Name = "TaskDetailForm".
        this-object:Text = "TaskDetailForm".
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    destructor public TaskDetailForm ( ):

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.
    
end class.
