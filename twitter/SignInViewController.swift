//
//  SignInViewController.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/07.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SignInViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var userIdTextField:UITextField!
    @IBOutlet var passwardTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField.delegate = self
        passwardTextField.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func SignIn(){
        
        if (userIdTextField.text?.count)! > 0 && (passwardTextField.text?.count)! > 0 {
            NCMBUser.logInWithUsername(inBackground: userIdTextField.text!, password: passwardTextField.text!) { (user, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    if user?.object(forKey: "active") as? Bool == false {
                        SVProgressHUD.setStatus("そのユーザーは退会済みです。")
                    } else {
                        // ログイン成功
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        // ログイン状態の保持
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                    }
                }
            }
        }
        }
    }

