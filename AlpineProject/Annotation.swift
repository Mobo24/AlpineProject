

import Foundation
import MapKit
import Contacts

class Annotation: NSObject, MKAnnotation {
  let title: String?
  let state: String?
  var population: Int?
  let coordinate: CLLocationCoordinate2D
  
  init(
    state: String?,
    city: String?,
    population: Int?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = state
    self.state = city
    self.population = population
    self.coordinate = coordinate
    
    super.init()
  }
  
  init?(feature: MKGeoJSONFeature) {
    guard
      let point = feature.geometry.first as? MKPointAnnotation,
      let propertiesData = feature.properties,
      let json = try? JSONSerialization.jsonObject(with: propertiesData),
      let properties = json as? [String: Any]
      else {
        return nil
    }

    title = properties["city"] as? String
    state = properties["state"] as? String
    population = properties["population"] as? Int
    coordinate = point.coordinate
    super.init()
  }
  
    var populationDetails: Int?
    {
        return population
    }
  var mapItem: MKMapItem? {
    guard let location = state else {
      return nil
    }
    
    let addressDict = [CNPostalAddressStreetKey: location]
    let placemark = MKPlacemark(
      coordinate: coordinate,
      addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
 
    return mapItem
  }
  
//  var markerTintColor: UIColor  {
//    switch title {
//    case "OR":
//      return .red
//    case "CA":
//      return .cyan
//    default:
//      return .green
//    }
//  }
  
  var image: UIImage {
    guard let name = title else { return #imageLiteral(resourceName: "pin") }
    
    switch name {
    default:
      return #imageLiteral(resourceName: "pin")
    }
  }
}
