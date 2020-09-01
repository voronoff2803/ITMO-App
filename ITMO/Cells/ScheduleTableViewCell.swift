//
//  ScheduleTableViewCell.swift
//  ITMO
//
//  Created by Alexey Voronov on 16/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var borderGradientView: GradientView!
    @IBOutlet weak var gradientView: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(subject: ScheduleSubject) {
        self.contentView.backgroundColor = Config.Colors.background
        self.backgroundColor = Config.Colors.background
        gradientView.topColor = Config.Colors.backgroundSecond
        gradientView.bottomColor = Config.Colors.backgroundThird
        
        titleLabel.textColor = Config.Colors.textFirst
        startTimeLabel.textColor = Config.Colors.textFirst
        
        placeLabel.textColor = Config.Colors.textSecond
        endTimeLabel.textColor = Config.Colors.textSecond
        statusLabel.textColor = Config.Colors.textSecond
        
        startTimeLabel.text = subject.start_time
        endTimeLabel.text = subject.end_time
        if subject.gr == "" {
            statusLabel.text = subject.status
        } else {
            statusLabel.text = subject.gr + "  " + subject.status
        }
        titleLabel.text = subject.title
        if subject.room == "" {
            self.placeLabel.text = subject.place
        } else {
            self.placeLabel.text = "Ауд. " + subject.room + ", " + subject.place
        }
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let currentTimeInt = hour * 100 + minutes
        let startTimeInt = Int(subject.start_time.replacingOccurrences(of: ":", with: ""))! - 10
        let endTimeInt = Int(subject.end_time.replacingOccurrences(of: ":", with: ""))!
        borderGradientView.isHidden = true
        if Helper.normalWeekDay(calendar.component(.weekday, from: date)) == subject.data_day {
            if (startTimeInt <= currentTimeInt && currentTimeInt <= endTimeInt) {
                borderGradientView.isHidden = false
                
                if endTimeInt - 30 < currentTimeInt  {
                    borderGradientView.startPointX = 1.1
                    borderGradientView.endPointX = 0.2
                } else if startTimeInt + 40 > currentTimeInt {
                    borderGradientView.startPointX = -0.1
                    borderGradientView.endPointX = 0.8
                } else {
                    borderGradientView.startPointX = 4.0
                    borderGradientView.endPointX = -10.0
                }
            }
        }
        
        //self.borderGradientView.alpha = 0.0
        //UIView.animate(withDuration: 0.8) { self.borderGradientView.alpha = 1.0}
    }
    
}
