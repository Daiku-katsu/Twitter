//
//  TweetTableViewCell.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/07.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit

protocol TweetTableTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapimageButton(tableViewCell: UITableViewCell, button: UIButton)
 //   func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}

class TweetTableViewCell: UITableViewCell{

    var delegate: TweetTableTableViewCellDelegate?
    
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameLabel:UILabel!
    @IBOutlet var photoImageView:UIImageView!
    @IBOutlet var likeButton:UIButton!
    @IBOutlet var likeCount:UIButton!
    @IBOutlet var likeCountLabel:UILabel!
    @IBOutlet var commentTextView:UITextView!
    @IBOutlet var timestampLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.bounds.width/2.0
        userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
       @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
  /*  @IBAction func openMenu(button: UIButton) {
    self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }*/
    @IBAction func image(button: UIButton) {
        self.delegate?.didTapimageButton(tableViewCell: self, button: button)
    }
    
    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    
}
