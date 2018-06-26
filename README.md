# iOS版Shadowrocket 完美重签 无需付费 无需越狱~ (理论上支持越狱手机所有已购App)
# 越狱手机砸壳ipa 详见<https://github.com/AloneMonkey/frida-ios-dump>
# 查看应用的bundleID ```Python3 dump.py -l```
# 砸壳 ```Python3 dump.py bundleID```


## 使用

#### 1、安装MonkeyDev(如已安装，跳过)

- 安装最新的theos

```
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
```

- 安装ldid(如安装theos过程安装了ldid，跳过)

```
brew install ldid
```

- 指定的Xcode

```
sudo xcode-select -s /Applications/Xcode.app
```

- 执行安装命令

```
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-install)"
```

- 更新

```
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-update)"
```

- 卸载

```
sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-uninstall)"
```

#### 2、运行工程

- 打开工程 WCShadowrocket.xcodeproj 
- 选择证书：自动配置证书即可（相信大家都是没有问题的）。
- 选择设备(不可选择模拟器，且仅支持64位设备)运行。
- 本次测试机iphone6s 10.3.3 xcode 9.3（其他机型应该也没问题）。


## 版权及免责声明

- iOS逆向实践，不可使用于商业和个人其他意图。一切问题均由个人承担，与本人无关。
- 感谢MonkeyDev的作者庆总<https://github.com/AloneMonkey/MonkeyDev>。
- 如内容对您的权利造成了影响，请[issues](https://github.com/we11cheng/WCShadowrocket/issues), 我会在第一时间进行删除。



## 效果截图

![](http://p2bzzkn05.bkt.clouddn.com/18-4-10/70735207.jpg)


## 华丽的分割线

点右上角的 Star 可以领红包，不信你试试。重签付费应用就是这么容易，感谢MonkeyDev作者。

## 最近更新

- 酷我音乐无损音质去壳ipa 路径：其他砸壳ipa目录下。拖入项目target运行即可（应用我都会先测试一下,放心使用）     
- 提供免费付费软件砸壳，低调使用。应用列表：Shu Thor Detour Kitsunebi Pythonista HyperApp JSBOx Surge Quantumult PPHub Tik Tok Mume Mume Red ...
- 2108-5-28 更新最新的MonkeyDev。
- 2018-5-29 添加自建vps ssr节点信息。虽然延迟有点高，但还是能用的。完全自己搭建，(有限制流量，不够再加)放心使用~  
 SSR   链接 : ssr://NjQuMTM3LjI1MS4xNDE6NTg2NzphdXRoX3NoYTFfdjQ6Y2hhY2hhMjA6dGxzMS4yX3RpY2tldF9hdXRoOlpHOTFZaTVwYnk5emMzcG9abmd2S2pVNE5qYy8/b2Jmc3BhcmFtPSZwcm90b3BhcmFtPSZncm91cD1kM2QzTG5OemNuTm9ZWEpsTG1OdmJRJnJlbWFya3M9UkUxZlRtOWtaUQ   

 SSR 二维码 : http://doub.pw/qr/qr.php?text=ssr://NjQuMTM3LjI1MS4xNDE6NTg2NzphdXRoX3NoYTFfdjQ6Y2hhY2hhMjA6dGxzMS4yX3RpY2tldF9hdXRoOlpHOTFZaTVwYnk5emMzcG9abmd2S2pVNE5qYy8/b2Jmc3BhcmFtPSZwcm90b3BhcmFtPSZncm91cD1kM2QzTG5OemNuTm9ZWEpsTG1OdmJRJnJlbWFya3M9UkUxZlRtOWtaUQ

![](http://p2bzzkn05.bkt.clouddn.com/18-6-26/47803455.jpg)
规则详见<https://github.com/lhie1/Rules>,自行选择使用。
- 2018-6-14,其他部分砸壳ipa请戳<https://github.com/we11cheng/WCCrackedCollect>
- 2018-6-26,vps炸裂，更新ssr信息。


