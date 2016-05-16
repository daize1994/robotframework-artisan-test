# robotframework-artisan-test简介
## 使用RF框架实现“artisan”项目接口测试的一些tests
### 环境：
- python 2.7
- robot framework 3.0:  `pip install robotframework`
- Requests Library:  `pip install requestslibrary`
- ArtisanCustomLibary:  从[这里](https://github.com/daize1994/ArtisanCustomLibrary)fork到本地site-packages目录
...

### 实现：
- 实现了web api和server api的接口测试
- 实现了CI，依赖项目的自动构建，每日定时构建

### 结构：
- 自定义用户关键字
- 用例
- 数据
