//
//  PodCommentTableViewCell.swift
//  PodMe
//
//  Created by Phillip  Tracy on 12/2/21.
//

import UIKit

class PodCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var commentPlayButton: UIButton!
    
    var comment: Comment! {
        didSet {
            commentTitleLabel.text = comment.commentTitle
            authorNameLabel.text = comment.displayName
            lengthLabel.text = comment.timeString
        }
    }
    
    
    @IBAction func commentPlayButtonPressed(_ sender: UIButton) {
    }
    

}
