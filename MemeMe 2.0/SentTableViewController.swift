//
//  SentTableViewController.swift
//  MemeMe 2.0
//
//  Created by Frances Koo on 12/11/20.
//  Copyright © 2020 happyengr1. All rights reserved.
//
//  History:
//  12 Dec 2020 Added tableView() protocol
//  12 Dec 2020 Next: Show memedImage and textLabel
//

import UIKit

class SentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // use appDelegate.memes to access memes

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // tableView.reloadData()
        
    }
    
    // MARK: - UITableView protocol
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        let meme = appDelegate.memes[(indexPath as NSIndexPath).row]
        
        // set the image
        cell.imageView?.image = meme.memedImage
        
        return cell

    }

}
