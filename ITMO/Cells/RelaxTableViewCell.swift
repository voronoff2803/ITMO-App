//
//  RelaxTableViewCell.swift
//  ITMO
//
//  Created by Alexey Voronov on 18/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class RelaxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup() {
        self.contentView.backgroundColor = Config.Colors.background
        self.backgroundColor = Config.Colors.background
        gradientView.topColor = Config.Colors.backgroundSecond
        gradientView.bottomColor = Config.Colors.backgroundThird
        
        titleLabel.textColor = Config.Colors.textFirst
    }
    
}
