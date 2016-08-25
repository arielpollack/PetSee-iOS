//
//  RaceChooseVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import XLForm
import PetseeCore
import PetseeNetwork
import AlamofireImage

class RaceChooseVC: UITableViewController, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor!
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar(frame: CGRectMake(0, 0, self.view.bounds.width, 44))
        bar.delegate = self
        return bar
    }()
    
    private var races = [Race]()
    private var filteredRaces = [Race]()
    private var isSearchMode = false
    
    private var dataSource: [Race] {
        return isSearchMode ? filteredRaces : races
    }
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = searchBar
        
        fetchRaces()
    }
    
    private func fetchRaces(term term: String? = nil) {
        PetseeAPI.fetchRaces(term ?? "") { races, error in
            guard let races = races else {
                self.races = []
                self.tableView.reloadData()
                return
            }
            
            self.races = races
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Race")!
        
        let race = dataSource[indexPath.row]
        cell.textLabel?.text = race.name
        if let image = race.image {
            cell.imageView?.af_setImageWithURL(NSURL(string: image)!)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowDescriptor.value = dataSource[indexPath.row]
        navigationController?.popViewControllerAnimated(true)
    }
}

extension RaceChooseVC: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        if text.characters.count == 0 {
            isSearchMode = false
        } else {
            isSearchMode = true
            filteredRaces = races.filter { $0.name.lowercaseString.containsString(text) }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearchMode = false
        tableView.reloadData()
    }
}

class RaceFormValueTransformer: NSValueTransformer {
  
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let value = value as? Race else {
            return nil
        }
        
        return value.name
    }
}