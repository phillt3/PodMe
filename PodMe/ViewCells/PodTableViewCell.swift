//
//  PodTableViewCell.swift
//  PodMe
//
//  Created by Phillip  Tracy on 11/4/21.
//

import UIKit

class PodTableViewCell: UITableViewCell {
    //MARK: POD Cell Outlests
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    
    //MARK: Catcher variable that upon Pod creation, save, and return to view controller, updates cell UI
    var pod: Pod! {
        didSet {
            titleLabel.text = pod.title
            authorLabel.text = pod.displayName
            lengthLabel.text = pod.timeString
        }
    }
    
}
