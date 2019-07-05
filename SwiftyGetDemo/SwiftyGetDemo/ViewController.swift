//
//  ViewController.swift
//  SwiftyGetDemo
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import UIKit
import swiftyget

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var urls = [URL]()
    private let refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        
        if let url = URL(string: "https://pastebin.com/raw/wgkJgazE") {
            SwiftyGet.getData(url: url)
                .then { [weak self] (data) in
                    self?.parseJson(data: data as Data)
            }
        }
        
        collectionView.refreshControl = refreshControll
        refreshControll.addTarget(self, action: #selector(refreshTriggered(_:)), for: .valueChanged)
    }
    
    @objc func refreshTriggered(_ sender: Any?) {
        collectionView.reloadData()
        refreshControll.endRefreshing()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            flowLayout.itemSize = CGSize(width: collectionView.bounds.width / 2.0 - 30, height: collectionView.bounds.width / 2.0 - 30)
            flowLayout.minimumInteritemSpacing = 10
        } 
    }
    
    func parseJson( data: Data ) {
        if let objects = try? JSONSerialization.jsonObject(with: data as Data, options: [.allowFragments]) as? NSArray {
            for i in objects {
                if let obj = i as? NSDictionary {
                    if let urls = obj["urls"] as? NSDictionary {
                        if let raw = urls["small"] as? NSString {
                            print(raw)
                            if let url = URL(string: raw as String) {
                                self.urls.append(url)
                            }
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinCell", for: indexPath) as? PinImageCell else { fatalError() }
        
        let url = urls[indexPath.row]
        cell.configure(with: SwiftyGet.getImage(url: url))
        return cell
    }
}

