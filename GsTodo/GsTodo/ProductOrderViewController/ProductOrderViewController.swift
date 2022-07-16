//
//  ProductPurchaseViewController.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/04.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import UIKit

/// 商品をオーダーするためのビュー
class ProductOrderViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    ///商品群を表示するコレクションビュー
    @IBOutlet weak var collectionView: UICollectionView!
    
    ///注文ボタン
    @IBOutlet weak var orderButton: UIButton!
    
    ///合計金額表示ラベル
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    
    ///表示する商品群
    let products:[Product] = [
        Product(name: "ブルーチーズ", thumbnailName: "blue_cheese", price: 1000),
        Product(name: "カマンベールチーズ", thumbnailName: "camembert_cheese", price: 1100),
        Product(name: "モッツアレラチーズ", thumbnailName: "mozzarella_cheese", price: 800),
        Product(name: "チェダーチーズ", thumbnailName: "cheddar_cheese", price: 700)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///コレクションビューをセットアップ
        setUpCollectionView()
        // Do any additional setup after loading the view.
    }
    
    
    /// リセットボタン押下時の処理
    /// - Parameter sender: ボタンアクション
    @IBAction func tapResetButton(_ sender: Any) {
        ///リセット
        resetOrder()
    }
    
    
    /// オーダーボタン押下時の処理
    /// - Parameter sender: ボタンアクション
    @IBAction func tapOrderButton(_ sender: Any) {
        FirestoreService.createOrder(products: self.products) { order in
            ///オーダー情報の書き込み完了後の処理
            let address = UserInfo.user.address
            let name = UserInfo.user.name
            let phoneNum = UserInfo.user.phoneNum
            var totalPrice:Int = 0
            var detail = "住所:\(address)\n氏名:\(name)\n電話番号:\(phoneNum)"
            for product in order.products {
                print("\n ●\(product.name) \(product.orderNum)個")
                detail += "\n ●\(product.name) \(product.price)円 \(product.orderNum)個"
                totalPrice += product.price * product.orderNum
            }
            detail += "\n合計 \(totalPrice)円"
            //お店側へのメール通知
            FirestoreService.sendEmail(to: "motonao21@gmail.com", subject: "オーダーが入りました", text: detail)
            ///UIから選択を解除
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                self.resetOrder()
            }
        }
    }
    
    /// コレクションビューの設定
    func setUpCollectionView(){
        ///デリゲート先を自身に設定
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        ///セルを登録
        let nib = UINib(nibName: "CustomCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        
        ///レイアウトを設定
        let layout = UICollectionViewFlowLayout()
        ///端末の画面の横幅いっぱいのサイズの半分
        let halfSize = UIScreen.main.bounds.size.width / 2
        ///1つのセルのサイズの横幅、縦幅を設定
        layout.itemSize = CGSize(width: halfSize, height: halfSize)
        ///セル同士の横の間隔の長さ
        layout.minimumInteritemSpacing = 0
        ///セル同士の縦の間隔の長さ
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
    }
    
    
    /// 選択しているオーダー情報をリセット
    func resetOrder(){
        print("reset order")
        ///それぞれのプロダクトのオーダー数を0にする
        for product in products {
            product.orderNum = 0
        }
        ///オーダーボタンの背景色を変える
        orderButton.backgroundColor = .lightGray
        ///オーダーボタンを押せなくする
        orderButton.isUserInteractionEnabled = false
        ///コレクションビューをリロード
        collectionView.reloadData()
        ///合計金額のラベルの値を空にする
        self.totalPriceLabel.text = ""
    }
    
    ///要素の個数を返すデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ///商品の個数
        return products.count
    }
    
    ///セルを返すデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        ///セルはカスタムセル
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath)as!CustomCollectionViewCell
        ///イメージにサムネイル画像を代入
        cell.imageView.image = UIImage(named: products[indexPath.row].thumbnailName)
        ///名前ラベルに商品名を代入
        cell.nameLabel.text = products[indexPath.row].name
        ///価格ラベルに価格を代入
        cell.priceLabel.text = "\(products[indexPath.row].price)円"
        ///その商品をオーダーがある場合とない場合で場合分け
        if products[indexPath.row].orderNum != 0 {
            ///オーダーがある場合は背景色をライトグレーにする
            cell.backgroundColor = .lightGray
            cell.orderNumLabel.text = String(products[indexPath.row].orderNum)
            cell.orderNumLabel.textColor = .black
        } else {
            ///オーダーがないときは背景色を白にする
            cell.backgroundColor = .white
            cell.orderNumLabel.text = ""
        }
        
        return cell
    }
    
    ///セルを選択した際のデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if UserInfo.user.segment == .customer {
            //セグメントがカスタマーの時のみオーダーボタンを押下できるようにする
            ///オーダーボタンをオレンジにする
            orderButton.backgroundColor = .orange
            ///オーダーボタンを押せるようにする
            orderButton.isUserInteractionEnabled = true
        }
        
        ///そのセルに対応する商品のオーダー個数を1つ追加する
        self.products[indexPath.row].orderNum += 1
        
        ///コレクションビューをリロード
        self.collectionView.reloadData()
        ///合計金額
        var totalPrice:Int = 0
        ///それぞれの商品とそのオーダー情報を使って、合計金額を計算
        for product in products {
            ///商品の価格
            let price = product.price
            ///商品のオーダー数
            let orderdNum = product.orderNum
            ///商品の価格×商品のオーダー数
            let sumPrice = price * orderdNum
            ///合計金額に加える
            totalPrice += sumPrice
        }
        ///合計金額を表示
        self.totalPriceLabel.text = "合計  \(totalPrice)円"
        
    }

}
