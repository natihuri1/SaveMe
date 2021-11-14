
import  Foundation


class SafeZone {
    
    private(set) var lat: NSNumber!
    private(set) var lon: NSNumber!
    private(set) var documentId: String!
    
    
    init(lat:NSNumber, lon:NSNumber, documentId: String)
    {
        self.lat = lat
        self.lon = lon
        self.documentId = documentId
    }
    
}
