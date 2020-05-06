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
    @IBOutlet weak var arrowView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = CGFloat((Double(numberView.frame.height) ) / 1.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        detailLabel.text = nil
        numberRightLabel.text = nil
    }
    
}
