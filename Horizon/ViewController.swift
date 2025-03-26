//
//  ViewController.swift
//  Horizon
//
//  Created by Vijay Venkatesan on 3/24/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let weatherService = WeatherService()
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let city = cityTextField.text, !city.isEmpty else { return }
        weatherService.fetchWeather(for: city) { [weak self] weatherData in
            guard let self = self, let data = weatherData else { return }
            self.cityLabel.text = data.name
            self.temperatureLabel.text = "\(Int(round(data.main.temp))) °F"
            self.loadWeatherIcon(iconCode: data.weather.first?.icon ?? "")
            self.descriptionLabel.text = data.weather.first?.description
            
        }
    }
    
    func loadWeatherIcon(iconCode: String) {
        let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
        if let url = URL(string: iconURLString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = image
                    }
                }
            }.resume()
        }
    }
}
