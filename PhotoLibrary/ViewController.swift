//
//  ViewController.swift
//  PhotoLibrary
//
//  Created by Amit Shukla on 27/06/20.
//  Copyright © 2020 Amit Shukla. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    var assets = [PHAsset]()
    var images = [UIImage]()
    let page = 10
    var beginIndex = 0
    
    var endIndex = 9
    var allPhotos : PHFetchResult<PHAsset>?
    var loading = false
    var hasNextPage = false
    
    var photoSize:CGSize {
        let width = (UIScreen.main.bounds.size.width - 6.0)/4.0
        return CGSize(width:width,height: width)
    }
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        PHPhotoLibrary.requestAuthorization({
            (status) in
            switch status {
            case .authorized:
                let options = PHFetchOptions()
                options.includeHiddenAssets = true
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: options)
                self.getImages()
            default:
                break
                
            }
        })
        
    }
    
    func getImages(){
        endIndex = beginIndex + (page - 1)
        if endIndex > allPhotos!.count {
            endIndex = allPhotos!.count - 1
        }
        if endIndex > beginIndex {
            let arr = Array(beginIndex...endIndex)
            let indexSet = IndexSet(arr)
            fetchPhotos(indexSet: indexSet)
        }
    }
    
    
    fileprivate func fetchPhotos(indexSet: IndexSet) {
        
        if allPhotos!.count == self.images.count {
            self.hasNextPage = false
            self.loading = false
            return
        }
        
        self.loading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
           
            self?.allPhotos?.enumerateObjects(at: indexSet, options: NSEnumerationOptions.concurrent, using: { (asset, count, stop) in
                guard let weakSelf = self else {
                    return
                }
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width:150,height: 150)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        weakSelf.images.append(image)
                        weakSelf.assets.append(asset)
                    }
                    
                })
                if weakSelf.images.count - 1 == indexSet.last! {
                    print("last element")
                    weakSelf.loading = false
                    weakSelf.hasNextPage = weakSelf.images.count != weakSelf.allPhotos!.count
                    weakSelf.beginIndex = weakSelf.images.count
                    DispatchQueue.main.async {
                        weakSelf.collectionView.reloadData()
                    }
                }
            })
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCelll", for: indexPath)
        let imgView = cell.viewWithTag(1) as! UIImageView
        imgView.image = self.images[indexPath.row]
        
        if self.hasNextPage && !loading && indexPath.row == self.images.count - 1 {
            getImages()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.assets[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(identifier: "FullViewController") as? FullViewController {
            vc.asset = asset
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return photoSize
    }
}

