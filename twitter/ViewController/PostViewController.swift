//
//  PostViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/12.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import UITextView_Placeholder
import NYXImagesKit

class PostViewController: UIViewController, UINavigationControllerDelegate,UITextViewDelegate,UIImagePickerControllerDelegate  {

    let placeholderImage = UIImage(named: "photo-placeholder")
    var resizedImage: UIImage!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        super.viewDidLoad()
        
        postImageView.image = placeholderImage
        postButton.isEnabled = false
        postTextView.placeholder = "キャプションを書く"
        postTextView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.5)
        
        postImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
    }
    //postのtextViewが150字以上なら表示できないように。
    func textViewDidChange(_ textView: UITextView) {
        let beforeStr: String = postTextView.text // 文字列をあらかじめ取得しておく
        if postTextView.text.count > 150 { // 150字を超えた時
            // 以下，範囲指定する
            let zero = beforeStr.startIndex
            let start = beforeStr.index(zero, offsetBy: 0)
            let end = beforeStr.index(zero, offsetBy: 150)
            postTextView.text = String(beforeStr[start...end])
        }
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    // 画像を選択する
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択して下さい。", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func Tweet() {
        SVProgressHUD.show()
        
        // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = resizedImage.pngData()
        // ここを変更（ファイル名無いので）
        let file = NCMBFile.file(with: data) as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 画像アップロードが成功
                let postObject = NCMBObject(className: "Post")
                
                if self.postTextView.text.count == 0 {
                    print("入力されていません")
                    return
                }
                postObject?.setObject(self.postTextView.text!, forKey: "text")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                let url = "https://mb.api.cloud.nifty.com/2013-09-01/applications/tXwQtNaLb9632QwL/publicFiles/" + file.name
                
                postObject?.setObject(url, forKey: "imageUrl")
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        SVProgressHUD.dismiss()
                        
                        //次投稿する時のためnilにしている
                        self.postImageView.image = nil
                        self.postImageView.image = UIImage(named: "photo-placeholder")
                        self.postTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                        self.dismiss(animated: true, completion: nil)
                    //    self.navigationController?.popViewController(animated: true)
                    //   self.presentingViewController?.presentingViewController?.dismiss(animated: true,completion: nil)
                        
                    }
                    
                })
            }
        }) { (progress) in
            print(progress)
        }
        
    }
    
    func confirmContent() {
        if postTextView.text.count > 0 && postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
     //    self.navigationController?.popViewController(animated: true)
       dismiss(animated: true, completion: nil)
    //  self.navigationController?.popViewController(animated: true)
}
}

