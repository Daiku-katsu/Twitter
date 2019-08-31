//
//  ViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/07.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import SideMenu
import Kingfisher


class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,TweetTableTableViewCellDelegate{
    
    var selectedPost: Post?
    var posts = [Post]()
     var followings = [NCMBUser]()
    @IBOutlet var TweetTableView:UITableView!
    //  @IBOutlet var imageButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  UIBarButtonItem.layer.cornerRadius = UIBarButtonItem.bounds.width / 2.0
        // UIBarButtonItem.layer.masksToBounds = true
        
        TweetTableView.dataSource = self
        TweetTableView.delegate = self
        let nib = UINib(nibName: "TweetTableViewCell", bundle: Bundle.main)
        TweetTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        TweetTableView.tableFooterView = UIView()
        setRefreshControl()
        loadImage()
        loadTweet()
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
     //   loadFollowingUsers()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadImage()
        loadTweet()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSlideUser" {
            let replytViewController = segue.destination as! UserProfileViewController
            //        ReplyViewController.postId = selectedPost?.objectId
            if segue.identifier == "toReply" {
                let replytViewController = segue.destination as! ReplyViewController
        if segue.identifier == "toDetail" {
          //      let detailViewController = segue.destination as! DetailTweetViewController
         //   detailViewController.TweetTableView = sender as!UITableView
            let tweetViewController = segue.destination as! DetailTweetViewController
            tweetViewController.selectedPost = selectedPost
      //      let selectedIndex = searchUserTableView.indexPathForSelectedRow!
      //      showUserViewController.selectedUser = users[selectedIndex.row]
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: posts[indexPath.row])
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")as!TweetTableViewCell
        //内容
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = posts[indexPath.row].user
        cell.userNameLabel.text = user.displayName
        let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/" + user.objectId
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder"))
        
             cell.commentTextView.text = posts[indexPath.row].text
        let imageUrl = posts[indexPath.row].imageUrl
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
        
        // Likeによってハートの表示を変える
            if posts[indexPath.row].isLiked == true {
               cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
          } else {
             cell.likeButton.setImage(UIImage(named: "heart-outlin"), for: .normal)
          }
        
        // Likeの数
            cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //  cell.timestampLabel.text = posts[indexPath.row].createDate.string()
        
        return cell
    }
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        //オブジェクトが０だった時にログインへ戻れるように。
        guard let currentUser = NCMBUser.current() else {
            //ログインに戻る
            let storyboard = UIStoryboard(name:"SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            return
        }
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(currentUser.objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        self.loadTweet()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            self.loadTweet()
                        }
                    })
                }
            })
        }
    }
    
    func didTapimageButton(tableViewCell: UITableViewCell, button: UIButton) {
        performSegue(withIdentifier: "toSlideUser", sender: nil)
    }
    
   
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toReply", sender: nil)
    }
   
  /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReply" {
            let replytViewController = segue.destination as! ReplyViewController
            //        ReplyViewController.postId = selectedPost?.objectId
        }
    }*/
    
    //別の画面に遷移
    //  performSegue(withIdentifier: "toSlideUser", sender: nil)
    //  cell.isUserInteractionEnabled = true
    // タップ時イベント設定
    //    cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageViewTapped)))
    
    // タップ時処理で使用するためrowをtagに持たせておく
    //  cell.userImageView.tag = indexPath.row
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        //セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        //別の画面に遷移
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    
    
    func loadImage() {
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil{
                print(error)
            }else{
                if data != nil {
                    let image = UIImage(data: data!)
                    let resizedImage = self.resize(image: image!, width: 10)
                    //ナビゲーションバーボタンに画像を設定
                    let imageButtonImage = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.push))
                    self.navigationItem.leftBarButtonItem = imageButtonImage
                }
            }
            
        }
    }
    @objc func push() {
        self.performSegue(withIdentifier: "toSliderMenu", sender: nil)
    }
    
    func resize(image: UIImage, width: Double) -> UIImage {
        
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = image.size.height / image.size.width
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectScale))
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    /*   @objc func change() {
     self.performSegue(withIdentifier: "toSlideTweet", sender: nil)
     }
     @objc func touser() {
     self.performSegue(withIdentifier: "toSlideUser", sender: nil)
     }*/
    
    
    
    func loadTweet() {
        let query = NCMBQuery(className: "Post")
        
        // 降順
        query?.order(byDescending: "createDate")
        
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
                self.posts = [Post]()
                
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
                        self.posts.append(post)
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
  /*  func loadFollowingUsers() {
        // フォロー中の人だけ持ってくる
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.followings = [NCMBUser]()
                for following in result as! [NCMBObject] {
                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
                }
          //      self.followings.append(NCMBUser.current())
                
                self.loadTweet()
            }
        })
    }*/
}
