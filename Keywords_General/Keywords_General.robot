*** Settings ***
Library           AppiumLibrary
Library           Collections
Library           Process
Library           OperatingSystem
Library           DateTime
Library           String
Library           Screenshot
Library           BuiltIn
Library           random
Library           os



*** Keywords ***

Get_Connected_Device_UDID
    ${result} =     Run     adb devices
    Log To Console  ${result}
    @{Lines} =  Split To Lines  ${result}
    @{Device_name} =  Split String  ${Lines}[1]
    Log To Console  Taking "${Device_name}[0]" as UDID for Device Desired capabilities >>>>>>>>>>
    set global variable    ${udid}   ${Device_name}[0]

#Gets the time of suite start
Get_Suite_Time
   ${Suite_Time} =    Get Current Date   increment=00:00:00  result_format=%Y-%m-%d__%H-%M
   log to console  \n>>>>>Test Execution started at ${Suite_Time}<<<<<
   [Return]  ${Suite_Time}

#Gets the status of current test after execution
Get_Test_Status
   ${Crash}   Validate_Value_in_Logs   beginning of crash
   ${Test_Result} =   Run keyword if    ${Crash}==True   Set Variable   APP_CRASH
   ...        ELSE    set variable   ${TEST STATUS}
   [Return]  ${Test_Result}


Validate_Value_in_Logs    [Arguments]  ${Value}
    ${handle} =    Process.Start Process
    ...    adb
    ...    logcat
    ...    >${EXECDIR}\\BNB_Output\\logs.txt
    ...    status-window
    ...    shell=yes
    ${result}=    Process.Wait For Process
    ...    handle=${handle}
    ...    on_timeout=terminate
    ...    timeout=1 s
   ${FILE_CONTENT}=   Get File    ${EXECDIR}\\BNB_Output\\logs.txt  'UTF-8'    ignore
       ${contains} =    Run Keyword And Return Status    Should Contain    ${FILE_CONTENT}   ${Value}
       log to console  >>>>>'${Value}' is found in logs = ${contains} <<<<<
       [Return]  ${contains}


Change_ScreenShot_Directory
     set screenshot directory   ${EXECDIR}/Screenshots


Capture Screen Recording
    wait until keyword succeeds  10 sec    0.1 sec   Start Screen Recording   forceRestart=true  bitRate=20000000   bugReport=true


End Screen Recording
    Run Keyword And Ignore Error    Remove Screen Recording If Pass


Remove Screen Recording If Pass
    ${SuiteName} =   Set Variable  BNB
    ${Tese_Time} =  Get Current Date  increment=00:00:00  result_format=%Y-%m-%d__%H-%M-%S
    ${apkpath}  ${apk_name} =  Split Path  ${appPath}
    ${File_Name} =   Set Variable    ${Test_Result}_${TEST NAME}_${Tese_Time}
    ${DestPath} =   Set Variable  ${EXECDIR}\\BNB_Output\\${apk_name}_${SuiteName}_${Suite_Time}
    ${SourcePath} =  Set Variable  ${EXECDIR}\\${File_Name}.mp4
    Stop Screen Recording    filename=${File_Name}

    move file     ${SourcePath}    ${DestPath}\\                                                                        #   Moving the recorded video to user defined path for both pass and failed cases
    log to console  \n>>>>>Saved Video in "${DestPath}\\${File_Name}.mp4" successfully<<<<



collectAdbLogs_Android
#   Run Keyword If  '${LOGS_FOR}' == 'PASS'  log to console  \LOGS for passed testcsse
    ${SuiteName} =   Set Variable  BNB
    ${Tese_Time} =  Get Current Date  increment=00:00:00  result_format=%Y-%m-%d__%H-%M-%S
    ${apkpath}  ${apk_name} =  Split Path  ${appPath}
    ${FileName} =  Set Variable    ${Test_Result}_${TEST NAME}_${Tese_Time}
#    ${FilePath} =  Set Variable  ${EXECDIR}\\BNB_Output\\${apk_name}_${Suite_Time}
    ${FilePath} =  Set Variable  ${EXECDIR}\\BNB_Output\\${apk_name}_${SuiteName}_${Suite_Time}
    create file    ${FilePath}\\${FileName}.txt
    ${handle} =    Process.Start Process
    ...    adb
    ...    logcat
    ...    >${FilePath}\\${FileName}.txt
    ...    status-window
    ...    shell=yes
    ${result}=    Process.Wait For Process
    ...    handle=${handle}
    ...    on_timeout=terminate
    ...    timeout=1 s
    log to console  Collected adblogs in ${FilePath}\\${FileName}.txt successfully



#Clears the adb logs in device
ClearADbLogsFromDevice_Android
    ${handle} =    Process.Start Process
    ...    adb
    ...    logcat
    ...    -c
    ...    status-window
    ...    shell=yes
    ${result}=    Process.Wait For Process
    ...    handle=${handle}
    ...    on_timeout=terminate
    ...    timeout=1 s
    log to console  \n>>>>>Cleared adblogs successfully<<<<<


Kill_Relaunch_App
    quit_application
    launch_application
    log to console  >>>>>Killed and relaunched the app successfully<<<<<
