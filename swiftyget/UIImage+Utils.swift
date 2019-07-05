//
//  UIImage+Utils.swift
//  swiftyget
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import UIKit

extension UIImageView {
    public func setFutureImage( future: FutureObject<UIImage>, animated: Bool ) {
        future.then { [weak self] (image) in
            DispatchQueue.main.async { [weak self] in
                self?.alpha = 0.0
                self?.image = image
                UIView.animate(withDuration: 1.0, animations: { [weak self] in 
                    self?.alpha = 1.0
                })
            }
        }
    }
}
