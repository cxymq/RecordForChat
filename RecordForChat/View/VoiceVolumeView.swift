//
//  VoiceVolumeView.swift
//  RecordingForChat
//
//  Created by Qi Wang on 2019/6/24.
//  Copyright © 2019 Qi Wang. All rights reserved.
//

import UIKit

class VoiceVolumeView: UIView {
	
	var volumeImageView: UIImageView?
	
	var volumeLb: UILabel?
	
	public func setVolumeView() {
		self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		self.layer.cornerRadius = 10
		
		volumeImageView = UIImageView.init(frame: .init(x: 15, y: 10, width: self.frame.size.width-30, height: self.frame.size.height-50))
		volumeImageView?.image = UIImage.init(named: "chat_volume1")
		self.addSubview(volumeImageView!)
		
		volumeLb = UILabel.init(frame: CGRect.init(x: 5, y: self.frame.size.height-30, width: self.frame.size.width-10, height: 20))
		volumeLb?.font = UIFont.systemFont(ofSize: 12)
		volumeLb?.layer.masksToBounds = true
		volumeLb?.layer.cornerRadius = 5
		volumeLb?.textAlignment = .center
		volumeLb?.textColor = UIColor.white
		volumeLb?.text = "手指上滑 取消发送"
		self.addSubview(volumeLb!)
	}
	
	public func changeVolumeImage(nameIndex: String) {
		volumeImageView?.image = UIImage.init(named: nameIndex)
	}
	
	public func changeVolumeLb(text: String, bgColor: UIColor) {
		volumeLb?.text = text
		volumeLb?.backgroundColor = bgColor
	}
	
//	required init?(coder aDecoder: NSCoder) {
//
//		super.init(coder: aDecoder)
//
//
//	}
	
	/*
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
	// Drawing code
	}
	*/
	
}
