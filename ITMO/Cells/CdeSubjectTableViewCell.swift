//
//  CdeSubjectTableViewCell.swift
//  ITMO
//
//  Created by Alexey Voronov on 16/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import MultiProgressView

class CdeSubjectTableViewCell: UITableViewCell, MultiProgressViewDataSource {
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var progressView: MultiProgressView!
    @IBOutlet weak var gradientView: GradientView!
    
    func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let bar = ProgressViewSection()
        bar.backgroundColor = Config.Colors.blue
        return bar
    }
    
    func numberOfSections(in progressView: MultiProgressView) -> Int {
        return 1
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
    }

    func setup(cdeSubject: CdeSubject) {
        self.contentView.backgroundColor = Config.Colors.background
        self.backgroundColor = Config.Colors.background
        
        gradientView.topColor = Config.Colors.backgroundSecond
        gradientView.bottomColor = Config.Colors.backgroundThird
        
        titleLabel.textColor = Config.Colors.textFirst
        pointsLabel.textColor = Config.Colors.textFirst
        
        descriptionLabel.textColor = Config.Colors.textSecond
        progressView.backgroundColor = Config.Colors.blue
        
        progressView.dataSource = self
        
        //gradientView.applyShadow(apply: true, color: .black, offset: CGSize(width: 0, height: 5), opacity: 0.8, radius: 5, shadowRect: nil)
        //gradientView.layer.masksToBounds = false
        
        progressView.backgroundColor = Config.Colors.blue.withAlphaComponent(0.3)
        
        pointsLabel.text = cdeSubject.points.first?.value ?? "0"
        titleLabel.text = cdeSubject.name
        if cdeSubject.marks.first?.markdate != "" {
            descriptionLabel.text = "\(cdeSubject.marks.first?.mark ?? "")  \(cdeSubject.marks.first?.markdate ?? "")"
        } else {
            descriptionLabel.text = "\(cdeSubject.marks.first?.worktype ?? "")"
        }
        if let currentPoints = Float(cdeSubject.points.first?.value.replacingOccurrences(of: ",", with: ".") ?? "0") {
            progressView.setProgress(section: 0, to: currentPoints / 100)
            
            if currentPoints > 59 {
                gradientView.bottomColor = UIColor.blend(color1: Config.Colors.backgroundThird, intensity1: 0.8, color2: .orange, intensity2: 0.1)
            }
            if currentPoints > 74 {
                gradientView.bottomColor = UIColor.blend(color1: Config.Colors.backgroundThird, intensity1: 0.8, color2: .yellow, intensity2: 0.1)
            }
            if currentPoints > 90 {
                gradientView.bottomColor = UIColor.blend(color1: Config.Colors.backgroundThird, intensity1: 0.8, color2: .green, intensity2: 0.1)
            }
        }
    }
    
}
