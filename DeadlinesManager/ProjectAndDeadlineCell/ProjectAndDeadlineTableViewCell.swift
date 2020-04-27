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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
