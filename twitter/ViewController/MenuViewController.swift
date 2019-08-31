//
//  MenuViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/08.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import SVProgressHUD


class MenuViewController: UIViewController,UIImagePickerControllerDelegate{
    
    @IBOutlet weak var menuView:UIView!
    @IBOutlet var userImageView:UIImageView!
    
    override func viewDidLoad() {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
   
    @IBAction func tapProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メニューの位置を取得する
        let menuPos = self.menuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅の分だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
        },
            completion: { bool in
        })
        
        loadImage()
    }
    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
    
    @IBAction func profileTap() {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    func loadImage() {
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: nil) as! NCMBFile
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
}
