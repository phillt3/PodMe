//
//  PodTableViewCell.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/4/21.
//

import UIKit

class PodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var lengthLabel: UILabel!
    var profile: Profile!
    var pod: Pod! {
        didSet {
            titleLabel.text = pod.title
            authorLabel.text = profile.displayName
            lengthLabel.text = pod.timeString
        }
    }
}
