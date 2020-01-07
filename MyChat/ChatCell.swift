//
//  ChatCell.swift
//  MyChat
//
//  Created by Xijie Lin on 1/6/20.
//  Copyright © 2020 com.cn. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    let bgView = UIView()
    let titleLab = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // register UITableViewCell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          
          self.addSub()
    
      }
    func addSub() {
        // adding sub elements
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        // setting the background color
        bgView.backgroundColor =  UIColor.systemBlue
        // setting round corner
        bgView.layer.cornerRadius = 5
        // cutting the edges
        bgView.layer.masksToBounds = true
        self.contentView.addSubview(bgView)
        
        // the message content
        titleLab.numberOfLines = 0
        // setting the color and font of the text
        titleLab.textColor = UIColor.black
        titleLab.font = UIFont.systemFont(ofSize: 14)
        // text Alignment
        titleLab.textAlignment = .left
        self.contentView.addSubview(titleLab)
        // icon of the sender
        let headIcon = UIImageView()
        // the icon size
        headIcon.frame = CGRect.init(x: ScreenW - 40, y: 10, width: 30, height: 30)
        
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
