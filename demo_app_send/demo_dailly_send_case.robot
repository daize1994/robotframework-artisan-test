*** Settings ***
Library           ArtisanCustomLibrary
Resource          ../common_keywords.txt    # 公用用户关键字
Resource          demo_data.txt    # demo账号造数据专用json

*** Test Cases ***
随机发送次数
    [Tags]    android-demo    ios-demo
    # 每次随机发送崩溃个数
    ${counts}=    Evaluate    random.randint(1,3)    modules=random, sys
    Log To Console    \nrandom_send_times is:${counts}
    Set Suite Variable    ${counts}

get_crashTotal_current_android_demo
    [Tags]    android-demo
    ${init_issueCrashReporter_list}    get_CrashTotal_current    ${android_app_id}    ${query_ip}
    Set Suite Variable    ${init_issueCrashReporter_list}
    log to console    BeforeSend:Total crash and exception = ${init_issueCrashReporter_list}    no_newline=true

send_android_session_demo
    [Tags]    android-demo
    : FOR    ${i}    IN RANGE    ${counts}
    \    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间精确到毫秒
    \    ${date}=    Convert To Integer    ${date}
    \    ${device_id}=    Convert To String    ${date}
    \    editJson    ${android_session.json}    app_key=${android_app_id}    date=${date}    device_id=${device_id}
    \    post_sdk_event    ${android_session.json}    ${sdk_ip}
    sleep    2

send_android_crash_demo
    [Tags]    android-demo
    : FOR    ${i}    IN RANGE    ${counts}
    \    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间精确到毫秒
    \    ${date}=    Convert To Integer    ${date}
    \    # 随机一个crash类型,更改长度需要同步修改@{android_crash_list}参数的长度
    \    ${crash_index}=    Evaluate    random.randint(0,7)    modules=random, sys
    \    log to console    随机的crash为:@{android_crash_list}[${crash_index}]
    \    # 随机一个device_id
    \    ${device_id}    Evaluate    random.randint(1999990,2000000)    modules=random, sys
    \    ${user_trace}    getUserTrace    android    #修改随机crash的user_trace值
    \    edit json    @{android_crash_list}[${crash_index}]    app_key=${android_app_id}    user_trace=${user_trace}    device_id=${device_id}    date=${date}
    \    editjsonfromdict    @{android_crash_list}[${crash_index}]    @{device_list}[${crash_index}]
    \    post_sdk_event     @{android_crash_list}[${crash_index}]    ${sdk_ip}
    sleep    10

get_crashTotal_after_send_sdkEvent_and_assert_android_demo
    [Tags]    android-demo
    #调用自定义关键字
    ${after_issueCrashReporter_list}    get_CrashTotal_current    ${android_app_id}    ${query_ip}
    log to console    AfterSend:Total crash and exception = ${after_issueCrashReporter_list}    no_newline=true
    #断言，依次比较0,1,2位置的数据
    Should Be Equal As Integers    ${after_issueCrashReporter_list}    ${init_issueCrashReporter_list+${counts}}

get_crashTotal_current_ios_demo
    [Tags]    ios-demo
    ${init_issueCrashReporter_list}    get_CrashTotal_current    ${ios_app_id}    ${query_ip}
    Set Suite Variable    ${init_issueCrashReporter_list}
    log to console    ${init_issueCrashReporter_list}    no_newline=true

send_ios_session
    [Tags]    ios-demo
    : FOR    ${i}    IN RANGE    ${counts}
    \    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间精确到毫秒
    \    ${date}=    Convert To Integer    ${date}
    \    ${tbid}=    Convert To String    ${date}
    \    editJson    ${ios_session.json}    app_key=${ios_app_id}    date=${date}    tbid=${tbid}
    \    postjson    ${ios_session.json}    ${sdk_ip}
    sleep    2

send_ios_crash_demo
    [Tags]    ios-demo
    #获取设备信息字典中的device_model列表
    ${ios_device_list}    Get Dictionary Keys    ${ios_device_model_os_version}
    #每次随机发送崩溃个数
    #${counts}=    Evaluate    random.randint(1,3)    modules=random, sys
    #Set Suite Variable    ${counts}
    #Log To Console    \nrandom_crash_counts is:${counts}
    : FOR    ${i}    IN RANGE    ${counts}
    \    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    \    ${date}=    Evaluate    ${date}*1000    # 被测系统的时间精确到毫秒
    \    ${date}=    Convert To Integer    ${date}
    \    #随机一个crash类型待编辑和发送
    \    ${crash_index}=    Evaluate    random.randint(0,2)    modules=random, sys
    \    Log To Console    \nrandom_json file is:@{ios_crash_list}[${crash_index}]
    \    #随机一个设备型号和其对应的os_version
    \    ${device_list_index}=    Evaluate    random.randint(0,10)    modules=random, sys
    \    Log To Console    \nrandom device model is:${ios_device_list[${device_list_index}]}
    \    ${os_version}=    Get From Dictionary    ${ios_device_model_os_version}    ${ios_device_list[${device_list_index}]}
    \    #随机tbid后12位
    \    ${tbid}    Evaluate    random.randint(199999999990,200000000000)    modules=random, sys
    #\    log    ${half_tbid}${tbid}    #组装后的tbid
    \    ${user_trace}    get User Trace    ios    #修改随机crash的user_trace值
    \    #把构造的user_trace和设备信息替换
    \    edit json    @{ios_crash_list}[${crash_index}]    app_key=${ios_app_id}    user_trace=${user_trace}    date=${date}    tbid=${half_tbid}${tbid}    device_model=${ios_device_list[${device_list_index}]}    os_version=${os_version}
    \    postjson    @{ios_crash_list}[${crash_index}]    ${sdk_ip}
    sleep    10

get_crashTotal_after_send_sdkEvent_and_assert_ios_demo
    [Tags]    ios-demo
    [Timeout]
    #调用自定义关键字
    ${after_issueCrashReporter_list}    get_CrashTotal_current    ${ios_app_id}    ${query_ip}
    log to console    AfterSend:Total crash and exception = ${after_issueCrashReporter_list}    no_newline=true
    #断言，依次比较0,1,2位置的数据
    Should Be Equal As Integers    ${after_issueCrashReporter_list}    ${init_issueCrashReporter_list+${counts}}
