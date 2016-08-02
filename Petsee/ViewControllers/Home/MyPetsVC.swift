//
//  MyPetsVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore
import AlamofireImage

class MyPetsVC: UIViewController {

    @IBOutlet weak var petsTableView: UITableView!
    
    private var pets = [Pet]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PetsStore.sharedManager.fetchAllPets { pets in
            self.pets = pets
            self.petsTableView.reloadData()
        }
    }
}

extension MyPetsVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Pet")!
        
        let pet = pets[indexPath.row]
        
        cell.textLabel?.text = pet.name
        
        if let image = pet.image, let url = NSURL(string: image) {
            cell.imageView?.af_setImageWithURL(url)
        } else {
            cell.imageView?.af_cancelImageRequest()
        }
        
        return cell
    }
}
