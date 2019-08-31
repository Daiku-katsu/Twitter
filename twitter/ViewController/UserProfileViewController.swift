//
//  UserProfileViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/13.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD

class UserProfileViewController: UIViewController {

    var selectedUser: NCMBUser!
    
    var followingInfo: NCMBObject?
    
    var posts = [Post]()
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var followButton: BorderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     photoCollectionView.dataSource = self
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: nil)as!NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil{
                print(error)
            }else{
                if data != nil {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //キャンセルボタン
    @IBAction func close(){
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func follow(){
    
    }
}



