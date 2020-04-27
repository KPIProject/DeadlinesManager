//
//  ProjectAndDeadlineTableViewCell.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 27.04.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

class ProjectAndDeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var numberRightLabel: UILabel!
    @IBOutlet weak var numberView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        numberRightLabel.layer.cornerRadius = CGFloat((Double(numberRightLabel.frame.height) ) / 3.5)
        numberView.layer.cornerRadius = CGFloat((Double(numberView.frame.height) ) / 1.5)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        numberRightLabel.layer.cornerRadius = CGFloat((Double(numberRightLabel.frame.height) ) / 3.5)
        nameLabel.text = nil
        detailLabel.text = nil
        numberRightLabel.text = nil
//        numberView.
    }
    
}
