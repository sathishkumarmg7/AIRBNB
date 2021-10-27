*** Settings ***

Resource          ../Keywords_General/Keywords_General.robot
Resource          ../Android_Objects/BNB_Objects.txt
Resource          ../BNB_Data/Device_and_User_Details.txt
Library           AppiumLibrary
Library           Collections
Library           Process
Library           OperatingSystem
Library           DateTime
Library           String
Library           BuiltIn



*** Keywords ***

LaunchMobileDevice
    [Arguments]    ${aliasName}    ${udid}    ${deviceName}    ${platformName}    ${appPackage}    ${appActivity}
    ...    ${BundleName}    ${NCTimeout}    ${noReset}    ${appPath}    ${accessKey}
    ${NCTimeout}    Convert To Integer    ${NCTimeout}
    Open Application    ${serverUrl}    alias=${aliasName}    udid=${udid}    deviceName=${deviceName}    platformName=${platformName}    appPackage=${appPackage}
    ...    appActivity=${appActivity}    BUNDLE_ID=${BundleName}    newCommandTimeout=${NCTimeout}    noReset=${noReset}    app=${appPath}    accessKey=${accessKey}
    ${apkpath}  ${apk_name} =  Split Path  ${appPath}
    log to console  \n>>>>>>>>>>>Installed and opened "${apk_name}" successfully<<<<<<<<<

LaunchAirbnbApp
     Get_Connected_Device_UDID
     LaunchMobileDevice    ${aliasName}    ${udid}     ${deviceName}    ${platformName}    ${appPackage}
     ...    ${appActivity}    ${BundleName}    ${NCTimeout}    ${noReset}    ${appPath}    ${accessKey}

BNB_Home_page
    FOR    ${i}    IN RANGE    1    6
        sleep  1
        ${BNBHomePage}    Run Keyword And Return Status    page should contain element    ${BNBSearch}    \    # checking profilename is visble or not
        Run Keyword If    ${BNBHomePage} == True   Exit For Loop
        Run Keyword If    ${BNBHomePage} == False   Press Keycode    4
        Run Keyword If    ${i} == 5   Kill_Relaunch_App
    END
Test Suitesetup BNB
     LaunchAirbnbApp
     ${S_Time} =   Get_Suite_Time
     set global variable    ${Suite_Time}   ${S_Time}

Test Suiteteardown BNB
     close all applications

Test Setup BNB
     Capture Screen Recording
     ClearADbLogsFromDevice_Android

Test Teardown BNB
     ${T_Status} =   Get_Test_Status
     set test variable    ${Test_Result}   ${T_Status}
     Run Keyword If    "${Test_Result}"=="APP_CRASH"  log to console     ------------------*****App crashed********
     Run Keyword If    "${Test_Result}"=="APP_CRASH"  fail   Appcrashed
     collectAdbLogs_Android
     BNB_Home_page
     End Screen Recording


LoginWithGoogle
     [Arguments]        ${Fname}    ${Lname}
     sleep    3
     ${SignupPage}    Run Keyword And Return Status    page should contain element    ${Google}    \    # checking profilename is visble or not
     Run Keyword If    ${SignupPage} == True   SelectGoogleAccount
     sleep    5
     ${AddinfoPage}    Run Keyword And Return Status    page should contain element    ${Add_info_Page}    \    # checking profilename is visble or not
     Run Keyword If    ${AddinfoPage} == True   Add_Information    ${Fname}    ${Lname}
     Wait Until Page Contains Element     ${BNBSearch}    30       Failed to signup/Signin


SelectGoogleAccount
     Wait Until Page Contains Element     ${Google}    10       Login or Sign up page failed to open
     click element  ${Google}
     Wait Until Page Contains Element     ${Choose_account_Page}    10    Choose account Page not shown
     Wait Until Page Contains Element     ${Google_Account}    10    No google account found
     @{Accounts}    Get Webelements    ${Google_Account}
     ${len} =   Get Length   ${Accounts}
     FOR    ${i}    IN RANGE  0    ${len}
         ${Name}    Get Text   ${Accounts}[${i}]
         log to console  \n>>>>>>>>>>Account "${Name}" <<<<<<<<<<<<
     END
     click element  ${Accounts}[${len-1}]

Add_Information
    [Arguments]        ${Fname}    ${Lname}
     Wait Until Page Contains Element     ${Add_info_Page}    10    Add info pafe not found
     @{Info}    Get Webelements    ${Info}
     Input Text  ${Info}[0]    ${Fname}
     Input Text  ${Info}[1]    ${Lname}
     click element  ${Info}[2]
     Wait Until Page Contains Element     ${Set_Birthday_Page}    10    Add info pafe not found
     @{Date}    Get Webelements    ${Date_Picker}
     click element  ${Date}[0]
     Input Text  ${Date}[0]    Nov
     click element  ${Date}[1]
     Input Text  ${Date}[1]    23
     click element  ${Date}[2]
     Input Text  ${Date}[2]    1991
     click element  ${OK}
     Wait Until Page Contains Element   ${AGREE}   10       Login or Sign up page failed to open
     click element  ${AGREE}
     sleep    10
     ${CommitPage}    Run Keyword And Return Status    page should contain element    ${Commit}    \    # checking profilename is visble or not
     Run Keyword If    ${CommitPage} == True    click element  ${AGREE}

Validate_Profile_Name
    [Arguments]        ${Profile}
    Wait Until Page Contains Element     ${ProfileOption}    10       App is not in home page
    click element  ${ProfileOption}
    Wait Until Page Contains Element     ${ProfileName}    10       Profile page not opened
    ${Name}    Get Text   ${ProfileName}
    log to console  \n>>>>>>>>>>Profile Name "${Profile}=${Name}" <<<<<<<<<<<<
    Should Be Equal As Strings      ${Profile}     ${Name}   Profile name not matching


BNB_Logout
    Wait Until Page Contains Element     ${ProfileOption}    10       App is not in home page
    click element  ${ProfileOption}
    Wait Until Page Contains Element     ${ProfileName}    10       Profile page not opened
    FOR    ${INDEX}    IN RANGE    5
        Swipe By Percent    50    70    50   40    250
        ${Logout_Present}=   Run Keyword And Return Status   page should contain element  ${BNBLogout}
        Run Keyword If    ${Logout_Present} == True     Exit For Loop
        Run Keyword If    ${Logout_Present} == False    Swipe By Percent    50    70    50   40    250
    END
    click element  ${BNBLogout}
    Wait Until Page Contains Element     ${LogoutOption}    10
    click element  ${LogoutOption}
    Wait Until Page Contains Element     ${LogoutProfile}    10       Failed to Logout

SearchPlaceToStay
     [Arguments]        ${Place}
     Wait Until Page Contains Element     ${BNBSearch}    10       Failed to signup/Signin
     click element  ${BNBSearch}
     Wait Until Page Contains Element     ${Searching}    10
     Input Text  ${Searching}    ${Place}
     Wait Until Page Contains Element     ${First_result}    10
     click element  ${First_result}
      Wait Until Page Contains Element     ${Place_to_Stay}    10
     click element  ${Place_to_Stay}

Select_Duration_of_Stay
      [Arguments]        ${Month_Year}    ${Start_date}    ${End_date}
      ${Month} =   Split String  ${Month_Year}
      ${Mon} =   get substring    ${Month}[0]    0    3
      Wait Until Page Contains Element     ${Calendar}    10
     FOR    ${INDEX}    IN RANGE    20
        ${Month}=   Run Keyword And Return Status   page should contain element  xpath=//*[@text='${Month_Year}']
        Run Keyword If    ${Month} == True     Exit For Loop
        Run Keyword If    ${Month} == False    Swipe By Percent    50    60   50   30    500
     END
     swipe By Percent    50    60   50   30
     Wait Until Page Contains Element     xpath=//*[contains(@content-desc,'${Mon} ${Start_date}')]    10
     click element   xpath=//*[contains(@content-desc,'${Mon} ${Start_date}')]
     FOR    ${INDEX}    IN RANGE    10
        ${Month}=   Run Keyword And Return Status   page should contain element    xpath=//*[contains(@content-desc,'${Mon} 28')]
        Run Keyword If    ${Month} == True     Exit For Loop
        Run Keyword If    ${Month} == False    Swipe By Percent    50    60   50   30    500
     END
     swipe By Percent    50    60   50  30
     Wait Until Page Contains Element    xpath=//*[contains(@content-desc,'${Mon} ${End_date}')]    10
     click element  xpath=//*[contains(@content-desc,'${Mon} ${End_date}')]
     Wait Until Page Contains Element    ${Next}
     click element  ${Next}


Number_of_Persons
      [Arguments]      ${ppl}   ${num}
      Wait Until Page Contains Element     ${Person_count}    10
      @{Cat}    Get Webelements    ${Plus}
      ${Add}=  Run Keyword If    '${ppl}' == 'Adults'    set variable  ${Cat}[0]
     ...        ELSE IF   '${ppl}' == 'Children'   set variable  ${Cat}[1]
     ...        ELSE IF   '${ppl}' == 'Infants'   set variable  ${Cat}[2]
     ...        ELSE    fail    Please give correct Categary type and try again
              FOR    ${i}    IN RANGE    ${num}
                 click element  ${Add}
              END

Search_Coming
      Wait Until Page Contains Element     ${SearchComing}    10
      click element  ${SearchComing}

Validate_Count_of_Stay
      [Arguments]        ${Count}
      Wait Until Page Contains Element     ${ResultStay}    10
      ${Name}    Get Text   ${ResultStay}
      log to console  \n>>>>>>>>>>Stay count "${Name}" <<<<<<<<<<<
      ${file} =   Split String  ${Name}
      should be equal    ${Count}    ${file}[0]   Not matching with expetecd number of stay

Save_To_Wishlist
     Wait Until Page Contains Element     ${SaveToWishlist}    10
     swipe By Percent    50    60   50  30    250
#     ${Place}    Get Text   ${Wishlistplace}
     click element  ${SaveToWishlist}
     sleep    2
     ${Month}=   Run Keyword And Return Status   page should contain element  ${CreateNewwishlist}
     Run Keyword If    ${Month} == True     click element  ${CreateNewwishlist}
     Wait Until Page Contains Element     ${WishlistnamePage}    10
     ${Name}    Get Text   ${Wishlistname}
     click element  ${BNBCreate}
     [Return]     ${Name}


Go_to_wishlists
     Wait Until Page Contains Element     ${Wishlists}    10
     click element  ${Wishlists}

Validate_wishlisted_places
      [Arguments]    ${Names}
     Wait Until Page Contains Element     ${Wishlistedname}    10     No places wish listed
     ${name1}   get text   ${Wishlistedname}
     should be equal as strings     ${Names}    ${name1}     Item not wishlisted

