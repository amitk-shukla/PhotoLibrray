//
//  FullViewController.swift
//  PhotoLibrary
//
//  Created by Amit Shukla on 27/06/20.
//  Copyright © 2020 Amit Shukla. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class FullViewController: UIViewController {

    @IBOutlet weak var imageView : UIImageView!
    var asset:PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Detail 400*400"
        
        if let asset = asset {
            let imageManager = PHImageManager.default()
            let targetSize = CGSize(width:400,height: 400)
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                self.imageView.image = image
            })
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
