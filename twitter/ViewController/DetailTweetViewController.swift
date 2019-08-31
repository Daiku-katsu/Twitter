//
//  DetailTweetViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/13.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import SideMenu
import Kingfisher

class DetailTweetViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
     @IBOutlet var replyTextView:UITextView!
    var selectedPost = [Post]()
     var postId: String!
     var posts = [Post]()
     @IBOutlet var TweetTableView:UITableView!
    var comments = [Comment]()
    @IBOutlet var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TweetTableView.dataSource = self
        TweetTableView.delegate = self
        let nib = UINib(nibName: "TweetTableViewCell", bundle: Bundle.main)
        TweetTableView.register(nib, forCellReuseIdentifier: "Cell")
        TweetTableView.tableFooterView = UIView()
        
        loadTweet()
        setRefreshControl()
        commentTableView.dataSource = self
        commentTableView.tableFooterView = UIView()
        loadComments()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadTweet()
        loadComments()
    }
    @IBAction func back(){
        self.dismiss(animated: true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPost.count
        return comments.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")as!TweetTableViewCell
        //内容
     //   cell.delegate = self as! TweetTableTableViewCellDelegate
        cell.tag = indexPath.row
        
        let user = selectedPost[indexPath.row].user
        cell.userNameLabel.text = user.displayName
        let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/" + user.objectId
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.png"))
        
        cell.commentTextView.text = selectedPost[indexPath.row].text
        let imageUrl = selectedPost[indexPath.row].imageUrl
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
        
        // Likeによってハートの表示を変える
           if selectedPost[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
          } else {
             cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
          }
        
        // Likeの数
            cell.likeCountLabel.text = "\(selectedPost[indexPath.row].likeCount)件"
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //  cell.timestampLabel.text = posts[indexPath.row].createDate.string()
        
    /*   let cel = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let userImageView = cel.viewWithTag(1) as! UIImageView
        let userNameLabel = cel.viewWithTag(2) as! UILabel
        let commentLabel = cel.viewWithTag(3) as! UILabel
        // let createDateLabel = cell.viewWithTag(4) as! UILabel
        
        // ユーザー画像を丸く
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        let user = comments[indexPath.row].user
        let userImagePath = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/" + user.objectId
        userImageView.kf.setImage(with: URL(string: userImagePath))
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text */
        
        return cell
    //    return cel
    }
    func loadTweet() {
        let query = NCMBQuery(className: "Post")
        
        // 降順
        query?.order(byDescending: "createDate")
        
    //    query?.whereKey("user", equalTo: objectId)
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        // フォロー中の人 + 自分の投稿だけ持ってくる
        //   query?.whereKey("user", containedIn: followings)
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.selectedPost = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                         if likeUsers?.contains(NCMBUser.current().objectId) == true {
                         post.isLiked = true
                         } else {
                         post.isLiked = false
                         }
                         
                         // いいねの件数
                         if let likes = likeUsers {
                         post.likeCount = likes.count
                         }
                        
                        // 配列に加える
                        self.selectedPost.append(post)
                    }
                }
                // 投稿のデータが揃ったらTableViewをリロード
                self.TweetTableView.reloadData()
            }
            }
        )}
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        TweetTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        //    self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
       // query?.whereKey("postId", equalTo: postId)
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
                    
                    // 投稿の情報を取得
        //            let imageUrl = commentObject.object(forKey: "imageUrl") as! String
                    
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
    @IBAction func reply() {
        
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(replyTextView?.text, forKey: "text")
          let url = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/"
             object?.setObject(url, forKey: "imageUrl")
        
            object?.saveInBackground({ (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                    self.loadComments()
                }
            })
        }
    
}

