//
//  Mail.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/16.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import Foundation

class Mail:Codable{
    var to:String
    var message:Message
    
    init(to:String, message:Message) {
        self.to = to
        self.message = message
    }
}

class Message:Codable{
    var subject:String
    var text:String
    
    init(subject:String, text:String) {
        self.subject = subject
        self.text = text
    }
}
