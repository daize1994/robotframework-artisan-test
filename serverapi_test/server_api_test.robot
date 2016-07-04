*** Settings ***
Library           ArtisanCustomLibrary
Resource          server_api_test_data.txt    # 接口测试专用数据
Resource          ../common_keywords.txt    # 公用用户关键字

*** Variables ***

*** Test Cases ***
get_crashTotal_current
    [Tags]    sdk2influxDB    query
    #查询当前崩溃总数
    ${init_issueCrashReporter_list}    get_CrashTotal_current    ${app_id}    ${query_ip}
    Set Suite Variable    ${init_issueCrashReporter_list}
    log to console    Current:[Total issues,Total crash,reporter]=${init_issueCrashReporter_list}    no_newline=true

send_android_session
    editJson    ${android_normal.json}    app_key=${app_id}
    post_sdk_event    ${android_normal.json}    ${sdk_ip}
    sleep    3

send_android_java_crash
    [Tags]    sdk2influxDB
    ${line}    Evaluate    random.randint(190,200)    modules=random, sys
    #把行号写到crash_stack
    ${crash_stack}    randomStack    ${line}
    #随机一个device_id
    ${device_id}    Evaluate    random.randint(1999990,2000000)    modules=random, sys
    ${device_id}    Convert To String    ${device_id}
    editJson    ${android_java_crash.json}    app_key=${app_id}    device_id=${device_id}    crash_stack=${crash_stack}
    : FOR    ${I}    IN RANGE    1
    \    post_sdk_event    ${android_java_crash.json}    ${sdk_ip}
    sleep    10

send_android_native_crash
    editJson    ${android_java_crash.json}    app_key=${app_id}
    post_sdk_event    ${android_native.json}    ${sdk_ip}
    sleep    5

send_android_mapping_crash
    editJson    ${android_java_crash.json}    app_key=${app_id}
    post_sdk_event    ${android_mapping_crash.json}    ${sdk_ip}
    sleep    5

get_crashTotal_after_send_sdkEvent_and_assert
    [Tags]    sdk2influxDB
    #调用自定义关键字，查询目前崩溃总数
    ${after_issueCrashReporter_list}    get_CrashTotal_current    ${app_id}    ${query_ip}
    log to console    AfterSend:[Total issues,Total crash,reporter]=${after_issueCrashReporter_list}    no_newline=true
    #断言，依次比较0,1,2位置的数据
    #Should Be Equal As Integers    ${after_issueCrashReporter_list[0]}    ${init_issueCrashReporter_list[0]}    error:assert_issueTotal-failed    #因为每次会随机新增问题数，所以这里无法确定是否相等或不等，故不作判断
    Should Be Equal As Integers    ${after_issueCrashReporter_list[1]}    ${init_issueCrashReporter_list[1]+1}    error:assert_crashtotal-failed
    #Should Be Equal As Integers    ${after_issueCrashReporter_list[2]}    ${init_issueCrashReporter_list[2]}    error:assert_reporter-failed    #因为每次会随机新增影响人数，所以这里无法确定是否相等或不等，故不作判断

get_issues_list_current
    [Tags]    query
    #查询某页的issue列表
    get_issues_list_current    ${app_id}    ${query_ip}    1

get_issueTimeRange_current
    [Tags]    query
    #查询某issue的最早和最近时间
    get_issueTimeRange_current    ${app_id}    ${query_ip}

get_crashReporterPerDay_current
    [Tags]    query
    #查询每日崩溃数和影响人数
    get_crashReporterPerDay_current    ${app_id}    ${query_ip}

send_ios_crash
    ${user_trace}    getUserTrace    ios
    editJson    ${ios_crash_armv7s.json}    free_ram=131072    user_trace=${user_trace}
    sleep    5
    postjson    ${ios_crash_armv7s.json}    ${sdk_ip}

cretae_verison
    ${random_ver_code}    Evaluate    random.randint(1,200)    modules=random, sys
    editJson    ${android_normal.json}    app_version_code=${random_ver_code}    app_version_name=auto_create_v1.0
    post_sdk_event    ${android_normal.json}    ${sdk_ip}
    sleep    3
    #todo：下面需要补充：查询版本列表
