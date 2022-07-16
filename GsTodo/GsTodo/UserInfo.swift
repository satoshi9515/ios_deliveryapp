//
//  UserInfo.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/11.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import Foundation

///ユーザー情報をアプリ内で保持して参照するためのクラス
class UserInfo{
    ///staticをつけると、クラスのインスタンスではなくクラスの型そのもの（UserInfo）にひもづく変数となる
    ///よってstaticをつけている場合、UserInfoクラスはインスタンス化せずに、利用する形になる
    /// ユーザー情報
    static var user:User!
}
