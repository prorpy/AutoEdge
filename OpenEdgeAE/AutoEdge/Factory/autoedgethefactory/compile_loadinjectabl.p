/*------------------------------------------------------------------------
    File        : compile_loadinjectabl.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Jan 17 15:06:27 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
{routinelevel.i}



/* ***************************  Main Block  *************************** */
define variable pcFilePattern as character no-undo.

define variable iLoop as integer no-undo.
define variable iMax as integer no-undo.
define variable cOriginalExtension as character no-undo.
define variable cFileBase as character no-undo.
define variable cFolderBase as character no-undo.
define variable cFile as character no-undo.
define variable cPWD as character no-undo.
define variable cFolder as character no-undo.
define variable lHasSrc as logical no-undo.
define variable cLastEntry as character no-undo.

pcFilePattern = 'load_injectabl_modules.p'.

/* Resolve the working folder into something meaningful, since
   SEARCH() is significantly faster with a fully-qualified path  */
file-info:file-name = '.'.
cPWD = file-info:full-pathname. 

iMax = num-entries(propath).
do iLoop = 1 to iMax on error undo, throw:
    cFolder = entry(iLoop, propath).
/*    cFolder = replace(entry(iLoop, propath), '~\', '~/').*/
    
    if cFolder begins '.' and
       /* don't mess up relative pathing */
       not cFolder begins '..' then
    do:
        if cFolder eq '.' then
            cFolder = cPWD.
        else
            cFolder = cPWD + substring(cFolder, 2).
    end.
    
    cLastEntry = entry(num-entries(cFolder, '/'), cFolder, '/').
    
    if cLastEntry eq 'bin' then
        next.

    lHasSrc = (cLastEntry eq 'src').
    
    /* Always looks for .R. We can write a specialised resolver here if we want 
       to get fancy and look for .r and .p */
    assign cFolderBase = right-trim(cFolder, '/') + '/' + pcFilePattern
           cFile = search(cFolderBase).
    
    if cFile ne ? then
    do:
        if lHasSrc then
            compile value(cFile) save into value(replace(cFile, 'src', 'bin')).
        else
            compile value(cFile) save.
    end.
end.
