*** Settings ***
Library           ArtisanCustomLibrary
Resource          ../common_keywords.txt    # 公用用户关键字
Resource          webapi_autotest_common_keywords.txt
Resource          ../webapi_common_data/webapi_data_for_test.txt    # 测试环境数据
#Resource         ../webapi_common_data/webapi_data_for_prod.txt    # 生产环境数据

*** Test Cases ***
issue列表概况崩溃统计-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${before}=    get_issue_summary  ${duration}    ${type}    ${app_id}
    log to console    用例执行前数据:${before}
    send_session_and_crash
    ${after}=    get_issue_summary  ${duration}    ${type}    ${app_id}
    log to console    用例执行后数据:${after}
    ${crash_increase}    evaluate    ${after[1][0]}-${before[1][0]}
    should be equal as integers    ${crash_increase}    1   error msg:已发送crash,但web上crash未增加!

issue列表概况影响人数统计-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${before}=    get_issue_summary  ${duration}    ${type}    ${app_id}
    log to console    用例执行前数据:${before}
    # 使用相同device_id发送2条崩溃,以检查排重
    send_session_and_crash_use_new_device    2
    ${after}=    get_issue_summary  ${duration}    ${type}    ${app_id}
    log to console    用例执行后数据:${after}
    ${reporter_increase}    evaluate    ${after[2][0]}-${before[2][0]}
    should be equal as integers    ${reporter_increase}    1   error msg:已使用新device_id发送crash,但web上影响人数未增加!

崩溃和影响人数趋势统计-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${before}=    get_issue_trend  ${duration}    ${type}    ${app_id}
    log to console    用例执行前数据:${before}
    send_session_and_crash_use_new_device   1
    ${after}=    get_issue_trend  ${duration}    ${type}    ${app_id}
    # 查询issue概况统计数据,用于和趋势图数据比对
    ${current_summary}=    get_issue_summary  ${duration}    ${type}    ${app_id}
    log to console    用例执行后数据:${after}
    ${all_crash_toal_before}=   set variable    0
    ${all_crash_toal_after}=   set variable    0
    ${all_device_toal_before}=   set variable    0
    ${all_device_toal_after}=   set variable    0
    # 计算所有时间点的crash数之和
    :for    ${i}    ${j}   in zip   ${before[0]}    ${after[0]}
    \    ${all_crash_toal_before}=    evaluate    ${all_crash_toal_before}+${i}
    \    ${all_crash_toal_after}=    evaluate    ${all_crash_toal_after}+${j}
    # 计算所有时间点的影响人数之和
    :for    ${i}    ${j}   in zip   ${before[1]}    ${after[1]}
    \    ${all_device_toal_before}=    evaluate    ${all_device_toal_before}+${i}
    \    ${all_device_toal_after}=    evaluate    ${all_device_toal_after}+${j}
    # 计算差值
    ${trend_crash_increase}=    evaluate     ${all_crash_toal_after}-${all_crash_toal_before}
    ${trend_device_increase}=    evaluate     ${all_device_toal_after}-${all_device_toal_before}
    should be equal as integers     ${trend_crash_increase}    1    error msg:已发送crash,但崩溃趋势上崩溃数未增加
    should be equal as integers     ${trend_device_increase}    1    error msg:已使用新设备发送crash,但是影响人数曲线上影响人数没变化
    should be equal as integers     ${all_crash_toal_after}    ${current_summary[1][0]}    error msg:issue概况上崩溃数与曲线图崩溃数总和不一致!

启动统计-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${before}=    get_launched_session    ${duration}    ${type}    ${app_id}
    log to console    用例执行前数据:${before}
     send_session_and_crash
    ${after}=    get_launched_session  ${duration}    ${type}    ${app_id}
    log to console    用例执行后数据:${after}
    ${session_increase}    evaluate    ${after[0]}-${before[0]}
    should be equal as integers    ${session_increase}    1   error msg:已发送session,但web上启动数未增加!

活跃统计-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${before}=    get_active_session    ${duration}    ${type}    ${app_id}
    log to console    用例执行前数据:${before}
    # 使用相同device_id发送2条崩溃,以检查排重
    send_session_and_crash_use_new_device    2
    ${after}=    get_active_session  ${duration}    ${type}    ${app_id}
    log to console    用例执行后数据:${after}
    ${session_increase}    evaluate    ${after[0]}-${before[0]}
    should be equal as integers    ${session_increase}    1   error msg:已发送新设备的session,但web上活跃数未增加或多增加了!

检查issue列表的issue个数-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${before}=    get_crash_list    ${duration}    ${type}   1    1    ${app_id}
    log to console    用例执行前数据:${before}
    # 发送新issue,重复2次,以检查issue合并
    send_session_and_crash_with_new_stack_use_new_device    2
    ${after}=    get_crash_list    ${duration}    ${type}   1    1    ${app_id}
    log to console    用例执行后数据:${after}
    ${issuecount_increase}    evaluate    ${after[2][0]}-${before[2][0]}
    should be equal as integers    ${issuecount_increase}    1   error msg:已发送新的issue,但web上issue列表没有增加该issue!

检查issue列表的issue统计-今天
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${issue_list}=    get_crash_list    ${duration}    ${type}   1    1    ${app_id}
    log to console    当前issue列表有 ${issue_list[2][0]} 个issue,将查询issue_id=${issue_list[0][0]}的统计信息
    ${before}=    get_crash_summary    ${duration}   ${issue_list[0][0]}
    log to console    用例执行前数据:${before}
    # 发送上一个issue,重复2次,以检查影响人数排重
    send_session_and_crash_use_new_device    2
    ${after}=    get_crash_summary    ${duration}   ${issue_list[0][0]}
    log to console    用例执行后数据:${after}
    ${issue_crash_count_increase}    evaluate    ${after[0][0]}-${before[0][0]}
    ${issue_device_count_increase}    evaluate    ${after[1][0]}-${before[1][0]}
    should be equal as integers    ${issue_crash_count_increase}    2   error msg:用1个新设备对issue发送2条crash,该issue的崩溃统计增加了${issue_crash_count_increase}个
    should be equal as integers    ${issue_device_count_increase}    1   error msg:用1个新设备对issue发送2条crash,该issue的影响人数统计增加了${issue_device_count_increase}个

查看第一个issue的所有crash详情
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration}    1
    ${date}=    Get Time    epoch    UTC+8 hour    # 获取当前UTC时间
    ${date_string}=    Evaluate    ${date}*1000    # 被测系统的时间需要*1000
    ${date}=    Convert To Integer    ${date_string}
    # 发送1条crash,防止issue列表为空
    send_session_and_crash_use_new_device    1
    # 查询issue列表,获得issue_id
    ${issue_list}=    get_crash_list    ${duration}    ${type}   1    1    ${app_id}
    log to console    当前issue列表有 ${issue_list[2][0]} 个issue,将查询 issue_id=${issue_list[0][0]} 的所有crash
    # 根据issue_id查询所有crash_id
    ${crash_ids}=    get_crash_id_list    ${issue_list[0][0]}    1    100
    :FOR   ${crash_id}    IN ZIP    ${crash_ids[1]}
    \    get_crash_detail    ${crash_id}

查看issue详情历史统计数据
    [Tags]    autotest
    Set Test Variable    ${type}    1
    Set Test Variable    ${duration_1}    1
    Set Test Variable    ${duration_all}    -1
    # 先发送1条crash,防止当前issue列表为空的情况
    send_session_and_crash_use_new_device    1
    # 查询issue列表,获得issue_id
    ${issue_list}=    get_crash_list    ${duration_1}    ${type}   1    1    ${app_id}
    log to console    当前issue列表有 ${issue_list[2][0]} 个issue,将测试 issue_id=${issue_list[0][0]} 的那一个
    # 获取测试前第一个issue的统计信息
    ${before}=    get_crash_summary    ${duration_all}    ${issue_list[0][0]}
    log to console    用例执行前数据:${before}
    # 使用1个新设备对该issue发送2条crash
    send_session_and_crash_use_new_device    2
    # 获取测试后第一个issue的统计信息
    ${after}=    get_crash_summary    ${duration_all}    ${issue_list[0][0]}
    log to console    用例执行后数据:${after}
    ${crash_increase}    evaluate    ${after[0][0]}-${before[0][0]}
    ${reporter_increase}    evaluate    ${after[1][0]}-${before[1][0]}
    # 断言,崩溃增加2个,影响人数增加1个
    should be equal as integers    ${crash_increase}    2   error msg:已发送该issue的crash2次,但issue详情中crash数未增加2!
    should be equal as integers    ${reporter_increase}    1   error msg:已使用1个新设备发送该issue的crash2次,但issue详情中影响人数不是增加1!
