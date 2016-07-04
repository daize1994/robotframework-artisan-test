*** Settings ***
Library           ArtisanCustomLibrary
Resource          ../common_keywords.txt    # 公用用户关键字
Resource          demo_data.txt    # demo账号造数据专用json

*** Test Cases ***
get_crashTotal_current-android-demo
    [Tags]    demo
    ${init_issueCrashReporter_list}    get_CrashTotal_current    ${android_app_id}    ${query_ip}
    Set Suite Variable    ${init_issueCrashReporter_list}
    log to console    ${init_issueCrashReporter_list}    no_newline=true

send_android_java_crash-android-demo
    [Tags]    demo
    #把所有的crash数据建立列表，若有改动，需要修改关键字“get user trace”的源码
    ${demoJsonList}=    create list    ${mainactivity_java03.json}    ${mainactivity_java04.json}    ${mainactivity_java05.json}    ${Activity1_java01.json}
    ...    ${Activity2_java06.json}    ${Activity2_java07.json}
    #每次随机发送崩溃个数
    ${counts}=    Evaluate    random.randint(1,3)    modules=random, sys
    Log To Console    random_crash_times is:${counts}
    Set Suite Variable    ${counts}
    : FOR    ${i}    IN RANGE    ${counts}
    \    #随机一个crash类型
    \    ${index}=    Evaluate    random.randint(0,5)    modules=random, sys
    \    #随机一个device_id
    \    ${device_id}    Evaluate    random.randint(1999980,2000000)    modules=random, sys
    \    ${user_trace}    get User Trace    android    ${index}    #修改随机crash的user_trace值
    \    #把构造的user_trace替换
    \    edit json    ${demoJsonList[${index}]}    user_trace=${user_trace}    device_id=${device_id}
    \    post_sdk_event    ${demoJsonList[${index}]}    ${sdk_ip}
    sleep    10

get_crashTotal_after_send_sdkEvent_and_assert-android-demo
    [Tags]    demo
    #调用自定义关键字
    ${after_issueCrashReporter_list}    get_CrashTotal_current    ${android_app_id}    ${query_ip}
    log to console    AfterSend:[Total issues,Total crash,reporter]=${after_issueCrashReporter_list}    no_newline=true
    #断言，依次比较0,1,2位置的数据
    #Should Be Equal As Integers    ${after_issueCrashReporter_list[0]}    ${init_issueCrashReporter_list[0]}
    Should Be Equal As Integers    ${after_issueCrashReporter_list[1]}    ${init_issueCrashReporter_list[1]+${counts}}
    #Should Be Equal As Integers    ${after_issueCrashReporter_list[2]}    ${init_issueCrashReporter_list[2]}

get_crashTotal_current-ios-demo
    [Tags]    ios-demo
    ${init_issueCrashReporter_list}    get_CrashTotal_current    ${ios_app_id}    ${query_ip}
    Set Suite Variable    ${init_issueCrashReporter_list}
    log to console    ${init_issueCrashReporter_list}    no_newline=true

send_ios_crash-demo
    [Tags]    ios-demo
    #获取设备信息字典中的device_model列表
    ${ios_device_list}    Get Dictionary Keys    ${ios_device_model_os_version}
    #每次随机发送崩溃个数
    ${counts}=    Evaluate    random.randint(1,3)    modules=random, sys
    Log To Console    random_crash_counts is:${counts}
    Set Suite Variable    ${counts}
    : FOR    ${i}    IN RANGE    ${counts}
    \    #随机一个crash类型待编辑和发送
    \    ${crash_index}=    Evaluate    random.randint(0,3)    modules=random, sys
    \    Log To Console    random_json file is:@{ios_crash}[${crash_index}]
    \    #随机一个设备型号和其对应的os_version
    \    ${device_list_index}=    Evaluate    random.randint(0,10)    modules=random, sys
    \    Log To Console    random device model is:${ios_device_list[${device_list_index}]}
    \    ${os_version}=    Get From Dictionary    ${ios_device_model_os_version}    ${ios_device_list[${device_list_index}]}
    \    #随机tbid后12位
    \    ${tbid}    Evaluate    random.randint(199999999980,200000000000)    modules=random, sys
    \    log    ${half_tbid}${tbid}    #组装后的tbid
    \    ${user_trace}    get User Trace    ios    #修改随机crash的user_trace值
    \    #把构造的user_trace和设备信息替换
    \    edit json    @{ios_crash}[${crash_index}]    user_trace=${user_trace}    tbid=${half_tbid}${tbid}    device_model=${ios_device_list[${device_list_index}]}    os_version=${os_version}
    \    post json    @{ios_crash}[${crash_index}]    ${sdk_ip}
    sleep    10

get_crashTotal_after_send_sdkEvent_and_assert-ios-demo
    [Tags]    ios-demo
    [Timeout]
    #调用自定义关键字
    ${after_issueCrashReporter_list}    get_CrashTotal_current    ${ios_app_id}    ${query_ip}
    log to console    AfterSend:[Total issues,Total crash,reporter]=${after_issueCrashReporter_list}    no_newline=true
    #断言，依次比较0,1,2位置的数据
    #Should Be Equal As Integers    ${after_issueCrashReporter_list[0]}    ${init_issueCrashReporter_list[0]}
    Should Be Equal As Integers    ${after_issueCrashReporter_list[1]}    ${init_issueCrashReporter_list[1]+${counts}}
    #Should Be Equal As Integers    ${after_issueCrashReporter_list[2]}    ${init_issueCrashReporter_list[2]}
