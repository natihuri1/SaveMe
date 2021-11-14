
import Foundation
import MapKit

class AlertAnnotions: NSObject, MKAnnotation {
    dynamic  var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key:String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
