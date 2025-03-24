//
//  weatherDataCell.swift
//  Weather App
//
//  Created by Bilal on 10/03/25.
//

import UIKit

class weatherDataCell: UITableViewCell {

    //MARK: - Outlets

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblTemprature: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblMinMaxTemp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
    }
}
