//
//  UserInfoRegisterViewController.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/02.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

/// ユーザーの詳細情報登録画面
class UserInfoRegisterViewController: UIViewController,UITextFieldDelegate {
    
    /// 名前入力のテキストフィールド
    @IBOutlet weak var nameTextField: UITextField!
    
    /// 電話番号入力のテキストフィールド
    @IBOutlet weak var phoneTextField: UITextField!
    
    /// 住所入力のテキストフィールド
    @IBOutlet weak var addressTextField: UITextField!
    
    /// ユーザーのセグメントの選択欄
    @IBOutlet weak var userSegmentControl: UISegmentedControl!
    
    ///Firestoreのインスタンス
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///UITextFieldのdelegate先を自らに指定
        nameTextField.delegate = self
        phoneTextField.delegate = self
        addressTextField.delegate = self
    }
    
    /// ユーザー情報登録ボタン
    /// - Parameter sender: ボタン
    @IBAction func tapRegisterButton(_ sender: Any) {
        ///ユーザーID、名前、電話番号、住所をアンラップ
        guard let userId = Auth.auth().currentUser?.uid , let name = nameTextField.text, let phone = phoneTextField.text, let address = addressTextField.text else {return}
        ///電話番号をInt型にキャストし、アンラップ
        guard let phoneNum = Int(phone) else {return}
        ///ユーザーに選択されたもの
        let selectedSegment = userSegmentControl.selectedSegmentIndex
        ///選択されたものによってユーザー区分を代入
        var segment:UserSegment!
        switch selectedSegment {
        case 0:
            segment = .customer
        case 1:
            segment = .staff
        default:
            segment = .customer
        }
        ///ユーザー自身のemailをアンラップ
        guard let email = Auth.auth().currentUser?.email else {return}
        
        let user = User(userId: userId, name: name, phoneNum: phoneNum, address: address, segment: segment, email: email)
        
        do {
            ///エンコードしてFirestoreに書き込みできる形に変換
        let encodedData = try Firestore.Encoder().encode(user)
            ///FirestoreでCreate処理
            db.collection("users").document(userId).setData(encodedData) { err in
                if let err = err {
                    ///書き込みに失敗
                    print("error:\(err)")
                } else {
                    ///書き込みに成功
                    ///このビューの2つ下層にあるViewControllerであるTabBarControllerを参照
                    let tabBarController = self.presentingViewController?.presentingViewController as! UITabBarController
                    ///TabBarControllerに紐づいているViewController群の1つであるNavigationControllerを参照
                    let navigationController = tabBarController.viewControllers![0]as!UINavigationController
                    ///NavigationControllerに紐づいているViewController群の1つであるTaskListViewControllerを参照
                    let vc = navigationController.viewControllers[0]as!TaskListViewController
                    ///ViewDidLoadメソッドを呼び出し
                    vc.viewDidLoad()
                    ///presentingViewControllerはLoginViewController。LoinViewControllerのpresentingViewControllerがdismissを呼び出し
                    ///2つ重なってる画面の元の画面に戻るイメージ
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        } catch {
            print("error encoding:\(error)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
