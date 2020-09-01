//
//  Cell+SelectionStyle.swift
//  ITMO
//
//  Created by Alexey Voronov on 06/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

extension UITableViewCell {
    override open func awakeFromNib() {
        selectionStyle = .none
    }
}
