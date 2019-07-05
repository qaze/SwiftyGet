//
//  PinImageCell.swift
//  SwiftyGetDemo
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import UIKit
import swiftyget

class PinImageCell : UICollectionViewCell {
    private var futureObject : FutureObject<UIImage>?
    @IBOutlet weak var imageView : UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        futureObject = nil
        imageView.image = nil
    }
    
    func configure( with future: FutureObject<UIImage> ) {
        futureObject = future
        imageView?.setFutureImage(future: future, animated: true)
    }
}
