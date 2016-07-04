*** Settings ***
Library           ArtisanCustomLibrary
Resource          webapi_autotest_data.txt    # 接口测试专用数据
Resource          ../common_keywords.txt    # 公用用户关键字

*** Test Cases ***
issue列表今天统计崩溃统计
    ${before}=    get_issue_summary  1    crash    ${test_app_id}
    log to console    用例执行前数据:${before}
    send_session_and_crash
    ${after}=    get_issue_summary  1    crash    ${test_app_id}
    log to console    用例执行后数据:${after}
    ${crash_increase}    evaluate    ${after[1][0]}-${before[1][0]}
    should be equal as integers    ${crash_increase}    1   error msg:已发送crash,但web上crash未增加!

issue列表今天影响人数统计
    ${before}=    get_issue_summary  1    crash    ${test_app_id}
    log to console    用例执行前数据:${before}
    # 使用相同device_id发送2条崩溃,以检查排重
    send_session_and_crash_use_new_device    2
    ${after}=    get_issue_summary  1    crash    ${test_app_id}
    log to console    用例执行后数据:${after}
    ${reporter_increase}    evaluate    ${after[2][0]}-${before[2][0]}
    should be equal as integers    ${reporter_increase}    1   error msg:已使用新device_id发送crash,但web上影响人数未增加!

崩溃趋势统计
    ${before}=    get_issue_trend  1    crash    ${test_app_id}
    log to console    用例执行前数据:${before}
    send_session_and_crash
    ${after}=    get_issue_trend  1    crash    ${test_app_id}
    # 查询issue概况统计数据,用于和趋势图数据比对
    ${current_summary}=    get_issue_summary  1    crash    ${test_app_id}
    log to console    用例执行后数据:${after}
    ${all_crash_toal_before}=   set variable    0
    ${all_crash_toal_after}=   set variable    0
    # 计算所有时间点的crash数之和
    :for    ${i}    ${j}   in zip   ${before}    ${after}
    \    ${all_crash_toal_before}=    evaluate    ${all_crash_toal_before}+${i}
    \    ${all_crash_toal_after}=    evaluate    ${all_crash_toal_after}+${j}
    ${trend_crash_increase}=    evaluate     ${all_crash_toal_after}-${all_crash_toal_before}
    should be equal as integers     ${trend_crash_increase}    1    error msg:已发送crash,但崩溃趋势上崩溃数未增加!
    should be equal as integers     ${all_crash_toal_after}    ${current_summary[1][0]}    error msg:issue概况上崩溃数与曲线图崩溃数总和不一致!

