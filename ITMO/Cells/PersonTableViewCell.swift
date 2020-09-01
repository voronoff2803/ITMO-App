//
//  PersonTableViewCell.swift
//  ITMO
//
//  Created by Alexey Voronov on 16/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        personImageView.backgroundColor = Config.Colors.backgroundSecond
        self.contentView.backgroundColor = Config.Colors.background
        self.backgroundColor = Config.Colors.background
        self.nameLabel.textColor = Config.Colors.textFirst
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(person: Person) {
        nameLabel.text = person.person
        self.accessoryType = .disclosureIndicator
    }
    
}
