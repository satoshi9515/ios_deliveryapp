//
//  Product.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/04.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import Foundation

/// 商品のモデル
class Product:Codable {
    ///名称
    var name:String
    ///サムネイル画像の名前
    var thumbnailName:String
    ///価格
    var price:Int
    ///オーダーの個数
    var orderNum:Int
    ///初期化
    init(name:String,thumbnailName:String,price:Int) {
        self.name = name
        self.thumbnailName = thumbnailName
        self.price = price
        self.orderNum = 0
    }
}
