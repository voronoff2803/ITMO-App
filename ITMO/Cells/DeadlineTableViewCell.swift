//
//  DeadlineTableViewCell.swift
//  ITMO
//
//  Created by Alexey Voronov on 01/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class DeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var firstBGView: UIView!
    @IBOutlet weak var secondBGView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        firstBGView.backgroundColor = Config.Colors.backgroundSecond
        secondBGView.backgroundColor = Config.Colors.backgroundSecond
        self.contentView.backgroundColor = Config.Colors.background
        self.backgroundColor = Config.Colors.background
        self.titleLabel.textColor = Config.Colors.textFirst
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(deadline: Deadline) {
        titleLabel.text = deadline.title
        subjectLabel.text = deadline.subject
        descriptionLabel.text = deadline.description
        dateLabel.text = deadline.date
        groupLabel.text = deadline.visible
        if deadline.active {
            checkboxImageView.image = UIImage(named: "empty")
        } else {
            checkboxImageView.image = UIImage(named: "filled")
        }
    }
    
}
