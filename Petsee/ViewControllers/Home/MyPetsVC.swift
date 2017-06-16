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
    
    fileprivate var pets = [Pet]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadPets()
    }
    
    fileprivate func reloadPets() {
        PetsStore.sharedStore.fetchAll { pets in
            self.pets = pets
            self.petsTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let petVC = segue.destination as? PetVC else {
            return
        }
        
        guard let selectedIndexPath = petsTableView.indexPathForSelectedRow else {
            return
        }
        
        petVC.pet = pets[selectedIndexPath.row]
    }
}

extension MyPetsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Pet")!
        
        let pet = pets[indexPath.row]
        
        cell.textLabel?.text = pet.name
        
        if let image = pet.image, let url = URL(string: image) {
            cell.imageView?.af_setImage(withURL: url)
        } else {
            cell.imageView?.af_cancelImageRequest()
        }
        
        return cell
    }
}
