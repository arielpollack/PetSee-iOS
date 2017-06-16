//
//  RaceChooseVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import XLForm
import AlamofireImage

class RaceChooseVC: UITableViewController, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor!
    
    fileprivate lazy var searchBar: UISearchBar = {
        let bar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        bar.delegate = self
        return bar
    }()
    
    fileprivate var races = [Race]()
    fileprivate var filteredRaces = [Race]()
    fileprivate var isSearchMode = false
    
    fileprivate var dataSource: [Race] {
        return isSearchMode ? filteredRaces : races
    }
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = searchBar
        
        fetchRaces()
    }
    
    fileprivate func fetchRaces(term: String? = nil) {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Race")!
        
        let race = dataSource[indexPath.row]
        cell.textLabel?.text = race.name
        if let image = race.image {
            cell.imageView?.af_setImage(withURL: URL(string: image)!)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowDescriptor.value = dataSource[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
}

extension RaceChooseVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        if text.characters.count == 0 {
            isSearchMode = false
        } else {
            isSearchMode = true
            filteredRaces = races.filter { $0.name.lowercased().contains(text) }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchMode = false
        tableView.reloadData()
    }
}

class RaceFormValueTransformer: ValueTransformer {
  
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Race else {
            return nil
        }
        
        return value.name
    }
}
