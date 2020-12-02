
import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
  @IBOutlet private var mapView: MKMapView!
  private var artworks: [Annotation] = []
  let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInitialData()
  }
    
  func setupInitialData()
    {
        let initialLocation = CLLocation(latitude: 36.778259, longitude: -119.417931)
        mapView.centerToLocation(initialLocation)
        
        let unitedStatesCoordinates = CLLocation(latitude: 36.778259, longitude: -119.417931)
        let region = MKCoordinateRegion(
          center: unitedStatesCoordinates.coordinate,
          latitudinalMeters: 2000000,
          longitudinalMeters: 2000000)
        mapView.setCameraBoundary(
          MKMapView.CameraBoundary(coordinateRegion: region),
          animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2000000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
        mapView.delegate = self
        
        mapView.register(
          AnnotationView.self,
          forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        loadInitialData()
        mapView.addAnnotations(artworks)
    }
  
    func deleteNilData()
    {
        //used this for testing and deleting unwanted core data entry points which i could not get to the bottom of on time
        let request = Location.fetchRequest() as NSFetchRequest<Location>
        request.returnsObjectsAsFaults = false
        let pred = NSPredicate(format: "city == %a",0)
        request.predicate = pred
        do{
            let example = try context.fetch(request)
            for managedObject in example
            {
                let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                       context.delete(managedObjectData)
            }
        }
        catch let error as NSError{
            print("Delete all data in Location error : \(error) \(error.userInfo)")
        }
    }
    
    func checkAvailabilityCity(entity: String) -> Bool
    {
        do{
            let request = Location.fetchRequest() as NSFetchRequest<Location>
            let pred = NSPredicate(format: "city CONTAINS '\(entity)'")
            request.predicate = pred
            let example:[Location] = try context.fetch(request)
            if example.isEmpty
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch{
            
        }
        return false
    }
    var logFile: URL?
    {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
                let fileName = "population.csv"
                return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func checkAvailabilityState(entity: String) -> Bool
    {
        do{
            let request = Location.fetchRequest() as NSFetchRequest<Location>
            let pred = NSPredicate(format: "state CONTAINS '\(entity)'")
            request.predicate = pred
            let example:[Location] = try context.fetch(request)
            if example.isEmpty
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch{
            
        }
        return false
    }
    
    func create(from Array:[Dictionary<String, AnyObject>])
    {
        let heading = "CITY, STATE, POPULATION\n"
        var dict = Dictionary<String, AnyObject>()
        dict = Array[0]
        let rows = Array.map {"\($0["C"]!), \($0["S"]!) , \($0["P"]!)"}
        let fileContents = "\(String(describing: dict["C"]!)), \(String(describing: dict["S"]!)) , \(String(describing: dict["P"]!))\n"
        guard let data = (fileContents).data(using: String.Encoding.utf8) else { return }
        if FileManager.default.fileExists(atPath: logFile!.path)
        {
            if let fileHandle = try? FileHandle(forWritingTo: logFile!) {
            
                           fileHandle.seekToEndOfFile()
                           fileHandle.write(data)
                           fileHandle.closeFile()
        }
        else
        {
        
            let csvString = heading + rows.joined(separator: "\n")
            do {

                    let path = try FileManager.default.url(for: .documentDirectory,
                                                           in: .allDomainsMask,
                                                           appropriateFor: nil,
                                                           create: false)
                    let fileURL = path.appendingPathComponent("population.csv")
                    try csvString.write(to: fileURL, atomically: true , encoding: .utf8)
                } catch {
                    print("error creating file")
                }
        }
    }
    }
    
  private func loadInitialData() {
    guard
      let fileName = Bundle.main.url(forResource: "Locations", withExtension: "geojson"),
      let annotationData = try? Data(contentsOf: fileName)
      else {
        return
    }
    
    do {
 
      let features = try MKGeoJSONDecoder()
        .decode(annotationData)
        .compactMap { $0 as? MKGeoJSONFeature }
        
      let validWorks = features.compactMap(Annotation.init)
        deleteNilData()
        var Anno = [Annotation]()
        for index in 0...(validWorks.count)-1
        {
           
            let newData = Location(context: self.context)
            //check if data exists in core data already
            print (validWorks[index].title!)
            if checkAvailabilityCity(entity:validWorks[index].title!)
            {
                if validWorks[index].title != nil
                {
                    var anno1: [Annotation] = []
                    newData.city = validWorks[index].title
                    newData.state = validWorks[index].state
                    let pop = Int32(validWorks[index].population!)
                    newData.population = pop
                    newData.latitude = validWorks[index].coordinate.latitude
                    newData.longitude = validWorks[index].coordinate.longitude
                    anno1.append(Annotation.init(state: validWorks[index].title, city: validWorks[index].state, population: Int(newData.population), coordinate: CLLocationCoordinate2D(latitude: newData.latitude, longitude: newData.longitude)))
                    Anno.append(contentsOf: anno1)
                }
            }
            else{
                let request = Location.fetchRequest() as NSFetchRequest<Location>
                do
                {
                    var anno1: [Annotation] = []
                    let example = try self.context.fetch(request)
                    for index in 0...(example.count)-1
                    {
                        let objectUpdate = example[index] as NSManagedObject
                        if objectUpdate.value(forKey: "city") != nil
                        {
                            anno1.append(Annotation.init(state: objectUpdate.value(forKey: "city")! as? String, city: objectUpdate.value(forKey: "state") as? String, population: objectUpdate.value(forKey: "population") as? Int, coordinate: CLLocationCoordinate2D(latitude: objectUpdate.value(forKey: "latitude") as! CLLocationDegrees, longitude:objectUpdate.value(forKey: "longitude") as! CLLocationDegrees)))
                            Anno.append(contentsOf:anno1)
                            try self.context.save()
                        }
                        
                    }
                   
                }
                catch{
                    print("Bad Bad")
                }
                continue
            }
        }
      
      artworks.append(contentsOf: Anno)
    } catch {
      print("Unexpected error: \(error).")
    }
  }
}

private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 10000000) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension ViewController: MKMapViewDelegate {
  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    guard let artwork = view.annotation as? Annotation else {
      return
    }
    let ac = UIAlertController(title: "New Population", message: "Enter Population", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
                if let txtField = ac.textFields?.first, let text = txtField.text {
                    let pop = Int32(text)
                    let request = Location.fetchRequest() as NSFetchRequest<Location>
                    print(artwork.title!)
                    let pred = NSPredicate(format: "city CONTAINS '\(artwork.title!)'")
                    request.predicate = pred
                    if pop! != artwork.population!
                    {
                        do
                        {
                            let example = try self.context.fetch(request)
                            let objectUpdate = example[0] as NSManagedObject
                            objectUpdate.setValue(pop, forKey: "population")
                            var myNewDictArray: [Dictionary<String, AnyObject>] = []
                            var dictionary = Dictionary<String, AnyObject>()
                            dictionary["C"] = objectUpdate.value(forKey: "city") as AnyObject?
                            dictionary["S"] = objectUpdate.value(forKey: "state") as AnyObject?
                            dictionary["P"] = objectUpdate.value(forKey: "population") as AnyObject?
                            myNewDictArray.append(dictionary)
                            self.create(from: myNewDictArray)
                            try self.context.save()
                            DispatchQueue.main.async {
                                self.loadView()
                                self.viewDidLoad()
                            }
                        }
                        catch{
                            print("Error")
                        }
                      
                    }
                   
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            ac.addTextField { (textField) in
                textField.placeholder = "New Population"
                textField.keyboardType = .numberPad
            }
            ac.addAction(confirmAction)
            ac.addAction(cancelAction)
            self.present(ac, animated: true, completion: nil)
  }
  
}
