//
//  ImageView+Lazy.swift
//  DevigetTest
//
//  Created by Ignacio Zunino on 29/09/2020.
//

import Foundation
import UIKit

private var associateKey: Void?

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    var downloadSession: URLSessionTask? {
        get {
            return objc_getAssociatedObject(self, &associateKey) as? URLSessionTask
        }
        set {
            objc_setAssociatedObject(self, &associateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func loadImageFrom(link: URL, contentMode: UIView.ContentMode) {
        
//        if let imageFromCache = imageCache.object(forKey: link as AnyObject) as? UIImage {
//
//            self.image = imageFromCache
//            return
//        }
//
        self.image = nil
        
        downloadSession = URLSession.shared.dataTask( with: link, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data {
                    let newImage = UIImage(data: data)!
                    self.image = newImage
                    imageCache.setObject(newImage, forKey: link as AnyObject)
                }
            }
        })
        
        downloadSession?.resume()
    }
    
    func cancelLoadingImage() {
        downloadSession?.cancel()
    }
}

