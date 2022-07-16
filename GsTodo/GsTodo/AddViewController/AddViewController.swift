//
//  AddViewController.swift
//  GsTodo
//
//  Created by NaokiKameyama on 2020/05/6.
//  Copyright © 2020 NaokiKameyama. All rights reserved.
//

import UIKit
#warning("ここに PKHUD を import しよう！")
import PKHUD

/// タスク追加のための画面
class AddViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!

    /// TaskListViewControllerからコピーしたtasks
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMemoTextView()
        setupNavigationBar()
    }
    
    ///メモを入力するUITextViewをセットアップする
    private func setupMemoTextView() {
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.layer.cornerRadius = 3
    }
    
    ///ナビゲーションバーをセットアップする
    private func setupNavigationBar() {
        title = "Add"
        let rightButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(tapSaveButton))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    
    ///Saveボタンを押したときの処理
    @objc func tapSaveButton() {
        print("Saveボタンを押したよ！")
        
        guard let title = titleTextField.text else {
            return
        }

        #warning("titleが空白のときのエラー処理")
        // titleが空白のときのエラー処理
        if title.isEmpty {
            print(title, "👿titleが空っぽだぞ〜")
            HUD.flash(.labeledError(title: nil, subtitle: "👿 タイトルが入力されていません！！！"), delay: 1)
            // showAlert("👿 タイトルが入力されていません！！！")
            return // return を実行すると、このメソッドの処理がここで終了する。
        }

        #warning("tasksにtaskを追加する処理")
        // tasksにAddする処理
        let task = Task(title: title, memo: memoTextView.text)
        tasks.append(task)
        UserDefaultsRepository.saveToUserDefaults(tasks)

        HUD.flash(.success, delay: 0.3)
        // 前の画面に戻る
        navigationController?.popViewController(animated: true)
    }

    #warning("アラートを表示するメソッド")
    /// アラートを表示するメソッド
    func showAlert(_ text: String){
        let alertController = UIAlertController(title: "エラー", message: text , preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
}
