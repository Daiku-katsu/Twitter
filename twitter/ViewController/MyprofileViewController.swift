//
//  MyprofileViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/09.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD

class MyprofileViewController: UIViewController{
    
    var posts = [Post]()
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIdTextField: UITextField!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var birthdayLabel:UILabel!
    @IBOutlet var PlaceLabel:UILabel!
    
    override func viewDidLoad() {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        super.viewDidLoad()
    }
    //キャンセルボタン
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
        
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
        if let user = NCMBUser.current() {
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroductionTextView.text = user.object(forKey: "introduction") as? String
            birthdayLabel.text = user.object(forKey:"birthday")as? String
            PlaceLabel.text = user.object(forKey: "Place")as?String
            self.navigationItem.title = user.userName
}
    func loadPost() {
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // 投稿の情報を取得
                    let imageUrl = postObject.object(forKey: "imageUrl") as! String
                    let text = postObject.object(forKey: "text") as! String
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUser = postObject.object(forKey: "likeUser") as? [String]
                    if likeUser?.contains(NCMBUser.current().objectId) == true {
                        post.isLiked = true
                    } else {
                        post.isLiked = false
                    }
                    // 配列に加える
                    self.posts.append(post)
                }
        //        self.photoCollectionView.reloadData()
                
                // post数を表示
        //        self.postCountLabel.text = String(self.posts.count)
            }
        })
    }
}
}
