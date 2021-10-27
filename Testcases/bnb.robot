*** Settings ***

Suite Setup       Test Suitesetup BNB
#Suite Teardown    Test Suiteteardown BNB
Test Setup        Test Setup BNB
Test Teardown     Test Teardown BNB

Resource          ../Keywords_Android/Keywords_Android.robot


*** Test Cases ***

Testcase1_LoginWithGoogle
    [Tags]    BNB
    LoginWithGoogle    Sathish    MG
    Validate_Profile_Name    Sathish
#    BNB_Logout

Testcase2_StayInBangalore
    [Tags]    BNB
    LoginWithGoogle    Sathish    MG
    SearchPlaceToStay    Bangalore
    Select_Duration_of_Stay    March 2022    5    7
    Number_of_Persons    Adults    2
    Search_Coming
    Validate_Count_of_Stay    300+

Testcase3_Validate_wishlisted_place
    [Tags]    BNB
    LoginWithGoogle    Sathish    MG
    SearchPlaceToStay    Bangalore
    Select_Duration_of_Stay    March 2022    5    7
    Number_of_Persons    Children    2
    Search_Coming
    Validate_Count_of_Stay    300+
    ${Name}     Save_To_Wishlist
    Go_to_wishlists
    Validate_wishlisted_places     ${Name}
