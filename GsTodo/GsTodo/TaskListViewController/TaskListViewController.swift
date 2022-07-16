//
//  TaskListViewController.swift
//  GsTodo
//
//  Created by NaokiKameyama on 2020/05/6.
//  Copyright © 2020 NaokiKameyama. All rights reserved.
//

import UIKit
import FirebaseAuth

/// Task群をリスト表示するための画面
class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    /// task情報の一覧。ここに全ての情報を保持しています！
    //var tasks: [Task] = []
    var orders:[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isLogin() == true{
            ///ログイン状態のときはスキップ
            ///ログインユーザーIDとログインユーザーのemailも取得できる
            print("\(String(describing: Auth.auth().currentUser?.uid)):ログインユーザーのユーザーID")
            print("\(String(describing: Auth.auth().currentUser?.email)):ログインユーザーのemail")
        } else {
            ///まだログインしていないときはログイン画面表示
            self.presentLoginViewController()
        }
        
        /// tableViewのお約束その１。この ViewController で delegate のメソッドを使うために記述している。
        tableView.delegate = self
        /// tableViewのお約束その２。この ViewController で datasouce のメソッドを使うために記述している。
        tableView.dataSource = self

        /// CustomCellの登録。忘れがちになるので注意！！
        /// nibの読み込み。nib と xib はほぼ一緒
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        /// tableView に使う xib ファイルを登録している。
        tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        
        setupNavigationBar()
        
        guard let userId = Auth.auth().currentUser?.uid else {return}
        ///ユーザー情報を読み込み
        FirestoreService.readUserInfo(userId:userId) { user in
            ///ユーザー情報をアプリ内でいつでも参照できる形にする
            UserInfo.user = user
            ///ユーザーの区分によって場合分け
            switch UserInfo.user.segment {
            case .customer:
                print("is customer")
                ///自らのオーダー群を監視
                FirestoreService.listenMyOrders { orders in
                    self.orders = orders
                    self.reloadTableView()
                }
            case .staff:
                print("is staff")
                ///全てのオーダー群を監視
                FirestoreService.listenAllOrders { orders in
                    self.orders = orders
                    self.reloadTableView()
                }
            }
        }
    }

    #warning("画面描画のたびにtableViewを更新")
    /// 画面描画のたびにtableViewを更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("👿viewWillAppearが呼ばれたよ")
        // UserDefaultsから読み出し
        //tasks = UserDefaultsRepository.loadFromUserDefaults()
        //dump(tasks)
        //reloadTableView()
    }
    ///ログイン認証されているかどうかを判定する関数
    func isLogin() -> Bool{
        ///ログインしているユーザーがいるかどうかを判定
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    ///ログイン画面を表示
    func presentLoginViewController(){
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: false, completion: nil)
    }

    #warning("navigation barのボタン追加")
    /// navigation barの設定
    private func setupNavigationBar() {
        //let rightButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddScreen))
        //navigationItem.rightBarButtonItem = rightButtonItem
        ///画面上部のナビゲーションバーの左側にログアウトボタンを設置し、押されたらlogOut関数が走るように設定
        let leftButtonItem = UIBarButtonItem(title: "ログアウト", style: .done, target: self, action: #selector(logOut))
        navigationItem.leftBarButtonItem = leftButtonItem
    }
    
    ///ログアウト処理
    @objc func logOut(){
        do{
        try Auth.auth().signOut()
            ///監視を一度リセットする（そうしないと、アカウントを切り替えても以前のアカウントの監視が残ったままになってしまう）
            FirestoreService.removeListeners()
            ///ログアウトに成功したら、ログイン画面を表示
            self.presentLoginViewController()
        } catch let signOutError as NSError{
            print("サインアウトエラー:\(signOutError)")
        }
    }

    #warning("navigation barのボタンをタップしたときの動作")
    /// navigation barのaddボタンをタップされたときの動作
    @objc func showAddScreen() {
        let vc = AddViewController()
        //vc.tasks = tasks
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UITableView
    /// 1つの Section の中の Row　の数を定義する(セルの数を定義)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    ///セルを生成する処理
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// 登録したセルを使う。 as! CustomCell としないと、UITableViewCell のままでしか使えない。
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.titleLabel?.text = "注文番号:\(orders[indexPath.row].orderId)"
        ///オーダーの作成日時
        let createdDate = orders[indexPath.row].createdAt
        ///Date型をString型に変換するためのインスタンス
        let dateFormatter = DateFormatter()
        ///どのような形式に変換するかを指定
        dateFormatter.dateFormat = "yyyy年M月d日(EEEEE) H時m分s秒"
        let dateString = dateFormatter.string(from: createdDate)
        cell.dateLabel.text = dateString
        ///注文の状態
        let state = orders[indexPath.row].orderState
        switch state {
        case .orderd:
            cell.stateLabel.text = "注文済み"
            cell.stateLabel.backgroundColor = .blue
        case .onDelivery:
            cell.stateLabel.text = "配達中"
            cell.stateLabel.backgroundColor = .orange
        case .delivered:
            cell.stateLabel.text = "配達完了"
            cell.stateLabel.backgroundColor = .lightGray
        }
        cell.stateLabel.textColor = .white
        return cell
    }
    
    #warning("ここにタップした時の処理を入れる")
    ///選択時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TaskDetailViewController()
        vc.selectIndex = indexPath.row
        vc.order = self.orders[indexPath.row]
        //vc.tasks = tasks
        navigationController?.pushViewController(vc, animated: true)
    }
    
#warning("ここにスワイプして削除する時の処理を入れる")
    /// 削除時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //tasks.remove(at: indexPath.row)
        //UserDefaultsRepository.saveToUserDefaults(tasks)
        //reloadTableView()
    }
    
    ///セルの高さを指定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    /// テーブルビューをリロード
    func reloadTableView() {
        tableView.reloadData()
    }
}
