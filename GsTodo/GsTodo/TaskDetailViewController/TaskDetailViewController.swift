//
//  TaskDetailViewController.swift
//  GsTodo
//
//  Created by Naoki Kameyama on 2020/06/12.
//  Copyright © 2020 yamamototatsuya. All rights reserved.
//

import UIKit
#warning("ここに PKHUD を import しよう！")
import PKHUD
import CoreLocation

/// タスク詳細を表示する画面
class TaskDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    /// タイトル
    @IBOutlet weak var titleTextField: UITextField!
    /// メモ
    @IBOutlet weak var memoTextView: UITextView!

    /// アクションボタン
    @IBOutlet weak var actionButton: UIButton!
    
    /// TaskListViewControllerからコピーしたtasksとindexPath
    //var tasks: [Task] = []
    
    var order:Order!
    /// 選択されたインデックス
    var selectIndex: Int?
    
    var locationManager:CLLocationManager?
    
    let locationAccuracy = kCLLocationAccuracyBest
    
    func configureOrder(){
        titleTextField.text = order?.orderId
        guard let products = order?.products else {return}
        guard let customerUserId = order?.customerUserId else {return}
        FirestoreService.readUserInfo(userId: customerUserId) { user in
            let address = user.address
            let name = user.name
            let phoneNum = user.phoneNum
            var totalPrice:Int = 0
            var detail = "住所:\(address)\n氏名:\(name)\n電話番号:\(phoneNum)"
            for product in products {
                print("\n ●\(product.name) \(product.orderNum)個")
                detail += "\n ●\(product.name) \(product.price)円 \(product.orderNum)個"
                totalPrice += product.price * product.orderNum
            }
            detail += "\n合計 \(totalPrice)円"
            self.memoTextView.text = detail
        }
        
        titleTextField.isUserInteractionEnabled = false
        memoTextView.isUserInteractionEnabled = false
        
    }

    /// メモを入力するUITextViewをセットアップ
    private func setupMemoTextView() {
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.layer.cornerRadius = 3
    }

    ///ナビゲーションバーをセットアップ
//    private func setupNavigationBar() {
//        title = "Task"
//        let rightButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(tapSaveButton))
//        navigationItem.rightBarButtonItem = rightButtonItem
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMemoTextView()
        //setupNavigationBar()

        /// 編集のときTask内容を表示させる
        //configureTask()
        configureOrder()
        
        setUpActionButton()
        
        FirestoreService.listenOrder(order: order!) { order in
            self.order = order
            self.setUpActionButton()
            if order.orderState == .delivered{
                ///配達されたらリスナーを切る
                print("deliverd and removeListener")
                FirestoreService.removeListener()
            }
        }
    }
    
    
    @IBAction func tapActionButton(_ sender: Any) {
        guard let order = order else {
            return
        }

        switch UserInfo.user.segment {
            ///購入者が開いた場合
        case .customer:
            print("customer")
            switch order.orderState {
                ///オーダーしたばかりのとき
            case .orderd:
                print("orderd")
                ///配達中のとき
            case .onDelivery:
                print("onDelivery")
                ///配達員の現在地を知るための地図を表示するビュー
                let mapVC = MapViewController()
                self.present(mapVC, animated: true, completion: nil)
                ///オーダーの状態を監視して、更新があれば位置情報をビューのプロパティに反映
                FirestoreService.listenOrder(order: order) { order in
                    mapVC.longitude = order.longitude
                    mapVC.latitude = order.latitude
                    print("location updated")
                }
            case .delivered:
                print("delivered")
            }
        case .staff:
            print("staff")
            switch order.orderState {
            case .orderd:
                ///【追記】Firestoreに記録 オーダーの状態を配達中に変える
                FirestoreService.updateOrder(order: order, orderState: .onDelivery, latitude: nil, longitude: nil)
                ///スタッフ自らの位置情報をFirestoreへ書き込み開始
                self.setUpLocationManager()
            case .onDelivery:
                print("Set up the map and confirm the location")
                self.locationManager?.stopUpdatingLocation()
                self.locationManager = nil
                ///Firestoreに記録
                FirestoreService.updateOrder(order: order, orderState: .delivered, latitude: nil, longitude: nil)
                
            case .delivered:
                print("delivered")
            }
        }
    }
    
    func setUpLocationManager(){
        ///位置情報取得のためのロケーションマネージャー
        self.locationManager = CLLocationManager()
        ///ユーザーに位置情報を利用する許可をリクエスト
        self.locationManager?.requestAlwaysAuthorization()
        ///許可のステータス
        let status = CLLocationManager.authorizationStatus()
        ///常に許可の場合
        if status == .authorizedAlways {
            ///ロケーションマネージャーのデリゲート先を自身に指定
            locationManager?.delegate = self
            ///位置情報の正確性に関する指定
            locationManager?.desiredAccuracy = locationAccuracy
            ///更新に必要な最小移動距離（1メートル）
            locationManager?.distanceFilter = 1
            ///位置情報の更新を開始
            locationManager?.startUpdatingLocation()
        }
    }
    
    ///CLLocationManagerのデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let order = order else {
            return
        }
        ///位置情報の配列の最初の要素を取得
        let location = locations.first
        ///緯度と経度を取得
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        print("latitude:\(String(describing: latitude)), longitude:\(longitude)")
        //Firestoreに記録
        ///【削除】
        //FirestoreService.updateOrder(order: order, orderState: .onDelivery, latitude: latitude, longitude: longitude)
        ///【追記】位置情報の更新分のみFirestoreに記録
        FirestoreService.updateLocationOfOrder(order: order, latitude: latitude, longitude: longitude)
    }
    
    func setUpActionButton(){
        guard let order = order else {
            return
        }
        
        switch UserInfo.user.segment {
        case .customer:
            print("customer")
            switch order.orderState {
            case .orderd:
                self.actionButton.setTitle("準備中", for: UIControl.State.normal)
                self.actionButton.backgroundColor = .blue
                self.actionButton.isUserInteractionEnabled = false
            case .onDelivery:
                self.actionButton.setTitle("現在地を確認", for: UIControl.State.normal)
                self.actionButton.backgroundColor = .orange
            case .delivered:
                self.actionButton.setTitle("配送済み", for: UIControl.State.normal)
                self.actionButton.backgroundColor = .lightGray
                self.actionButton.isUserInteractionEnabled = false
            }
        case .staff:
            print("staff")
            switch order.orderState {
            case .orderd:
                self.actionButton.setTitle("配達を開始する", for: UIControl.State.normal)
                self.actionButton.backgroundColor = .blue
            case .onDelivery:
                self.actionButton.setTitle("配達を終える", for: UIControl.State.normal)
                self.actionButton.backgroundColor = .orange
            case .delivered:
                self.actionButton.setTitle("配送済み", for: UIControl.State.normal)
                self.actionButton.backgroundColor = .lightGray
                self.actionButton.isUserInteractionEnabled = false
            }
        }
    }
    
    ///選択されたインデックスの情報をもとにタスクを取得し、タイトル、メモ表示に利用する
    #warning("ここにEditかどうかの判定を入れる")
//    private func configureTask() {
//        if let index = selectIndex {
//            titleTextField.text = tasks[index].title
//            memoTextView.text = tasks[index].memo
//        }
//    }

    ///Saveボタンを押したときの処理
//    @objc func tapSaveButton() {
//        print("Saveボタンを押したよ！")
//
//        guard let title = titleTextField.text, let index = selectIndex else {
//            return
//        }
//
//        #warning("titleが空白のときのエラー処理")
//        /// titleが空白のときのエラー処理
//        if title.isEmpty {
//            print(title, "👿titleが空っぽだぞ〜")
//            HUD.flash(.labeledError(title: nil, subtitle: "👿 タイトルが入力されていません！！！"), delay: 1)
//            /// showAlert("👿 タイトルが入力されていません！！！")
//            return /// return を実行すると、このメソッドの処理がここで終了する。
//        }
//
//        #warning("ここにEditかどうかの判定を入れる")
//        /// Edit
//        tasks[index] = Task(title: title, memo: memoTextView.text)
//        UserDefaultsRepository.saveToUserDefaults(tasks)
//
//        HUD.flash(.success, delay: 0.3)
//        /// 前の画面に戻る
//        navigationController?.popViewController(animated: true)
//    }

    /// アラートを表示するメソッド
    func showAlert(_ text: String){
        let alertController = UIAlertController(title: "エラー", message: text , preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
