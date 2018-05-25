//
//  ViewController.swift
//  MarsV1
//
//  Created by Release on 2018. 5. 16..
//  Copyright © 2018년 Hyuck Jung. All rights reserved.
//

import UIKit
import CoreML
enum Feature: Int {
    case solarPanels = 0, greenhouses, size
}

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    let model = MarsHabitatPricer()
    
 
    
    /// Formatter for the output.
    let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    {
    didSet {
    pickerView.delegate = self
    pickerView.dataSource = self
    
    let features: [Feature] = [.solarPanels, .greenhouses, .size]
    for feature in features {
    pickerView.selectRow(2, inComponent: feature.rawValue, animated: false)
            }
        }
    }
    func updatePredictedPrice() {
        func selectedRow(for feature: Feature) -> Int {
            return pickerView.selectedRow(inComponent: feature.rawValue)
        }
        
        let solarPanels = self.value(for: selectedRow(for: .solarPanels), feature: .solarPanels)
        let greenhouses = self.value(for: selectedRow(for: .greenhouses), feature: .greenhouses)
        let size = self.value(for: selectedRow(for: .size), feature: .size)
        
        guard let marsHabitatPricerOutput = try? model.prediction(solarPanels: solarPanels, greenhouses: greenhouses, size: size) else {
            fatalError("Unexpected runtime error.")
        }
        
        let price = marsHabitatPricerOutput.price
        priceLabel.text = priceFormatter.string(for: price)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(" Selected row=",row)
        updatePredictedPrice()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let feature = Feature(rawValue: component) else{
            fatalError("Invalid component")
        }
        return self.title(for: row, feature: feature)
        
    }
    
    private let solarPanelDataSource = SolarPanelDataSource()
    private let greenhouseDataSource = GreenhouseDataSource()
    private let sizeDataSource = SizeDataSource()
    
    func title(for row: Int,feature: Feature) -> String? {
        switch feature {
        case .solarPanels: return solarPanelDataSource.title(for: row)
        case .greenhouses: return greenhouseDataSource.title(for: row)
        case .size: return sizeDataSource.title(for: row)
        }
        
    }
    
    func value(for row: Int,feature: Feature) -> Double {
        let value: Double?
        switch feature {
        case .solarPanels: value = solarPanelDataSource.value(for: row)
        case .greenhouses: value = greenhouseDataSource.value(for: row)
        case .size: value = sizeDataSource.value(for: row)
        }
        return value!
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView,numberOfRowsInComponent component: Int) -> Int
    {
        switch Feature(rawValue: component)! {
        case .solarPanels: return solarPanelDataSource.values.count
        case .greenhouses: return greenhouseDataSource.values.count
        case .size: return sizeDataSource.values.count
        }
        
    }
    
 
}


struct SolarPanelDataSource {
    let values = [1,1.5,2,2.5,3,3.5,4,4.5,5]
    func title(for index:Int) -> String? {
        guard index < values.count else {return nil}
        return String(values[index])
    }
    func value(for index: Int) -> Double?{
        guard index < values.count else {return nil}
        return Double(values[index])
    }
}

struct GreenhouseDataSource {
    let values = [1,2,3,4,5]
    func title(for index:Int) -> String? {
        guard index < values.count else {return nil}
        return String(values[index])
    }
    func value(for index: Int) -> Double?{
        guard index < values.count else {return nil}
        return Double(values[index])
    }
}

struct SizeDataSource {
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    let values = [750, 1000, 1500, 2000, 3000, 4000, 5000, 10_000]
    func title(for index:Int) -> String? {
        guard index < values.count else {return nil}
        return SizeDataSource.numberFormatter.string(from: NSNumber(value: values[index]))
    }
    func value(for index: Int) -> Double?{
        guard index < values.count else {return nil}
        return Double(values[index])
    }
}

