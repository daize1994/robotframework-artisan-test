*** Settings ***
Library    ArtisanCustomLibrary
#Library    pabot.PabotLib
#Library    Remote   45.58.54.95:1000
Resource   local_test_data.txt   # 接口测试专用数据
Resource   ../common_keywords.txt    # 公用用户关键字

*** Test Cases ***
send_android_session_local
    [Tags]    android_crash
    : FOR    ${I}    IN RANGE    1
    \   ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \   ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    \   ${date}=    Convert To Integer    ${date}
    \   editJson    ${android_normal.json}    date=${date}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    os_name=android
    \   ...    device_id=${device_id}
    # \    send_many_crash    1
    \    post_sdk_event    ${android_normal.json}    ${sdk_ip}
    #sleep    1

send_android_crash_local
    [Tags]    android_crash
    ${start_time}=    Get Time    epoch    UTC+8 hour
    log to console    开始于:${start_time}
    : FOR    ${I}    IN RANGE    1
    \   ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \   ${time_spend}=    Evaluate    ${date}-${start_time}
    \   log to console     已经过了:${time_spend}秒
    \   run keyword if    ${time_spend}>50400    sleep    120
    \   ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    \   ${date}=    Convert To Integer    ${date}
    \   editJson    ${android_java_crash.json}    date=${date}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    device_id=${device_id}
    \   ...    user_id=aacc    event_code=java_crash    device_model=wwsdw    os_version=5.1
    \    post_sdk_event    ${android_java_crash.json}    ${sdk_ip}
    sleep    3

send_ios_session_local
    [Tags]    ios_crash
    : FOR    ${I}    IN RANGE    1
    \    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    \    ${date}=    Convert To Integer    ${date}
    \    editJson    ${ios_normal.json}    date=${date}    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    os_name=ios
    \    ...    tbid=6E9ED81E-AD7A-4584${device_id}
    \    post_sdk_event    ${ios_normal.json}    ${sdk_ip}
    sleep    3

send_ios_crash_local
    [Tags]    ios_crash
    : FOR    ${I}    IN RANGE    1
    \    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    \    ${date}=    Convert To Integer    ${date}
    \    editJson    ${ios_crash.json}    date=${date}    event_code=ios_crash    app_key=${app_id}    app_version_name=${ver_name}    app_version_code=${ver_code}    tbid=${device_id}
    \    post_sdk_event    ${ios_crash.json}    ${sdk_ip}
    sleep    3

