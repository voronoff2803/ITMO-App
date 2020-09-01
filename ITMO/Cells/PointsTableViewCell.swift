//
//  PointTableViewCell.swift
//  ITMO
//
//  Created by Alexey Voronov on 16/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import MKMagneticProgress

class PointsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var decriptionLabel: UILabel!
    @IBOutlet weak var progressView: MKMagneticProgress!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = Config.Colors.background
        self.backgroundColor = Config.Colors.background
        self.titleLabel.textColor = Config.Colors.textFirst
        self.pointsLabel.textColor = Config.Colors.blue
        self.progressView.progressShapeColor = Config.Colors.blue
        self.progressView.backgroundShapeColor = Config.Colors.blue.withAlphaComponent(0.3)
        self.decriptionLabel.textColor = Config.Colors.textSecond
        self.progressView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(cdePoint: CdePoint) {
        pointsLabel.text = cdePoint.value + "/" + cdePoint.max
        titleLabel.text = cdePoint.variable
        decriptionLabel.text = "Необходимы порог: " + cdePoint.limit
        
        if titleLabel.text?.components(separatedBy: " ").contains("Семестр") ?? false {
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        } else if titleLabel.text?.components(separatedBy: " ").contains("Модуль") ?? false {
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        
        self.pointsLabel.textColor = Config.Colors.blue
        progressView.setProgress(progress: 0.0, animated: false)
        self.progressView.progressShapeColor = Config.Colors.blue
        self.progressView.backgroundShapeColor = Config.Colors.blue.withAlphaComponent(0.3)
        
        if let currentPoints = Float(cdePoint.value.replacingOccurrences(of: ",", with: ".") ) {
            if let maxPoints = Float(cdePoint.max.replacingOccurrences(of: ",", with: ".") ) {
                let progress = currentPoints / maxPoints
                progressView.setProgress(progress: CGFloat(progress), animated: false)
            }
            if let neededPoints = Float(cdePoint.limit.replacingOccurrences(of: ",", with: ".") ) {
                if currentPoints >= neededPoints {
                    self.progressView.progressShapeColor = Config.Colors.green
                    self.progressView.backgroundShapeColor = Config.Colors.green.withAlphaComponent(0.3)
                    self.pointsLabel.textColor = Config.Colors.green
                }
            }
        }
    }
}
