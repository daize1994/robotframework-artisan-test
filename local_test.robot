*** Settings ***
Library           ArtisanCustomLibrary
Resource          server_api_test_data.txt   # 接口测试专用数据
Resource          common_keywords.txt    # 公用用户关键字

*** Test Cases ***
send_android_session_local
    [Tags]    android_crash
    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    editJson    ${android_normal.json}    date=${date}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    os_name=android
    ...    device_id=201605161211110000
    : FOR    ${I}    IN RANGE    1
    \    post_sdk_event    ${android_normal.json}    ${sdk_ip}
    sleep    3

send_ios_session_local
    [Tags]    ios_crash
    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    editJson    ${ios_normal.json}    date=${date}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    os_name=ios
    ...    tbid=6E9ED81E-AD7A-4584-9E26-7D75B8C7AA1191
    : FOR    ${I}    IN RANGE    1
    \    post_sdk_event    ${ios_normal.json}    ${sdk_ip}
    sleep    3

send_android_crash_local
    [Tags]    android_crash
    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    editJson    ${android_java_crash.json}    date=${date}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    channel_id=tbttb    device_id=20160516111    custom_log=sewdwde
    : FOR    ${I}    IN RANGE    1
    \    post_sdk_event    ${android_java_crash.json}    ${sdk_ip}
    sleep    3

send_ios_crash_local
    [Tags]    ios_crash
    editJson    ${ios_crash.json}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    tbid=6E9ED81E-AD7A-4584-9E26-7D75B8C7AA11
    : FOR    ${I}    IN RANGE    1
    \    post_sdk_event    ${ios_crash.json}    ${sdk_ip}
    sleep    3
