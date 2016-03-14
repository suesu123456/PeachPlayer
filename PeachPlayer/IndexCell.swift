
//
//  IndexCell.swift
//  PeachPlayer
//
//  Created by yxk on 16/3/14.
//  Copyright © 2016年 yxk. All rights reserved.
//

import UIKit

class IndexCell: UITableViewCell {
    
    var images: UIImageView!
    var titleLab: UILabel!
    var detailLab: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        images = UIImageView(frame: CGRectMake(10, 20, 50, 50))
        images.layer.masksToBounds = true
        images.layer.cornerRadius = 25
        self.addSubview(images)
        titleLab = UILabel(frame: CGRectMake(70, 15, SCREEN_WIDTH - 80, 30))
        self.addSubview(titleLab)
        detailLab = UILabel(frame: CGRectMake(70, titleLab.frame.maxY + 8, 200, 20))
        self.addSubview(detailLab)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    

}
