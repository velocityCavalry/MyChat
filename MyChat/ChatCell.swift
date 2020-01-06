//
//  ChatCell.swift
//  MyChat
//
//  Created by abc on 2019/12/31.
//  Copyright © 2019 com.cn. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    let bgView = UIView()
    let titleLab = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //注册UITableViewCell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          
          self.addSub()
    
      }
    func addSub() {
        //添加子控件
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        // 添加聊天消息蓝色背景
        bgView.backgroundColor =  UIColor.systemBlue
        // 圆角
        bgView.layer.cornerRadius = 5
        //切除边缘
        bgView.layer.masksToBounds = true
        self.contentView.addSubview(bgView)
        
        // 聊天内容
        titleLab.numberOfLines = 0
        //字体颜色
        titleLab.textColor = UIColor.black
        titleLab.font = UIFont.systemFont(ofSize: 14)
        //字体左对齐
        titleLab.textAlignment = .left
        self.contentView.addSubview(titleLab)
        //发送消息者头像
        let headIcon = UIImageView()
        //位置大小
        headIcon.frame = CGRect.init(x: ScreenW - 40, y: 10, width: 30, height: 30)
        //图片
        headIcon.image = UIImage(named: "me")
        self.contentView.addSubview(headIcon)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
