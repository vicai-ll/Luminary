//
//  TableCell.swift
//  Luminary
//
//  Created by Cai, Weiqi on 2/3/18.
//  Copyright © 2018 Cai, Weiqi. All rights reserved.
//

import Foundation
import UIKit


class TableCell : UITableViewCell {

    @IBOutlet weak var lineText: UITextView!
    
    // MARK: Cell Configuration
    func configurateTheCell(_ line: Line) {
        self.lineText?.text = line.text
        self.lineText.translatesAutoresizingMaskIntoConstraints = true
//        self.lineText.sizeToFit()
        self.lineText.isScrollEnabled = false
    }
}
