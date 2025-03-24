import CoreData
import UIKit

func saveWeatherData(weather: [WeatherResponse]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = appDelegate.persistentContainer.viewContext

    // 1. Check if the weather array is empty
    guard !weather.isEmpty else {
        print("⚠️ No weather data to save")
        return
    }

    let weatherEntity = NSEntityDescription.insertNewObject(forEntityName: "WeatherEntity", into: context)

    let firstWeather = weather[0]

    weatherEntity.setValue(firstWeather.lat, forKey: "lat")
    weatherEntity.setValue(firstWeather.lon, forKey: "lon")
    weatherEntity.setValue(firstWeather.timezone, forKey: "timezone")
    weatherEntity.setValue(Date(), forKey: "timestamp")

    let dailyTemperatureMin = firstWeather.daily?.data?.first?.all_day?.temperature_min ?? 0
    weatherEntity.setValue("\(dailyTemperatureMin)", forKey: "mintemp")

    let dailyTemperatureMax = firstWeather.daily?.data?.first?.all_day?.temperature_max ?? 0
    weatherEntity.setValue("\(dailyTemperatureMax)", forKey: "maxtemp")

    weatherEntity.setValue(firstWeather.current?.summary, forKey: "summary")

    let currentTemp = firstWeather.current?.temperature ?? 0
    weatherEntity.setValue("\(currentTemp)", forKey: "temprature")

    do {
        try context.save()
        print("✅ Weather data saved successfully!")
    } catch {
        print("❌ Error saving data: \(error.localizedDescription)")
    }
}

func fetchWeatherDataFromCoreData() -> [WeatherResponse] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return []
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<WeatherEntity> = WeatherEntity.fetchRequest()
    
    // ✅ Sort by timestamp in descending order (newest first)
    let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    do {
        let coreDataResults = try context.fetch(fetchRequest)
        
        // Mapping Core Data objects to WeatherResponse models
        let weatherDataArray: [WeatherResponse] = coreDataResults.compactMap { entity in
            WeatherResponse(
                lat: entity.lat,
                lon: entity.lon,
                elevation: nil,
                timezone: entity.timezone,
                units: nil,
                current: Current(
                    icon: nil,
                    icon_num: nil,
                    summary: entity.summary,
                    temperature: Double(entity.temprature ?? "0") ?? 0.0,
                    wind: Wind(speed: nil, dir: nil, angle: nil),
                    precipitation: Precipitation(total: nil, type: nil),
                    cloud_cover: nil
                ),
                hourly: Hourly(data: [
                    DataWeather(
                        day: nil,
                        weather: nil,
                        icon: nil,
                        summary: nil,
                        all_day: All_day(
                            weather: nil,
                            icon: nil,
                            temperature: nil,
                            temperature_min: nil,
                            temperature_max: nil,
                            wind: nil,
                            cloud_cover: nil,
                            precipitation: nil
                        ),
                        morning: nil,
                        afternoon: nil,
                        evening: nil
                    )
                ]),
                daily: Daily(data: [
                    DataWeather(
                        day: nil,
                        weather: nil,
                        icon: nil,
                        summary: entity.summary,
                        all_day: All_day(
                            weather: nil,
                            icon: nil,
                            temperature: Double(entity.temprature ?? "0") ?? 0.0,
                            temperature_min: Double(entity.mintemp ?? "0") ?? 0.0,
                            temperature_max: Double(entity.maxtemp ?? "0") ?? 0.0,
                            wind: nil,
                            cloud_cover: nil,
                            precipitation: nil
                        ),
                        morning: nil,
                        afternoon: nil,
                        evening: nil
                    )
                ])
            )
        }
        return weatherDataArray
    } catch {
        print("Failed to fetch data from Core Data: \(error.localizedDescription)")
        return []
    }
}

func deleteWeatherData(at indexPath: IndexPath, WeatherData : [WeatherResponse]) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = appDelegate.persistentContainer.viewContext
    
    // Get the object to delete
    let weatherToDelete = WeatherData[indexPath.row]
    
    // Fetch the corresponding Core Data object
    let fetchRequest: NSFetchRequest<WeatherEntity> = WeatherEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "lat == %@ AND lon == %@", weatherToDelete.lat ?? "", weatherToDelete.lon ?? "")
    
    do {
        let objects = try context.fetch(fetchRequest)
        if let objectToDelete = objects.first {
            context.delete(objectToDelete) // Delete from Core Data
            
            try context.save() // Save changes to Core Data
            
            print("✅ Deleted successfully from Core Data and TableView!")
        }
    } catch {
        print("❌ Error deleting data: \(error.localizedDescription)")
    }
}
