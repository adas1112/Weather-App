//
//  searchModel.swift
//  Weather App
//
//  Created by Bilal on 12/03/25.
//

import Foundation

struct SearchResonse : Codable{
    let name : String?
    let place_id : String?
    let adm_area1 : String?
    let adm_area2 : String?
    let country : String?
    let lat : String?
    let lon : String?
    let timezone : String?
    let type : String?

    init(name:String, place_id:String, adm_area1: String, adm_area2:String, country:String, lat:String, lon:String, timezone:String, type:String){
        self.name = name
        self.place_id = place_id
        self.adm_area1 = adm_area1
        self.adm_area2 = adm_area2
        self.country = country
        self.lat = lat
        self.lon = lon
        self.timezone = timezone
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        place_id = try values.decodeIfPresent(String.self, forKey: .place_id)
        adm_area1 = try values.decodeIfPresent(String.self, forKey: .adm_area1)
        adm_area2 = try values.decodeIfPresent(String.self, forKey: .adm_area2)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lon = try values.decodeIfPresent(String.self, forKey: .lon)
        timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}
