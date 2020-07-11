
import Foundation

protocol weatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailError(error: Error)
}

struct WeatherManager {
    
    var delegate: weatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=ed7f7d5620e65cbacfe40fdeaa92f0da"
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    func fetchWeather(_ lan: Double, _ lon: Double){
        let urlString = "\(weatherURL)&lat=\(lan)&lon=\(lon)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                    
                }
                
            }
           
            task.resume()
            
            func parseJSON(_ weatherData: Data) -> WeatherModel?{
                let decoder = JSONDecoder()
                do{
                    let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                    let id = (decodedData.weather[0].id)
                    let temperature = (decodedData.main.temp)
                    let name = (decodedData.name)
                    let windSpeed = (decodedData.wind.speed)
                    
                    let weather = WeatherModel(conditionId: id, cityName: name, temperature: temperature, windSpeed: windSpeed)
                    
                    return weather
                }catch{
                    delegate?.didFailError(error: error)
                    return nil
                }
            }
            
            
            
            
        }
        
    }
}
