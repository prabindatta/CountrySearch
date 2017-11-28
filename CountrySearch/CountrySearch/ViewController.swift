//
//  ViewController.swift
//  CountrySearch
//
//  Created by Prabin K Datta on 24/11/17.
//  Copyright © 2017 Prabin K Datta. All rights reserved.
//
//TODO: http://country.io/names.json  for reference http://country.io/data/

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var m_SearchBar: UISearchBar!
    @IBOutlet weak var m_TableView: UITableView!
    var fetching = false
    var countries: [Country] = []
    var m_Countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        m_SearchBar.showsCancelButton = true
        print("Countries: \(m_Countries.count)")
        Client.countrycode().getCountryList(begin: { () -> Void in
            if !self.isCurrentViewActive() {
                self.fetching = false
                return
            }
        }, success: { (result) -> Void in
            objc_sync_enter(self)
            self.countries = result.items
            self.m_Countries = self.countries
            objc_sync_exit(self)

            DispatchQueue.main.async {
                self.m_TableView.reloadData()
            }

        }, error: { (statusCode, errorResponse) -> Void in
            if !self.isCurrentViewActive() {
                self.fetching = false
                return
            }
            
            self.m_TableView.reloadData()
        }, complete: { () -> Void in
            // Leave Empty
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isCurrentViewActive() -> Bool {
        return navigationController?.visibleViewController == self
    }

    //MARK:TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_Countries.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")!
        cell.textLabel?.text = (self.m_Countries[indexPath.row] as Country).countryName
        cell.detailTextLabel?.text = (self.m_Countries[indexPath.row] as Country).countryCode
        return cell
    }
    
    //MARK:SearchBar Delegates
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.m_Countries = self.countries.filter({ (country: Country)  -> Bool in
            return (country.countryCode == searchBar.text)
        })
        m_TableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.m_Countries = self.countries
        m_TableView.reloadData()
    }
}

