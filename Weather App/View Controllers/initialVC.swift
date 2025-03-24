//
//  ViewController.swift
//  Weather App
//
//  Created by Bilal on 10/03/25.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Outlets

    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradient()
    }
    
    //MARK: - Button Actions
    
    @IBAction func startBtnClick(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "weatherMainVC") as? weatherMainVC ?? UIViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - UI Setup
    
    func applyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgView.bounds
        
        let increasedHeight: CGFloat = bgView.bounds.height * 2 // Add extra height
        let increasedwidth: CGFloat = bgView.bounds.width + 20 
        gradientLayer.frame = CGRect(x: 0, y: 0, width: increasedwidth, height: increasedHeight)
        
        // Set gradient colors
        gradientLayer.colors = [
            UIColor.init(hex: "535287").cgColor,
            UIColor.white.cgColor
        ]
        
        // Set gradient start and end points for top-right to bottom-left
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.3)   // Bottom-left

        bgView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
