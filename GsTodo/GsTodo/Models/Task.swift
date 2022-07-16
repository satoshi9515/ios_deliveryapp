//
//  Task.swift
//  GsTodo
//
//  Created by NaokiKameyama on 2020/05/6.
//  Copyright © 2020 NaokiKameyama. All rights reserved.
//

import Foundation

/// タスクのモデル
/// プロパティに title と memo を持っている
class Task: Codable {
    var title: String
    var memo: String?
    
    /// init とは、Task を作るときに呼ばれるメソッド。(イニシャライザという)
    /// 使い方： let task = Task(title: "プログラミング")
    init(title: String, memo: String = "") {
        self.title = title
        self.memo = memo
    }
}
