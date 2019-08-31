//
//  MyProfileEditViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/09.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import SVProgressHUD
import RxSwift
import RxCocoa

class MyProfileEditViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameTextField:UITextField!
    @IBOutlet var userPhotoImageView:UIImageView!
    @IBOutlet var PlaceTextField:UITextField!
    @IBOutlet var introductionTextView: UITextView!
    @IBOutlet var birthbayTextField:UITextField!
    
    @IBOutlet var userButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    var resizedImage: UIImage!
    
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        userNameTextField.delegate = self
        PlaceTextField.delegate = self
        introductionTextView.delegate = self
        birthbayTextField.delegate = self
        
        userPhotoImageView.image = placeholderImage
        
        //UserIdは書いていない(MyProfileの方で書く)
        if let user = NCMBUser.current() {
            userNameTextField.text = user.object(forKey: "displayName") as? String
            PlaceTextField.text = user.object(forKey: "Place") as? String
            birthbayTextField.text = user.object(forKey: "birthday") as? String
            introductionTextView.text = user.object(forKey: "introduction") as? String
            
            //疑問ー＞　objectIdってなにと紐づいている？
            
            let file = NCMBFile.file(withName: user.objectId,data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil {
                    //  let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
                    // let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    //})
                    // alert.addAction(okAction)
                    // self.present(alert, animated: true, completion: nil)
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        var resizedImage = resize(image: selectedImage, width: 100)
        selectedImage.scale(byFactor: 0.5)
        picker.dismiss(animated: true, completion: nil)
        // 追加(PostViewControllerから)
        resizedImage = selectedImage.scale(byFactor: 0.7)
        
        let data = resizedImage.pngData()
        let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: data) as! NCMBFile
        
        //ユーザボタンのタップを検知
        self.userButton.rx.tap.subscribe(onNext: { [weak self] in
            file.saveInBackground({ (error) in
                if error != nil {
                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    })
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.userImageView.image = resizedImage
                    print(resizedImage)
                }
            }) { (progress) in
                print(progress)
            }
        }).disposed(by: self.disposeBag)
        
        //背景ボタンのタップを検知
        self.backButton.rx.tap.subscribe(onNext: { [weak self] in
            file.saveInBackground({ (error) in
                if error != nil {
                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
        
                    })
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.userPhotoImageView.image = resizedImage
                    print(resizedImage)
                }
            }) { (progress) in
                print(progress)
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    
    //画像を選択した時に呼ばれるアクション
    @IBAction func selectdImage() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択して下さい", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
    }
    //背景画像を選択した時に呼ばれるアクション(HomeImage)
    @IBAction func selectdBackImage() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択して下さい", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
    }
    
    //キャンセルボタン
    @IBAction func closeEditViewController(){
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func saveUserInfo(){
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text, forKey: "displayName")
        user?.setObject(introductionTextView.text, forKey: "introduction")
        user?.setObject(birthbayTextField.text, forKey: "birthday")
        user?.setObject(PlaceTextField.text, forKey: "Place")
        
        user?.saveInBackground({ (error) in
            if error != nil {
                let alert = UIAlertController(title: "送信エラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
}

