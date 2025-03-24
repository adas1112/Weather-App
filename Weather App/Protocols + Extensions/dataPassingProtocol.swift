//
//  dataPassingProtocol.swift
//  Weather App
//
//  Created by Bilal on 17/03/25.
//

import Foundation

protocol DataPassingDelegate: AnyObject {
    func appendData(data: [WeatherResponse])
}
