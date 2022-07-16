//
//  Order.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/11.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import Foundation
import CoreLocation

/// オーダーモデル
class Order:Codable{
    ///オーダーID
    var orderId:String
    ///オーダー商品群
    var products:[Product]
    ///購入者のユーザーID
    var customerUserId:String
    ///作成日時
    var createdAt:Date
    ///更新日時
    var updatedAt:Date
    ///オーダーの状態
    var orderState:orderState
    ///緯度 nilを許容
    var latitude:CLLocationDegrees?
    ///経度 nilを許容
    var longitude:CLLocationDegrees?
    ///イニシャライズ
    init(orderId:String, products:[Product], customerUserId:String, createdAt:Date, updatedAt:Date, orderState:orderState,latitude:CLLocationDegrees?, longitude:CLLocationDegrees?) {
        self.orderId = orderId
        self.products = products
        self.customerUserId = customerUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.orderState = orderState
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// オーダーの状態
enum orderState:Codable {
    case orderd ///注文完了
    case onDelivery ///配送中
    case delivered ///配送完了
}

