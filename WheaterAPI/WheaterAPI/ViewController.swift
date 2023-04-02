//
//  ViewController.swift
//  WheaterAPI
//
//  Created by ARIF on 3/26/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController{
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempatureLabel: UILabel!
    @IBOutlet weak var windInfoLabel: UILabel!
    @IBOutlet weak var windDirInfoLabel: UILabel!
    @IBOutlet weak var atmPressureLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var wheaterDescLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userLocationCity = ""
    let activityIndicatorView = UIActivityIndicatorView()
    var country = ""
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        dateLabel.isHidden = true
        locationLabel.isHidden = true
        imageView.isHidden = true
        tempatureLabel.isHidden = true
        windInfoLabel.isHidden = true
        windDirInfoLabel.isHidden = true
        atmPressureLabel.isHidden = true
        visibilityLabel.isHidden = true
        humidityLabel.isHidden = true
        wheaterDescLabel.isHidden = true

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserLocation()
        
    }
    
    func apiRequest(){
        
        let url = URL(string: "http://api.weatherstack.com/current?access_key=533016de2176aed023d7dad8a4eed0ba&query=\(userLocationCity)")
        if let urlRequest = url{
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { (data,response,error) in
                if error != nil{
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                    alertController.addAction(okButton)
                    self.present(alertController, animated: true)
                    
                }else {
                    
                    if data != nil {
                        
                        if let responseData = data {
                            
                            do{
                                
                                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String,Any>{
                                    
                                    DispatchQueue.main.async {
                                            
                                            if let location = jsonResponse["location"] as? [String:Any]{
                                                
                                                if var date = location["localtime"] as? String{
                                                    date.removeLast(6)
                                                    self.dateLabel.text = date
                                                    
                                                    if let name = location["name"] as? String{
                                                        self.name = name
                                                        
                                                        if let country = location["country"] as? String{
                                                            self.country = country
                                                            
                                                            self.locationLabel.text = "\(name),\(country)"
                                                            
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if let current = jsonResponse["current"] as? [String:Any]{
                                            
                                            if let windDir = current["wind_dir"] as? String{
                                                self.windDirInfoLabel.text = windDir
                                            }
                                            
                                            if let humadity = current["humidity"] as? Int{
                                                self.humidityLabel.text = "\(humadity)%"
                                            }
                                            
                                            if let visibility = current["visibility"] as? Int{
                                                self.visibilityLabel.text = "\(visibility) km"
                                            }
                                            
                                            if let atmPresssure = current["pressure"] as? Int{
                                                self.atmPressureLabel.text = "\(atmPresssure) mb"
                                            }
                                            
                                            if let windSpeed = current["wind_speed"] as? Int{
                                                self.windInfoLabel.text = "\(windSpeed) km/s"
                                            }
                                            
                                            if let tempature = current["temperature"] as? Int{
                                                self.tempatureLabel.text = "\(tempature)°C"
                                            }
                                            
                                                if let wheatherDescription = current["weather_descriptions"] as? [String]{
                                                
                                                    self.wheaterDescLabel.text = wheatherDescription[0]

                                                }
                                            
                                            
                                            if let wheatherIcon = current["weather_icons"] as? [String]{
                                                
                                                guard let url = URL(string: wheatherIcon[0]) else{
                                                    print("Unvalid URL")
                                                    return
                                                }
                                                
                                                URLSession.shared.dataTask(with: url) { data, response, error in
                                                    if let error = error {
                                                        print(error.localizedDescription)
                                                        return
                                                    }

                                                    guard let data = data, let image = UIImage(data: data) else {
                                                        print("No data or invalid image data")
                                                        return
                                                    }

                                                    DispatchQueue.main.async {
                                                        self.imageView.image = image
                                                    }
                                                }.resume()
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        self.activityIndicatorView.stopAnimating()
                                       
                                        self.dateLabel.isHidden = false
                                        self.locationLabel.isHidden = false
                                        self.imageView.isHidden = false
                                        self.tempatureLabel.isHidden = false
                                        self.windInfoLabel.isHidden = false
                                        self.windDirInfoLabel.isHidden = false
                                        self.atmPressureLabel.isHidden = false
                                        self.visibilityLabel.isHidden = false
                                        self.humidityLabel.isHidden = false
                                        self.wheaterDescLabel.isHidden = false
                                        
                                        
                                    }
                                }
                            }catch{
                                
                            }
                            
                        }
                    }
                }
            }
                    
                    task.resume()
                }
            }
        
        
        func getUserLocation() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }

    
    extension ViewController: CLLocationManagerDelegate {
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse:
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                manager.startUpdatingLocation()
            default:
                break
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first else { return }
                
                if let city = placemark.locality {
                    self.userLocationCity = city
                    print(self.userLocationCity)
                    self.apiRequest()
                }
            }
        }
    }







