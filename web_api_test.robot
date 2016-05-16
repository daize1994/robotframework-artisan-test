*** Settings ***
Library           ArtisanCustomLibrary
Resource          server_api_test_data.txt    # 接口测试专用数据
Resource          common_keywords.txt    # 公用用户关键字

*** Test Cases ***
get_appication_list
    ${response}=    get_appication_list    1    4

get_issue_trend
     # params: ${duration}   ${issue_type}    ${version}=    ${appkey}=${app_id}
     ${response}=    get_issue_trend    1    crash

get_version_list
    get_version_list    1    1

get_detail
    get_detail

get_issue_summary
    get_issue_summary   1   crash

get_daily_launched_session
    get_daily_launched_session    1    crash

get_daily_active_session
    get_daily_active_session    1    crash

get_crash_list
    get_crash_list    1    crash    1    1

