//
//  FirestoreService.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/11.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import PKHUD
import CoreLocation

class FirestoreService{
    ///Firestoreのインスタンス
    static var db = Firestore.firestore()
    
    ///【追記】監視そのもののインスタンス自体を格納する変数
    static var myOrdersListener:ListenerRegistration?
    
    ///【追記】監視そのもののインスタンス自体を格納する変数
    static var allOrdersListener:ListenerRegistration?
    
    ///監視そのもののインスタンス自体を格納する変数
    static var orderListener:ListenerRegistration?
    
    ///Firestoreのmailsに書き込み
    public static func sendEmail(to:String,subject:String,text:String){
        //Messageのインスタンスを作成
        let message = Message(subject: subject, text: text)
        let mail = Mail(to: to, message: message)
        do {
        let encodedData = try Firestore.Encoder().encode(mail)
            let mailId = db.collection("mails").document().documentID
            db.collection("mails").document(mailId).setData(encodedData)
        } catch{
            print("error:\(error)")
        }
    }
    
    ///ユーザー情報の読み込み
    ///引数にコールバック関数を持つ
    ///コールバック関数の処理の中身は、readUserInfoの関数を呼び出す側で記述する（他の引数と同様）
    ///@escapingはFirestoreのメソッドがescaping closureとなっているため付ける必要がある
    static func readUserInfo(userId:String,callback:@escaping (User)->Void){
        db.collection("users").document(userId).getDocument { snapShot, err in
            if let err = err {
                print("error:\(err)")
            } else {
                guard let data = snapShot?.data() else {return}
                do {
                let decodedData = try Firestore.Decoder().decode(User.self, from: data)
                    print("User data is:\(decodedData)")
                    ///ユーザー情報を引数に持つコールバック関数を呼び出し
                    callback(decodedData)
                } catch {
                    print("error decoding data:\(error)")
                }
            }
        }
    }
    
    ///オーダー情報の書き込み
    static func createOrder(products:[Product], callback:@escaping (Order)-> Void){
        ///ユーザーID
        guard let userId = Auth.auth().currentUser?.uid else {return}
        ///ローディングのインディケーター表示
        HUD.show(.progress)
        ///オーダーID
        let orderId = db.collection("orders").document().documentID
        ///オーダーのインスタンス
        let order = Order(orderId:orderId, products: products, customerUserId: userId, createdAt: Date(), updatedAt: Date(),orderState: .orderd, latitude: nil,longitude: nil)
        
        do {
            ///オーダーを変換
        let encodedData = try Firestore.Encoder().encode(order)
            ///Firestoreのusersコレクションのドキュメントに紐づくサブコレクションとしてオーダーを書き込み
            self.db.collection("users").document(userId).collection("orders").document(orderId).setData(encodedData) { err in
                if let err = err {
                    ///エラー
                    print("error writing document:\(err)")
                    HUD.flash(.error, delay: 1.0)
                } else {
                    ///成功
                    HUD.flash(.success, delay: 1.0)
                    ///コールバック関数を呼び出し
                    callback(order)
                }
            }
        } catch {
            print("failed encoding order document")
        }
    }
    
    ///オーダー情報の監視
    static func listenMyOrders(callback: @escaping ([Order])->Void){
        ///ユーザーID
        guard let userId = Auth.auth().currentUser?.uid else {return}
        ///オーダーコレクションを監視
        let listener = db.collection("users").document(userId).collection("orders").order(by: "createdAt", descending: true).addSnapshotListener { snapShot, err in
            if let err = err {
                print("error:\(err)")
            } else {
                ///Document群
                let documents = snapShot!.documents
                var orders:[Order] = []
                for document in documents {
                    ///各DocumentからはDocumentIDとその中身のdataを取得できる
                    print("\(document.documentID) => \(document.data())")
                    do {
                        ///オーダー型に変換
                        let decodedOrder = try Firestore.Decoder().decode(Order.self, from: document.data())
                        ///変換に成功
                        orders.append(decodedOrder)
                    } catch {
                        ///変換に失敗
                        print("error decoding:\(error)")
                    }
                }
                ///for文の処理を全て終えたらコールバック関数を呼び出し
                callback(orders)
            }
        }
        ///【追記】監視のインスタンスを変数に格納
        self.myOrdersListener = listener
    }
    
    ///全てのオーダーの更新を監視
    static func listenAllOrders(callback: @escaping ([Order])->Void){
        ///コレクショングループを監視
        let listener = db.collectionGroup("orders").order(by: "createdAt", descending: true).addSnapshotListener { snapShot, err in
            if let err = err {
                print("error listen All orders:\(err)")
            } else {
                let documents = snapShot!.documents
                var orders:[Order] = []
                for document in documents {
                    ///各DocumentからはDocumentIDとその中身のdataを取得できる
                    print("\(document.documentID) => \(document.data())")
                    do {
                    let decodedOrder = try Firestore.Decoder().decode(Order.self, from: document.data())
                        orders.append(decodedOrder)
                    } catch {
                        print("error decoding:\(error)")
                    }
                }
                ///for文の処理を全て終えたらコールバック関数を呼び出し
                callback(orders)
            }
        }
        ///【追記】監視のインスタンスを変数に格納
        self.allOrdersListener = listener
    }
    
    
    ///監視を解除する
    static func removeListeners(){
        ///【追記】変数に格納した監視のインスタンスを取り除く
        self.myOrdersListener?.remove()
        self.allOrdersListener?.remove()
    }
    
    
    ///ある1つのオーダーの状態を監視する
    static func listenOrder(order:Order, callback: @escaping (Order)->Void){
        let listener = db.collection("users").document(order.customerUserId).collection("orders").document(order.orderId).addSnapshotListener { snapShot, err in
            guard let document = snapShot else {
                print("error fetching document:\(String(describing: err))")
                return
            }
            guard let data = document.data() else {
                print("document data is empty")
                return
            }
            do {
                let decodedOrder = try Firestore.Decoder().decode(Order.self, from: data)
                callback(decodedOrder)
            }catch{
                print("error:\(error)")
            }
        }
        ///監視のインスタンスを変数に格納
        self.orderListener = listener
    }
    
    ///監視を解除する
    static func removeListener(){
        self.orderListener?.remove()
    }
    
    ///ある1つのオーダーをアップデートする
    static func updateOrder(order:Order, orderState:orderState, latitude:CLLocationDegrees?,longitude:CLLocationDegrees?){
        let updatedOrder = Order(orderId:order.orderId, products: order.products, customerUserId: order.customerUserId, createdAt: order.createdAt, updatedAt: Date(),orderState: orderState,latitude: latitude,longitude: longitude)
        do {
        let encodedData = try Firestore.Encoder().encode(updatedOrder)
            self.db.collection("users").document(order.customerUserId).collection("orders").document(order.orderId).updateData(encodedData)
        } catch{
            print("error:\(error)")
        }
        
    }
    ///ある1つのオーダーの緯度と経度のみ更新する
    static func updateLocationOfOrder(order:Order,latitude:CLLocationDegrees?,longitude:CLLocationDegrees?){
        ///エンコードを利用しない場合は下記のような記述の仕方も可能
        let updateData = [
            "latitude":latitude,
            "longitude":longitude
        ]
        self.db.collection("users").document(order.customerUserId).collection("orders").document(order.orderId).updateData(updateData as [AnyHashable : Any])
    }
    
}
