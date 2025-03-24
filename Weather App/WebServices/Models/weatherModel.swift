//
//  weatherModel.swift
//  Weather App
//
//  Created by Bilal on 11/03/25.
//

import Foundation

struct Cloud_cover : Codable {
    let total : Double?
    
    init(total: Double?) {
        self.total = total
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        total = try values.decodeIfPresent(Double.self, forKey: .total)
    }
}

struct Current : Codable {
    let icon : String?
    let icon_num : Int?
    let summary : String?
    let temperature : Double?
    let wind : Wind?
    let precipitation : Precipitation?
    let cloud_cover : Double?

    init(icon: String?,icon_num: Int?,summary: String?,temperature: Double?,wind: Wind?,precipitation:Precipitation?,cloud_cover: Double?) {
           self.icon = icon
           self.icon_num = icon_num
           self.summary = summary
           self.temperature = temperature
           self.wind = wind
           self.precipitation = precipitation
           self.cloud_cover = cloud_cover
       }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        icon_num = try values.decodeIfPresent(Int.self, forKey: .icon_num)
        summary = try values.decodeIfPresent(String.self, forKey: .summary)
        temperature = try values.decodeIfPresent(Double.self, forKey: .temperature)
        wind = try values.decodeIfPresent(Wind.self, forKey: .wind)
        precipitation = try values.decodeIfPresent(Precipitation.self, forKey: .precipitation)
        cloud_cover = try values.decodeIfPresent(Double.self, forKey: .cloud_cover)
    }
}

struct DataWeather : Codable {
    let day : String?
    let weather : String?
    let icon : Int?
    let summary : String?
    let all_day : All_day?
    let morning : String?
    let afternoon : String?
    let evening : String?

    init(day: String?,weather: String?,icon: Int?,summary: String?,all_day: All_day?,morning: String?,afternoon: String?,evening: String?) {
            self.day = day
            self.weather = weather
            self.icon = icon
            self.summary = summary
            self.all_day = all_day
            self.morning = morning
            self.afternoon = afternoon
            self.evening = evening
        }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        day = try values.decodeIfPresent(String.self, forKey: .day)
        weather = try values.decodeIfPresent(String.self, forKey: .weather)
        icon = try values.decodeIfPresent(Int.self, forKey: .icon)
        summary = try values.decodeIfPresent(String.self, forKey: .summary)
        all_day = try values.decodeIfPresent(All_day.self, forKey: .all_day)
        morning = try values.decodeIfPresent(String.self, forKey: .morning)
        afternoon = try values.decodeIfPresent(String.self, forKey: .afternoon)
        evening = try values.decodeIfPresent(String.self, forKey: .evening)
    }
}


struct Hourly : Codable {
    let data : [DataWeather]?

    init(data: [DataWeather]?) {
           self.data = data
       }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([DataWeather].self, forKey: .data)
    }

}

struct WeatherResponse : Codable {
    let lat : String?
    let lon : String?
    let elevation : Int?
    let timezone : String?
    let units : String?
    let current : Current?
    let hourly : Hourly?
    let daily : Daily?

    init(lat: String?,lon: String?,elevation: Int?,timezone: String?,units: String?,current: Current?,hourly: Hourly?,daily: Daily?) {
        self.lat = lat
        self.lon = lon
        self.elevation = elevation
        self.timezone = timezone
        self.units = units
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lon = try values.decodeIfPresent(String.self, forKey: .lon)
        elevation = try values.decodeIfPresent(Int.self, forKey: .elevation)
        timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
        units = try values.decodeIfPresent(String.self, forKey: .units)
        current = try values.decodeIfPresent(Current.self, forKey: .current)
        hourly = try values.decodeIfPresent(Hourly.self, forKey: .hourly)
        daily = try values.decodeIfPresent(Daily.self, forKey: .daily)
    }

}

struct Precipitation : Codable {
    let total : Double?
    let type : String?

    init(total: Double?, type: String?) {
        self.total = total
        self.type = type
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        total = try values.decodeIfPresent(Double.self, forKey: .total)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}

struct Wind : Codable {
    let speed : Double?
    let dir : String?
    let angle : Int?

    init(speed: Double?, dir: String?, angle: Int?) {
           self.speed = speed
           self.dir = dir
           self.angle = angle
       }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        speed = try values.decodeIfPresent(Double.self, forKey: .speed)
        dir = try values.decodeIfPresent(String.self, forKey: .dir)
        angle = try values.decodeIfPresent(Int.self, forKey: .angle)
    }

}

struct Daily : Codable {
    let data : [DataWeather]?

    init(data: [DataWeather]?) {
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([DataWeather].self, forKey: .data)
    }

}


struct All_day : Codable {
    let weather : String?
    let icon : Int?
    let temperature : Double?
    let temperature_min : Double?
    let temperature_max : Double?
    let wind : Wind?
    let cloud_cover : Cloud_cover?
    let precipitation : Precipitation?
    
    init(weather: String?,icon: Int?,temperature: Double?,temperature_min: Double?,temperature_max: Double?,wind: Wind?,cloud_cover: Cloud_cover?,precipitation: Precipitation?) {
           self.weather = weather
           self.icon = icon
           self.temperature = temperature
           self.temperature_min = temperature_min
           self.temperature_max = temperature_max
           self.wind = wind
           self.cloud_cover = cloud_cover
           self.precipitation = precipitation
       }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        weather = try values.decodeIfPresent(String.self, forKey: .weather)
        icon = try values.decodeIfPresent(Int.self, forKey: .icon)
        temperature = try values.decodeIfPresent(Double.self, forKey: .temperature)
        temperature_min = try values.decodeIfPresent(Double.self, forKey: .temperature_min)
        temperature_max = try values.decodeIfPresent(Double.self, forKey: .temperature_max)
        wind = try values.decodeIfPresent(Wind.self, forKey: .wind)
        cloud_cover = try values.decodeIfPresent(Cloud_cover.self, forKey: .cloud_cover)
        precipitation = try values.decodeIfPresent(Precipitation.self, forKey: .precipitation)
    }

}
