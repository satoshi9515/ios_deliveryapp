//
//  User.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/03.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import Foundation

/// ユーザーのモデル
class User:Codable {
    /// ユーザーID
    var userId:String
    /// 名前
    var name:String
    /// 電話番号
    var phoneNum:Int
    /// 住所
    var address:String
    /// ユーザーの区分
    var segment:UserSegment
    /// メールアドレス ※DBに書き込むことで後々の利用可能性が広がる userのemailはAuthのメソッドからも取得できるが自分自身のものしか取得できない
    var email:String
    
    ///初期化
    init(userId:String, name:String, phoneNum:Int, address:String, segment:UserSegment,email:String) {
        self.userId = userId
        self.name = name
        self.phoneNum = phoneNum
        self.address = address
        self.segment = segment
        self.email = email
    }
}

/// ユーザーの区分
enum UserSegment:Codable {
    case customer
    case staff
}
