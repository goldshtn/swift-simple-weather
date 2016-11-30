//
//  ViewController.swift
//  SimpleWeather
//
//  Created by Sasha Goldshtein on 11/29/16.
//  Copyright © 2016 Sasha Goldshtein. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var resultsTable: UITableView!
    
    private let userDefaults = AppUserDefaults()
    private var results = [WeatherResult]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "result_cell", for: indexPath)
        let result = results[indexPath.row]
        switch result {
        case .Error(let error):
            cell.textLabel?.text = "Error"
            cell.detailTextLabel?.text = error
        case .Success(let conditions):
            let formattedTemperature = String(format: "%.2f", conditions.temperatureCelsius)
            cell.textLabel?.text = "\(conditions.generalDescription.capitalized) in \(conditions.city)"
            cell.detailTextLabel?.text = "\(formattedTemperature)℃, \(conditions.humidityPercent)% humidity"
        }
        return cell
    }
    
    @IBAction func getWeather() {
        guard let city = cityField.text, city != "" else {
            return
        }
        WeatherService().weather(forCity: city) { result in
            DispatchQueue.main.async { self.processResult(result: result) }
        }
        userDefaults.saveLastCity(city)
    }
    
    private func processResult(result: WeatherResult) {
        if case let .Error(error) = result {
            let alert = UIAlertController(title: "Error", message: "An error occurred while fetching weather information.\n\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        results.append(result)
        resultsTable.insertRows(at: [IndexPath(row: self.results.count - 1, section: 0)], with: .bottom)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cityField.text = userDefaults.lastCity()
    }

}

