//
//  MyPetsVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import AlamofireImage

class MyPetsVC: UIViewController {

    @IBOutlet weak var petsTableView: UITableView!
    
    private var pets = [Pet]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadPets()
    }
    
    private func reloadPets() {
        PetsStore.sharedStore.fetchAll { pets in
            self.pets = pets
            self.petsTableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let petVC = segue.destinationViewController as? PetVC else {
            return
        }
        
        guard let selectedIndexPath = petsTableView.indexPathForSelectedRow else {
            return
        }
        
        petVC.pet = pets[selectedIndexPath.row]
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
