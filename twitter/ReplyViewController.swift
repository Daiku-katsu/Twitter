//
//  ReplyViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/18.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class ReplyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var replyTextView:UITextView!
     var postId: String!
    var comments = [Comment]()
    
    @IBOutlet var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        commentTableView.dataSource = self
        
   //     commentTableView.tableFooterView = UIView()
        
        loadComments()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let userImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let commentLabel = cell.viewWithTag(3) as! UILabel
        // let createDateLabel = cell.viewWithTag(4) as! UILabel
        
        // ユーザー画像を丸くする
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        let user = comments[indexPath.row].user
        let userImagePath = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/" + user.objectId
        userImageView.kf.setImage(with: URL(string: userImagePath))
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text
        
        return cell
    }
    
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    
                    // Commentクラスに格納　　　//postIdはどうやったら取得できるのか。NCMBへpostIdが入っていない。。
                    
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
        })
    }
    @IBAction func ReplyTweet(){
        // 画像アップロードが成功
        let postObject = NCMBObject(className: "Post")
        
        if self.replyTextView.text.count == 0 {
            print("入力されていません")
            return
        }
        postObject?.setObject(self.replyTextView.text!, forKey: "text")
        postObject?.setObject(NCMBUser.current(), forKey: "user")
        let url = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/"
        
        postObject?.setObject(url, forKey: "imageUrl")
        postObject?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                SVProgressHUD.dismiss()
                
                //次投稿する時のためnilにしている
            //    self.postImageView.image = nil
            //    self.postImageView.image = UIImage(named: "photo-placeholder")
                self.replyTextView.text = nil
                self.tabBarController?.selectedIndex = 0
                self.dismiss(animated: true, completion: nil)
                //     self.navigationController?.popViewController(animated: true)
                //   self.presentingViewController?.presentingViewController?.dismiss(animated: true
                //         ,completion: nil)
                
            }
            
        })
    }
    @IBAction func cancel(){
        dismiss(animated: true, completion: nil)
    }
}
