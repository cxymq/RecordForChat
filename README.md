# RecordForChat

注意：在 info.plist 中申请麦克风权限

步骤如下：

 

1.需要申请麦克风权限

 

2.调用 AVFoundation 的API 

 

主要用到 AVAudioRecorder(录音) 、AVAudioPlayer(播放)、AVAudioSession(设置音频硬件设备)

 

录音开始前，先检测权限，如果允许，则设置音频硬件设备：
```
audioS.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
 ```
 
```
audioS.setActive(true, options: AVAudioSession.SetActiveOptions.init(rawValue: 0))
 ```

设置存放路径：
```
letpath: String= (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?? nil)!
 
let order = voiceList.count as Int
 
let namePath = "/Record\(String(describing: order)).wav"
 
let voiceFilePath = path.appending(namePath)
 ```

进行录音设置：
```
letrecordSetting = [
 
AVFormatIDKey: kAudioFormatLinearPCM,
 
AVSampleRateKey: 8000.0,
 
AVNumberOfChannelsKey: 1,
 
AVLinearPCMBitDepthKey: 16,
 
AVLinearPCMIsNonInterleaved: false,
 
AVLinearPCMIsFloatKey: false,
 
AVLinearPCMIsBigEndianKey: false
 
] as [String : Any]
 ```

然后调用 record() 开始录音。


播放录音，只需要提供音频路径，调用 play() 即可。

-----------------------------------------------------------

[个人博客](https://blog.csdn.net/Crazy_SunShine)

[Github](https://github.com/cxymq)

[个人公众号:Flutter小同学]
![https://github.com/cxymq/Images/blob/master/0.失败预加载图片/error.jpg](https://github.com/cxymq/Images/blob/master/1.公众号二维码/qrcode.png)

[个人网站](http://chenhui.today/)

--------------------- 

