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
    @IBOutlet weak var profileButton: UIButton!
    
    var pod: Pod! {
        didSet {
            profileButton.layer.cornerRadius = 15
            profileButton.layer.masksToBounds = true
            titleLabel.text = pod.title
            authorLabel.text = pod.displayName
            lengthLabel.text = pod.timeString
        }
    }
    
    
    
}
