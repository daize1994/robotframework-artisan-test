*** Settings ***
Library           ArtisanCustomLibrary
Resource          ../common_keywords.txt    # 公用用户关键字

*** Test Cases ***
get_appication_list
    [Documentation]  点击下拉列表,获取所有app
    [Tags]    issue_list_page
    ${response}=    get_appication_list    100
    # 已取消home页,故注释各页的请求
    # ${app_key_list}=    set variable    ${response[1]}    # 如果固定一个app,注释此行
    # ${pages}=    set variable    (${response[0][0]}-1)/4+1+1    #从返回的二维list结果中取出app总数,计算页数
    # :FOR    ${index}    IN RANGE   2   ${pages}    #循环请求该token账户下所有的列表页面
    # \   ${response}=    get_appication_list    ${index}
    # \   ${app_key_list}=    Combine Lists    ${app_key_list}    ${response[1]}    #获取各页的appkey,保存为list,(如果只固定一个app,注释此行)
    # Set Suite Variable  ${app_key_list}
    ${app_key_list}=    set variable    ${response[1]}
    Set Suite Variable  ${app_key_list}
    log to console    all app_key is:${app_key_list}

get_issue_trend_today
    # params: ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version}=
    [Documentation]  测试各app的今日崩溃曲线图
    [Tags]    home_page
    :FOR    ${key}    IN ZIP    ${app_key_list}    #:FOR IN ZIP循环,可以从列表中遍历元素
    \   ${response}=    get_issue_trend    1    crash   ${key}

get_version_list
    [Documentation]  获取各个app的版本列表(只拿了第一页)
    [Tags]    home_page
    :FOR    ${key}    IN ZIP    ${app_key_list}    #:FOR IN ZIP循环,可以从列表中遍历元素
    \   ${response}=    get_version_list    1    1   ${key}

get_detail
    #params: ${appkey}=${app_id}
    [Documentation]  获取应用的属性信息,例如所有版本,名称之类似
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}   #:FOR IN ZIP循环,可以从列表中遍历元素
    \    get_detail    ${key}

get_issue_trend_yesterday
    # params: ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version}=
    [Documentation]  获取最近2天的崩溃趋势图信息
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}    #:FOR IN ZIP循环,可以从列表中遍历元素
    \   ${response}=    get_issue_trend    2    crash   ${key}

get_issue_trend_month
    # params: ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version}=
    [Documentation]  获取最近30天的崩溃趋势图信息
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}    #:FOR IN ZIP循环,可以从列表中遍历元素
    \   ${response}=    get_issue_trend    30    crash   ${key}

get_issue_summary_today
    # params:  ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version}=
    [Documentation]  获取今日问题统计
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}    #:FOR IN ZIP循环,可以从列表中遍历元素
    \   get_issue_summary   1   crash   ${key}

get_launched_session
    # params: ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version_name}=    ${version_code}=
    [Documentation]  获取今日启动数
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}
    \   get_launched_session    1    crash    ${key}

get_active_session
    # params: ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version_name}=    ${version_code}=
    [Documentation]  获取今日活跃数
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}
    \   get_active_session    1    crash    ${key}

get_crash_list_month
    # params: ${duration}   ${issue_type}   ${page}    ${page_size}    ${appkey}=${app_id}    ${version}=
    [Documentation]  获取30天的问题列表
    [Tags]    issue_list_page
    ${app_key_crash_list_message_dict}=    create dictionary
    # 获取各个app_key下30天内的profile_key,字典形式{appkey:[profile1,profile2,...],...}返回
    :FOR    ${key}    IN ZIP    ${app_key_list}    #:FOR IN ZIP循环,可以从列表中遍历元素
    \   ${return_message}=    get_crash_list   30   crash   1    1    ${key}
    \   Set To Dictionary    ${app_key_crash_list_message_dict}    ${key}    ${return_message}
    log to console    the dict of message for app is: ${app_key_crash_list_message_dict}
    Set Suite Variable  ${app_key_crash_list_message_dict}

get_crash_summary_month
    # params: ${profilekey}    ${duration}   ${issue_type}    ${appkey}=${app_id}    ${version}=
    [Documentation]  获取最近30天的每一个问题的统计信息(这里只取了列表的第一个问题来测试)
    [Tags]    issue_list_page
    :FOR    ${key}    IN ZIP    ${app_key_list}
    \   # 从用例get_crash_list_month的返回结果字典中,根据appkey查找profilekey
    \   ${get_message_list}=    Get From Dictionary    ${app_key_crash_list_message_dict}    ${key}
    \   ${list_length}=    Get Length    ${get_message_list[0]}
    \   # 过滤掉没有profilekey的app
    \   run keyword if    ${list_length}>0    get_crash_summary    ${get_message_list[0][0]}    30    crash    ${key}   # 二维列表中取出profilekey

get_crash_version_reporter
     # params: ${profilekey}    ${appkey}=${app_id}
     [Documentation]  获取每一个问题的各版本最近7天崩溃数据(这里只取了列表的第一个问题来测试)
     [Tags]    crash_detail_page
     :FOR    ${key}    IN ZIP    ${app_key_list}
    \   # 从用例get_crash_list_month的返回结果字典中,根据appkey查找profilekey
    \   ${get_message_list}=    Get From Dictionary    ${app_key_crash_list_message_dict}    ${key}
    \   ${list_length}=    Get Length    ${get_message_list[0]}
    \   # 过滤掉没有profilekey的app
    \   run keyword if    ${list_length}>0    get_crash_version_reporter    ${get_message_list[0][0]}    crash    ${key}   # 二维列表中取出profilekey

get_crash_distribution_reporter
     # params: ${profilekey}    ${appkey}=${app_id}
     [Documentation]  获取每一个问题的设备和系统分布数据(这里只取了列表的第一个问题来测试)
     [Tags]    crash_detail_page
     :FOR    ${key}    IN ZIP    ${app_key_list}
    \   # 从用例get_crash_list_month的返回结果字典中,根据appkey查找profilekey
    \   ${get_message_list}=    Get From Dictionary    ${app_key_crash_list_message_dict}    ${key}
    \   ${list_length}=    Get Length    ${get_message_list[0]}
    \   # 过滤掉没有profilekey的app
    \   run keyword if    ${list_length}>0    get_crash_distribution_reporter    ${get_message_list[0][0]}    crash    ${key}   # 二维列表中取出profilekey

get_crash_detail
    # params: ${profilekey}    ${direction}   ${issue_type}    ${lasttime}    ${appkey}=${app_id}    ${version}=    ${crashkey}=
    [Documentation]  获取每一个问题的崩溃详情(这里只取了列表的第一个问题来测试)
    [Tags]    crash_detail_page
    :FOR    ${key}    IN ZIP    ${app_key_list}
    \   # 从用例get_crash_list_month的返回结果字典中,根据appkey查找lasttime
    \   ${get_message_list}=    Get From Dictionary    ${app_key_crash_list_message_dict}    ${key}
    \   log to console    定位的:${get_message_list}
    \   ${list_length}=    Get Length    ${get_message_list[0]}
    \   # 过滤掉没有crash的app
    \   run keyword if    ${list_length}>0    get_crash_detail    ${get_message_list[0][0]}    0    crash    ${get_message_list[1][0]}    ${key}   # 二维列表中取出各app下第一个ceash的lasttime

# todo:1.crash详情更多页面接口检测;2.按版本筛选条件,补充测试用例;