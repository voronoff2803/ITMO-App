//
//  UIViewController+LoadIndicator.swift
//  ITMO X
//
//  Created by Alexey Voronov on 13/05/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func loadIndicator(show: Bool, _ ignoreTable: Bool = false) {
        DispatchQueue.main.async {
            let tableView = self.view as? UITableView
            let count = tableView?.numberOfRows(inSection: 0) ?? 0

            if (show && count == 0) || ignoreTable {
                var offset: CGFloat = 0.0
                if let tableView = self.view as? UITableView {
                    offset = tableView.contentOffset.y
                    if offset < 0 {
                        offset = 0
                    }
                }
                self.view.isUserInteractionEnabled = false
                let back = UIView(frame: self.view.frame)
                back.transform = CGAffineTransform(translationX: 0, y: offset)
                back.backgroundColor = Config.Colors.background
                let indicator = UIActivityIndicatorView()
                indicator.center = CGPoint(x: back.frame.width/2, y: back.frame.height/2 - 50)
                
                back.addSubview(indicator)
                self.view.addSubview(back)
                indicator.startAnimating()
                back.layer.zPosition = 10
                back.tag = 10
            } else {
                self.view.subviews.filter() {$0.tag == 10}.forEach() {$0.removeFromSuperview()}
                self.view.isUserInteractionEnabled = true
            }
        }
    }
}
