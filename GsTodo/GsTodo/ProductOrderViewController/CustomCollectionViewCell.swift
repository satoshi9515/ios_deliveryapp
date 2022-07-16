//
//  CustomCollectionViewCell.swift
//  GsTodo
//
//  Created by 鈴江元尚 on 2022/03/04.
//  Copyright © 2022 yamamototatsuya. All rights reserved.
//

import UIKit

/// コレクションビューのカスタムセル
class CustomCollectionViewCell: UICollectionViewCell {
    ///画像を表示するビュー
    @IBOutlet weak var imageView: UIImageView!
    ///商品の名前を表示するラベル
    @IBOutlet weak var nameLabel: UILabel!
    ///商品の価格を表示するラベル
    @IBOutlet weak var priceLabel: UILabel!
    ///商品のオーダー個数を表示するラベル
    @IBOutlet weak var orderNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
