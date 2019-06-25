//
//  ViewController.swift
//  RecordingForChat
//
//  Created by Qi Wang on 2019/6/20.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController ,UITableViewDataSource ,UITableViewDelegate {
	
	@IBOutlet weak var speakBtn: UIButton!
	
	@IBOutlet weak var tableView: UITableView!
	
	var volumeView: VoiceVolumeView?
	
	var voiceList: NSMutableArray
	
	var audioSession: AVAudioSession?
	
	var audioRecorder: AVAudioRecorder?
	
	var audioPlayer: AVAudioPlayer?
	
	//	var voiceFilePath: String?
	
	var countTime: NSInteger
	
	var voiceTimer: Timer?
	
	var isLeaveSpeak: Bool?
	
	
	required init?(coder aDecoder: NSCoder) {
		countTime = 60
		voiceList = NSMutableArray.init()
		isLeaveSpeak = false
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.speakBtn.setTitle("松开 发送", for: .highlighted)
		self.speakBtn.setTitle("按住 说话", for: .normal)
	}
	
	//MARK:-------UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return voiceList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:VoiceCell = tableView.dequeueReusableCell(withIdentifier: "VoiceCell") as! VoiceCell
		cell.textLabel?.text = voiceList[indexPath.row] as? String
		return cell
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		
		playRecordVoice(index: indexPath.row)
	}
	
	//MARK:------Button Click
	//按住按钮时，开始录音
	@IBAction func speakClickTouchDown(_ sender: Any) {
		print("------------speakClickTouchDown")
		
		if canRecorder() {
			print("请开启麦克风-设置/隐私/麦克风")
		}
		
		//显示录音视图
		if (volumeView != nil) {
			volumeView?.removeFromSuperview()
		}
		volumeView = VoiceVolumeView.init()
		if let vv = volumeView {
			vv.frame.size = CGSize.init(width: 120, height: 150)
			vv.center = self.view.center
			self.view.addSubview(vv)
			vv.setVolumeView()
		}
		
		//开始录音
		countTime = 60
		
		voiceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
			self.audioRecorder?.updateMeters()
			
			var level: Float = 0.0
			let minDecibels: Float = -80.0
			let decibels: Float = (self.audioRecorder?.averagePower(forChannel: 0))!
			
			if (decibels < minDecibels) {
				level = 0.0
			} else if (decibels >= 0.0) {
				level = 1.0
			} else {
				let root = 2.0
				let minAmp = powf(10.0, 0.05 * minDecibels)
				let inverseAmpRange = 1.0 / (1.0 - minAmp)
				let amp = powf(10.0, 0.05 * decibels)
				let adjAmp = (amp - minAmp) * inverseAmpRange
				
				level = powf(adjAmp, Float(1.0 / root))
			}
			
			var voice = level*10 + 1
			voice = voice > 8 ? 8 : voice
			
			let imageIndex = String.init(format: "chat_volume%.f", round(voice))
			if self.isLeaveSpeak! {
				//设置取消的图片
				
			} else {
				//设置音量的图片
				print(imageIndex)
				
				if let vv = self.volumeView {
					vv.changeVolumeImage(nameIndex: imageIndex)
				}
			}
			
			self.countTime = self.countTime - 1
			print(self.countTime)
			
			if self.countTime < 10 && self.countTime > 0 {
				//设置剩余时间的文字
				
			}
			
			if(self.countTime < 1) {
				//自动发送消息
				self.speakClickTouchUpInside(sender)
			}
		})
		RunLoop.current.add(voiceTimer!, forMode: .common)
		
		if let audioS = audioSession {
			do {
				try audioS.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
			} catch {
				print("audioSession 设置失败")
			}
			
			do {
				try audioS.setActive(true, options: AVAudioSession.SetActiveOptions.init(rawValue: 0))
			} catch {
				print("audioSession 设置失败")
			}
		}
		
		//获取沙盒文件位置
		let path: String = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last ?? nil)!
		let order = voiceList.count as Int
		let namePath = "/Record\(String(describing: order)).wav"
		let voiceFilePath = path.appending(namePath)
		
		//将音频添加至数组
		voiceList.add(namePath)
		
		//设置参数
		let filePathURL = URL.init(fileURLWithPath: voiceFilePath)
		
		let recordSetting = [
			AVFormatIDKey: kAudioFormatLinearPCM,
			AVSampleRateKey: 8000.0,
			AVNumberOfChannelsKey: 1,
			AVLinearPCMBitDepthKey: 16,
			AVLinearPCMIsNonInterleaved: false,
			AVLinearPCMIsFloatKey: false,
			AVLinearPCMIsBigEndianKey: false
			] as [String : Any]
		do {
			try audioRecorder = AVAudioRecorder.init(url: filePathURL, settings: recordSetting)
		} catch {
			print("audioRecorder 初始化失败")
		}
		
		audioRecorder?.isMeteringEnabled = true
		audioRecorder?.prepareToRecord()
		audioRecorder?.record()
		
	}
	
	//松开发送
	@IBAction func speakClickTouchUpInside(_ sender: Any) {
		print("------------speakClickTouchUpInside")
		//隐藏录音视图
		if (volumeView != nil) {
			volumeView?.removeFromSuperview()
		}
		
		isLeaveSpeak = false
		
		voiceTimer?.invalidate()
		voiceTimer = nil
		
		if let _ = audioRecorder?.isRecording {
			audioRecorder?.stop()
		}
		
		//刷新列表
		tableView.reloadData()
	}
	
	//离开按钮区域 松开 取消 "松开手指 取消发送"
	@IBAction func speakClickTouchUpOutside(_ sender: Any) {
		print("------------speakClickTouchUpOutside")
		isLeaveSpeak = false
		
		voiceList.removeLastObject()
		
		voiceTimer?.invalidate()
		voiceTimer = nil
	
		if let _ = audioRecorder?.isRecording {
			audioRecorder?.stop()
		}
		
		//隐藏录音视图
		if (volumeView != nil) {
			volumeView?.removeFromSuperview()
		}
		
	}
	
	@IBAction func speakClcikTouchDragExit(_ sender: Any) {
		print("------------松开手指，取消发送")
		isLeaveSpeak = true
		
		if let vv = self.volumeView {
			vv.changeVolumeImage(nameIndex: "chat_volume_cancel")
			vv.changeVolumeLb(text: "松开手指 取消发送", bgColor: UIColor.red)
		}
		
	}
	
	@IBAction func speakClickTouchDragEnter(_ sender: Any) {
		print("------------手指上滑，取消发送")
		isLeaveSpeak = false
		
		if let vv = self.volumeView {
			vv.changeVolumeImage(nameIndex: "")
			vv.changeVolumeLb(text: "手指上滑 取消发送", bgColor: UIColor.clear)
		}
		
	}
	
	//MARK:------method
	//检查麦克风权限
	func canRecorder() -> Bool {
		var result = false;
		
		//无须解包 直接获取权限状态
		//		let recordPermission = AVAudioSession.sharedInstance().recordPermission
		//强制解包 获取权限状态
		//			let recordPermission = audioSession!.recordPermission
		
		audioSession = AVAudioSession.sharedInstance()
		
		//if let 解包 获取audioSession
		if let audioS = audioSession {
			switch audioS.recordPermission {
			case .granted:
				//已授权
				result = true
			case .denied:
				//拒绝授权
				result = false
			case .undetermined:
				//请求授权
				DispatchQueue.main.async {
					audioS.requestRecordPermission { (allowed) in
						if allowed {
							result = true
						} else {
							result = false
						}
					}
				}
			default:
				result = false
			}
		}
		return result;
	}
	
	//MARK:------播放音频
	func playRecordVoice(index: Int) {
		let path: String = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last ?? nil)!
		let namePath = "/Record\(String(describing: index)).wav"
		let voiceFilePath = path.appending(namePath)
		let filePathURL = URL.init(fileURLWithPath: voiceFilePath)
		
		do {
			try audioPlayer = AVAudioPlayer.init(contentsOf: filePathURL)
		} catch {
			print("audioPlayer 初始化失败")
		}
		
		audioSession = AVAudioSession.sharedInstance()
		if let audioS = audioSession {
			do {
				try audioS.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
			} catch let err as NSError {
				print("audioSession 设置失败：\(err.description)")
			}
			
			do {
				try audioS.setActive(true, options: AVAudioSession.SetActiveOptions.init(rawValue: 0))
			} catch {
				print("audioSession 设置失败")
			}
		}
		
		audioPlayer?.prepareToPlay()
		audioPlayer?.play()
	}
}

