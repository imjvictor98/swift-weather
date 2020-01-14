import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
//MARK:- Variables
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var conditionImageView: UIImageView!
    
    
    let gradientLayer = CAGradientLayer()
    let locationManager = CLLocationManager()
    
    let apiKey = "34ec13b385a5f69476096aca088ad64a"
    
    var lat = -15.776250
    var lon = -47.796619
    var activityIndicator: NVActivityIndicatorView!
    
    
    //MARK:- Lifetime screen
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width - indicatorSize) / 2,
                                    y:(view.frame.height - indicatorSize) / 2,
                                    width: indicatorSize,
                                    height: indicatorSize
        )
        
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame,
                                                    type: .lineScale,
                                                    color: UIColor.white,
                                                    padding: 20.0
        )
        
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
    }

    //MARK:- Functions
    func setBlueGradientBackground() {
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255, alpha: 1.0).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyGradientBackground() {
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255, alpha: 1.0).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
        
            response in
            self.activityIndicator.stopAnimating()
           
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                 
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                self.minTemperature.text = "\(Int(round(jsonTemp["temp_min"].doubleValue)))"
                self.maxTemperature.text = "\(Int(round(jsonTemp["temp_max"].doubleValue)))"
                self.humidityLabel.text = "\(Int(round(jsonTemp["humidity"].doubleValue)))"
                
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let sufix = iconName.suffix(1)
                
                if sufix == "n" {
                    self.setGreyGradientBackground()
                } else {
                    self.setBlueGradientBackground()
                }
            }
            self.locationManager.stopUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error.localizedDescription)
        }
        

    }
}

