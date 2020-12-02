

import Foundation
import MapKit

class AnnotationMarkerView: MKMarkerAnnotationView {
    @objc func didClickDetailDisclosure(sender: UIButton!) {
        print("Button Clicked")
    }
  override var annotation: MKAnnotation? {
    willSet {
      guard let artwork = newValue as? Annotation else {
        return
      }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      glyphImage = artwork.image
    }
  }
}

class AnnotationView: MKAnnotationView {
    func didClickDetailDisclosure(sender: UIButton!) {
          print("Button Clicked")
     }
  override var annotation: MKAnnotation? {
    willSet {
      guard let annotations = newValue as? Annotation else {
        return
      }
      canShowCallout = true
      calloutOffset = CGPoint(x: -10, y: -10)
      let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24)))
        
        if annotations.title == "Bend"
        {
            mapsButton.setBackgroundImage(#imageLiteral(resourceName: "oregon"), for: .normal)
        }
        else if annotations.title == "San Francisco"
        {
            mapsButton.setBackgroundImage(#imageLiteral(resourceName: "49ers"), for: .normal)
        }
        else{
            mapsButton.setBackgroundImage(#imageLiteral(resourceName: "pin"), for: .normal)
        }
     
      rightCalloutAccessoryView = mapsButton
      
      image = annotations.image
      
      let detailLabel = UILabel()
      detailLabel.numberOfLines = 2
      detailLabel.font = detailLabel.font.withSize(12)
        detailLabel.text = "Population : " + String(annotations.population ?? 0)
         detailCalloutAccessoryView = detailLabel
     
    }
    
  }
    
 
}
