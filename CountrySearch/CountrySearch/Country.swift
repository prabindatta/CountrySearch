//
//  Country.swift
//  CountrySearch
//
//  Created by Prabin K Datta on 28/11/17.
//  Copyright © 2017 Prabin K Datta. All rights reserved.
//

import Foundation

class Country {
    var countryCode: String
    var countryName: String
    
    init(code:String, name: String) {
        self.countryCode = code
        self.countryName = name
    }
}
