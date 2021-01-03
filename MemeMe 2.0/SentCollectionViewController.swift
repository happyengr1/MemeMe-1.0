//
//  SentCollectionViewController.swift
//  MemeMe 2.0
//
//  Created by Frances Koo on 12/11/20.
//  Copyright © 2020 happyengr1. All rights reserved.
//
//  History:
//  12 Dec 2020 Added collectionView() protocol
//  12 Dec 2020 Next: Add cell.imageView
//

import UIKit

class SentCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var navCollectionTitle: UINavigationController?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // use appDelegate.memes to access memes

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // collectionView.reloadData()
    }
    
    // MARK: Collectionfunc overridefunccollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        
        let meme = appDelegate.memes[indexPath.row]

        // >>>> HERE <<<<
        // cell.imageView!.image = meme.memedImage
        
        return cell
    }
}

