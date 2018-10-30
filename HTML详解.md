HTML详解

```
什么是标签:

是由一对尖括号包裹的单词构成 例如: <html> *所有标签中的单词不可能以数字开头.
标签不区分大小写.<html> 和 <HTML>. 推荐使用小写.
标签分为两部分: 开始标签<a> 和 结束标签</a>. 两个标签之间的部分 我们叫做标签体.
有些标签功能比较简单.使用一个标签即可.这种标签叫做自闭和标签.例如: <br/> <hr/> <input /> <img />
标签可以嵌套.但是不能交叉嵌套. <a><b></a></b>
```

```
标签属性：
通常是以键值对形式出现的. 例如 name="alex"
属性只能出现在开始标签 或 自闭和标签中.
属性名字全部小写. *属性值必须使用双引号或单引号包裹 例如 name="alex"
如果属性值和属性名完全一样.直接写属性名即可. 例如 readonly
```

<！DOCTYPE html> 标签 

该标签表示自己遵守html 新语法

head 标签

```
<meta>meta标签有两个属性，分别是http-equiv 和name属性，不同的属性有不同的值，这些值实现了不同网页的功能
1.name 标签属性主要用于描述网页，与之对应的属性为content, content 中的内容主要是便于搜索引擎进行查找和分类信息
 · <meta charset="UTF-8">
 · <meta name="keywords" content="zabbix.xytiao.cn">
2.http-equiv 属性相当于http的文件头作用，可以向浏览器传递一些用用的东西，以便于精确定位和显示网页内容，与之对应的属性值为content
实现功能：
 · 刷新，几秒后跳转
   <meta http-equiv="Refresh" content="2;https://www.baidu.com"> 如果不加网址，那么仅仅表示刷新，不跳转
 · <meta http-equiv="content-Type"content="text/html;charset=UTF8">
 
title标签，表示显示在页面上方的内容
link 标签，表示链接到哪
 · <link rel="icon" href="http://www.jd.com/favicon.ico">  表示使用标签栏的图标
```

BODY标签

一、基本标签

```
<hn>: n的取值范围是1~6; 从大到小. 用来表示标题.
<p>: 段落标签. 包裹的内容被换行.并且也上下内容之间有一行空白.
<b> <strong>: 加粗标签.
<strike>: 为文字加上一条中线.
<em>: 文字变成斜体.
<sup>和<sub>: 上角标 和 下角表.
<br>:换行.
<hr>:水平线
 <div><span>
```

 ```
特殊字符：

      &lt; &gt；&quot；&copy;&reg;
 ```

图片：

```
图片标签：
<img>
属性：src指定图片路径,title当鼠标悬停显示的文字，height图片高度可以使用px,width图片宽度，alt 当图片加载失败的提示。
<img src="icon.png" title="icon" height="192px" width="192px" alt="missing">
```

超链接

```
超链接标签(锚标签)：
<a>
属性：href 要连接的资源路径，可以是本地路径或者网络路径，如果要找本文档中的id定位，需要前边加#表示匹配本文档中的id属性 #书签名称
target:_blank 表示在新窗口打开超链接或者在新框架中打开链接内容
name: 定义一个页面的书签

<a href="http://zabbix.xytiao.cn" target="_blank" title="zabbix" >zabbix</a>
```

列表：

```
列表分为
ul:无序列表
ol:有序列表
	表内容定义通过li
dl:自定义列表
	<dt> 列表标题
	<dd> 列表项

```

表格：

```
表格标签：
	border: 表格边框
	cellpadding:内边距
	cellspacing:外边距
	width:像素百分比
	<tr>: table row
		<th> :table head cell
		<td>: table data cell
	rowspan:行合并单元格
	colspan:列合并单元格
	
<table border="1", cellpadding="2", cellspacing="3" style="width: 500px;height: 20px">
    <thead>
        <tr>
            <td>第一列</td>
            <td>第二列</td>
            <td>第三列</td>
        </tr>
    </thead>
    <tbody>
    <tr>
        <td>1</td>
        <td colspan="2">2 3</td>

    </tr>
     <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
    </tr>
     <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
    </tr>

    </tbody>
</table>
```





