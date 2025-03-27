//
//  ViewController.swift
//  Horizon
//
//  Created by Vijay Venkatesan on 3/24/25.
//

import UIKit
import CoreLocation
import Toast

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var forecastLabel: UILabel!
    
    let weatherService = WeatherService()
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    @IBAction func detectLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        getCityName(from: location)
    }
    // CLLocationManager Delegate - Handle errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    // Convert coordinates to city name
    func getCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, let city = placemark.locality else {
                print("Could not get city name")
                self?.view.makeToast("Could not get city name.", duration: 5.0, position: .top)
                return
            }
            print("Detected city: \(city)")
            self.view.makeToast("Detected city: \(city)", duration: 5.0, position: .top)
            self.fetchWeather(for: city)
        }
    }
    // Fetch weather data for detected city
    func fetchWeather(for city: String) {
        weatherService.fetchWeather(for: city) { [weak self] weatherData in
            guard let self = self, let data = weatherData else { return }
            
            let weatherDescription = data.weather.first?.description.capitalized ?? "No data"
            let roundedTemp = round(data.main.temp)
            let tempDisplay = roundedTemp.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(roundedTemp)) : String(roundedTemp)
            
            self.cityLabel.text = data.name
            self.temperatureLabel.text = "\(Int(round(data.main.temp))) °F"
            self.loadWeatherIcon(iconCode: data.weather.first?.icon ?? "")
            self.descriptionLabel.text = data.weather.first?.description
        }
        
        weatherService.fetchForecast(for: city) { [weak self] forecastList in
            guard let self = self, let forecastList = forecastList else { return }
            
            let forecastText = forecastList.prefix(5).map { forecast in
                let dateText = self.formatDate(forecast.dt_txt)
                let temp = round(forecast.main.temp)
                let tempDisplay = temp.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(temp)) : String(temp)
                return "\(dateText): \(tempDisplay)°F"
            }.joined(separator: "\n")
            
            self.forecastLabel.text = forecastText
        }
    }

    
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let city = cityTextField.text, !city.isEmpty else { return }
        weatherService.fetchWeather(for: city) { [weak self] weatherData in
            guard let self = self, let data = weatherData else { return }
            self.cityLabel.text = data.name
            self.temperatureLabel.text = "\(Int(round(data.main.temp))) °F"
            self.loadWeatherIcon(iconCode: data.weather.first?.icon ?? "")
            self.descriptionLabel.text = data.weather.first?.description
            
        }
        // Fetch 5-day forecast
        weatherService.fetchForecast(for: city) { [weak self] forecastList in
            guard let self = self, let forecastList = forecastList else { return }
            
            // Format the forecast display (e.g., first 5 time slots)
            let forecastText = forecastList.prefix(5).map { forecast in
                let dateText = self.formatDate(forecast.dt_txt) // Convert date format
                let temp = round(forecast.main.temp)
                let tempDisplay = temp.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(temp)) : String(temp)
                return "\(dateText): \(tempDisplay)°F"
            }.joined(separator: "\n")
            
            self.forecastLabel.text = forecastText
        }
    }
    
    // Convert "yyyy-MM-dd HH:mm:ss" to a short format like "Tue 3 PM"
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "E h a" // Example: "Tue 3 PM"
            return formatter.string(from: date)
        }
        return dateString // Fallback to raw string if parsing fails
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
