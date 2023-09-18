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
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS sObject 
using OpenEdge.PresentationLayer.Interfaces.*.
using OpenEdge.PresentationLayer.Presenter.*.
using OpenEdge.PresentationLayer.Common.*.
using OpenEdge.Core.System.*.
using OpenEdge.Lang.*.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS sObject 
/*------------------------------------------------------------------------

  File:

  Description: from SMART.W - Template for basic ADM2 SmartObject

  Author:
  Created:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{src/adm2/widgetprto.i}
{OpenEdge/PresentationLayer/View/ABLGui/view.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn-First Btn-Prev Btn-Next Btn-Last RECT-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn-First 
     IMAGE-UP FILE "adeicon/first-au":U
     LABEL "&First":L 
     SIZE 4 BY 1.33 TOOLTIP "First".

DEFINE BUTTON Btn-Last 
     IMAGE-UP FILE "adeicon/last-au":U
     LABEL "&Last":L 
     SIZE 4 BY 1.33 TOOLTIP "Last".

DEFINE BUTTON Btn-Next 
     IMAGE-UP FILE "adeicon/next-au":U
     LABEL "&Next":L 
     SIZE 4 BY 1.33 TOOLTIP "Next".

DEFINE BUTTON Btn-Prev 
     IMAGE-UP FILE "adeicon/prev-au":U
     LABEL "&Prev":L 
     SIZE 4 BY 1.33 TOOLTIP "Previous".

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL  GROUP-BOX  ROUNDED 
     SIZE 19.2 BY 1.62.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Btn-First AT ROW 1.33 COL 3.6 WIDGET-ID 16
     Btn-Prev AT ROW 1.33 COL 7.6 WIDGET-ID 22
     Btn-Next AT ROW 1.33 COL 11.6 WIDGET-ID 20
     Btn-Last AT ROW 1.33 COL 15.6 WIDGET-ID 18
     RECT-2 AT ROW 1.24 COL 2 WIDGET-ID 10
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic
   Frames: 1
   Add Fields to: Neither
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW sObject ASSIGN
         HEIGHT             = 1.86
         WIDTH              = 22.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB sObject 
/* ************************* Included-Libraries *********************** */

{src/adm2/visual.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW sObject
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       Btn-First:PRIVATE-DATA IN FRAME F-Main     = 
                "First".

ASSIGN 
       Btn-Last:PRIVATE-DATA IN FRAME F-Main     = 
                "Last".

ASSIGN 
       Btn-Next:PRIVATE-DATA IN FRAME F-Main     = 
                "Next".

ASSIGN 
       Btn-Prev:PRIVATE-DATA IN FRAME F-Main     = 
                "Prev".

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn-First
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-First sObject
ON CHOOSE OF Btn-First IN FRAME F-Main /* First */
or CHOOSE OF Btn-Prev or
CHOOSE OF Btn-Next or 
CHOOSE OF Btn-Last 
DO:
    define variable oButton as EnumMember no-undo.
    define variable oArgs as ToolbarActionEventArgs no-undo.
                    
    case self:private-data:
        when 'First' then oButton = NavigationActionEnum:First.
        when 'Prev' then oButton = NavigationActionEnum:Prev.
        when 'Next' then oButton = NavigationActionEnum:Next.
        when 'Last' then oButton = NavigationActionEnum:Last.
    end case.

        
    oArgs = new ToolbarActionEventArgs(oButton:ToString(), ToolbarActionTypeEnum:Event).
    oArgs:SetArgValue('Action', oButton:ToString(), DataTypeEnum:Integer).
    
    cast(goPresenter, ISelectToolbarAction):SelectToolbarAction (oArgs).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK sObject 


/* ***************************  Main Block  *************************** */

dynamic-function('SetViewName' in target-procedure, 'OpenEdge.PresentationLayer.View.ABLGui.NavigationPanel').

/* If testing in the UIB, initialize the SmartObject. */  
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
  RUN initializeObject.
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI sObject  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialize sObject 
PROCEDURE Initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SetActionState sObject 
PROCEDURE SetActionState :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter poActions as EnumMember extent no-undo.
    define input parameter poStates as EnumMember extent no-undo.
    
    define variable iLoop as integer no-undo.
    
    do iLoop = 1 to extent(poActions) with frame {&FRAME-NAME}:
        case poActions[iLoop]:
            when NavigationActionEnum:First then btn-First:Sensitive = poStates[iLoop] eq ActionStateEnum:Enable.
            when NavigationActionEnum:Prev then btn-Prev:Sensitive  = poStates[iLoop] eq ActionStateEnum:Enable.
            when NavigationActionEnum:Next then btn-Next:Sensitive  = poStates[iLoop] eq ActionStateEnum:Enable.
            when NavigationActionEnum:Last then btn-Last:Sensitive  = poStates[iLoop] eq ActionStateEnum:Enable.
        end case.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

