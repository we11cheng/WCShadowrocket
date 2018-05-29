## frida-ios-dumy 
### 新手砸壳教程（演示为Python2环境）

### ios端配置参考（越狱情况下）
- 打开cydia 添加源：https://build.frida.re
- 打开刚刚添加的源 安装 Frida
- 安装完成

#### 参考链接  <https://www.frida.re/docs/ios/>

### mac端配置
- 终端执行：

```sudo pip install frida```  
- 假如报以下错误：

```Uninstalling a distutils installed project (six) has been deprecated and will be removed in a future version. This is due to the fact that uninstalling a distutils project will only partially uninstall the project.```

- 使用以下命令安装：

```sudo pip install frida –upgrade –ignore-installed six```

- 检查是否安装成功 任意mac终端输入```frida-ps -U```有数据返回表示成功安装。

#### ps: Python3 使用pip3安装(大同小异)

## 通过USB&ssh连接iphone
- 安装usbmuxd（brew安装最简单暴力推荐使用brew安装）。  
```brew install usbmuxd```   
如果你没有安装brew的话，那需要先执行  
```/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"```      
- 手机通过数据线连接电脑。      
- 终端输入      
```iproxy 2222 22```     
ps：将当前连接设备的22端口映射到电脑的4567端口上，继而来连接SSH。   
- 新开一个终端  
```ssh -p 2222 root@127.0.0.1```   
ps：127.0.0.1是默认本机回环地址。
- 输入ssh密码即可（默认密码alpine，建议修改）。

### 开始砸壳之旅

- 从Github下载工程：
```
git clone https://github.com/AloneMonkey/frida-ios-dump 
```     
- 安装依赖：
```
sudo pip install -r /opt/dump/frida-ios-dump/requirements.txt --upgrade
```
- 修改dump.py参数：
```
vim frida-ios-dump/dump.py
```
- 找到如下几行   
User = 'root'   
Password = 'xxxxxxxxxx'   
Host = 'localhost'   
Port = 2222   
- 修改Password和端口号。和iproxy命令端口号保持一致。  
- 执行frida命令：切换到frida-ios-dump目录
1. ```python dump.py -l``` 列举出安装的应用的名字和bundle id   
2. ```python dump.py bundle id``` 
- 默认砸壳后ipa路径在项目根目录。

#### ps1:执行dump命令的时候要确保手机上已经打开你需要砸壳的app。
### ps2:Python3 有对应Python3 分支3.x分支（如何切换分支自行百度）演示的为Python2。


