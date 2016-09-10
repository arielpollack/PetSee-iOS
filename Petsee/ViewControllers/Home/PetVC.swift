//
//  PetVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 19/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import AlamofireImage

class PetVC: UIViewController {
    
    @IBOutlet weak var lblPetName: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var imgPetThumbnail: UIImageView!
    @IBOutlet weak var tableServices: UITableView!
    
    var pet: Pet!
    private var services = [Service]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPetName.text = pet.name
        lblAbout.text = pet.about

        imgPetThumbnail.image = UIImage(named: "pet-profile-placeholder")
        if let imageString = pet.image, imageURL = NSURL(string: imageString) {
            imgPetThumbnail.af_setImageWithURL(imageURL)
        }
        
        loadServices()
    }
    
    private func loadServices() {
        ServicesStore.sharedStore.fetchPredicate({$0.pet == self.pet}) { services in
            self.services = services
            self.tableServices.reloadData()
        }
    }
    
    @IBAction func exitTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PetVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Service") as! ServiceCell
        cell.service = services[indexPath.row]
        return cell
    }
    
}

extension PetVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let service = services[indexPath.row]
        let serviceVC = storyboard?.instantiateViewControllerWithIdentifier("ServiceVC") as! ServiceVC
        serviceVC.service = service
        navigationController?.pushViewController(serviceVC, animated: true)
    }
}