安装指南
--------

1. 安装rdm

        npm install random-moviegod -g

2. 更新电影数据库

        rdm update

注：更新电影数据库比较耗时



命令详解
--------

注：下文中提到的lx都是指python lixian_cli.py的别名。

常用命令：

* rdm update
* rdm random
* rdm clean

### rdm update
将会更新电影数据库

### rdm random

    rdm random

如果希望指定评分

    rdm random -r 0

注：可指定`0 - 10`分

如果想指定分类

    rdm random -c 恐怖

要指定多个分类请使用空格 ` `

    rdm random -c "恐怖 剧情"

目前可以使用的分类有如下

*  动作片
*  剧情片
*  爱情片
*  喜剧片
*  科幻片
*  恐怖片
*  动画片
*  惊悚片
*  战争片
*  犯罪片

### rdm clean
清除一些操作带来的设置缓存
