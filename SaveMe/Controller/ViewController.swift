//
//  ViewController.swift
//  SaveMe
//
//  Created by maor elimelech on 09/07/2019.
//  Copyright © 2019 M.O.N Team. All rights reserved.
//
import MapKit
import UIKit
import GeoFire
import FirebaseAuth
import Firebase
import FirebaseFirestore
import RevealingSplashView


 // 4.8 last update
///////////////////Reports
///////////////////Parking
///////////////////User


class ViewController: UIViewController {
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var helpDetailsView: UIView!
    @IBOutlet weak var relevanceView: UIView!
    @IBOutlet weak var logoOfView: UIImageView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnDissLike: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var reliabilityLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var navigationPark: UIButton!
    
    var isInitiallyZoomedToUserLocation: Bool = false
    
    var titlePin : String = ""
    var type = false
    var GPS:String?
    var lat:Double?
    var lon:Double?
    
    var userLatAddress : Double?
    var userLonAddress : Double?
    
    
    var mySafeZoneLat : Double?
    var mySafeZoneLon : Double?
    var userIsProtected = false
    
    var myCarLat : Double?
    var myCarLon : Double?
    
    var myReportLat : Double?
    var myReportLon : Double?
    
    var reportsCorrdinateLatDB : Double?
    var reportsCorrdinateLonDB : Double?

    
    var reportStreetAdressView : String?
    var reportCityAdressView : String?
    
    
    var created : Date?
//
    var userIsParked = false
    private var reports = [Reports]()
    
    
    let regionRaduis : Double = 250
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let userLocation = MKUserLocation()
    let annotation = MKPointAnnotation()
    
    
    let geoCoder = CLGeocoder()
    let locationManger = CLLocationManager()
    private var locationManager1: CLLocationManager!
    private var currentLocation: CLLocation?
    let reportsID = (UIDevice.current.identifierForVendor?.uuidString)!
    
    var delegate: CenterVCDelegate?
    
    let reveailingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .green)
    
    
    override func viewDidLoad() {
//        listenReportsData()
        super.viewDidLoad()
        //offLineViewController.sharedInstance.observeReachability()
        locationManger.requestWhenInUseAuthorization()
        myMap.delegate = self
        locationManger.delegate = self
        myMap.showsUserLocation = true
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        configureLocationService()
        
        DataService.instance.REF_REPORTS.observe(.value, with:  { (snapshot) in
            self.chekeProtectedAndGetData()
            
        })
        
       
       
        
        
        self.view.addSubview(reveailingSplashView)
        reveailingSplashView.animationType = SplashAnimationType.heartBeat
        reveailingSplashView.startAnimation()
        
        
        reveailingSplashView.heartAttack = true

    }
    
    func chekeProtectedAndGetData() {
        DataService.instance.REF_USERS.observe(.value, with:  { (snapshot) in
            if let usersnapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in usersnapShot{
                    if user.key == Auth.auth().currentUser?.uid {
                        if user.childSnapshot(forPath: "userIsProtected").value as? Bool == true {
                            self.getReportsAnnonationFromDB()
                            self.myMap.tintColor = .red

                        } else {
                            self.myMap.tintColor = .blue
                            return
                        }
                        
                    }
                }
            }
            
        })
        
    }
    
    fileprivate func checkIfConnected () {
        
        if Auth.auth().currentUser?.uid == nil {
            
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.present(viewController, animated: true, completion: nil)
        }
    }


                                                            //////REPORTS FUNCS///////////
    

    func uploadReportDB() {
        let userCurrentID = Auth.auth().currentUser?.uid
        DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["report": [self.myReportLat!,self.myReportLon!]])
    }
    
    func getReportsAnnonationFromDB(){
        print("need to load reports")
        DataService.instance.REF_REPORTS.observeSingleEvent( of: .value, with:  { (snapshot) in
            print("first check")
            if let reportsSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for report in reportsSnapshot {
                    print("searching reports..")
                    if report.hasChild("coordinate") {
                        print("find report")
                        
                        if let reportDict = report.value as? Dictionary<String , AnyObject> {
                        // coordinateArry preper to handle the values in "report" child as arry
                            let coordinateArray = reportDict["coordinate"] as! NSArray
                            //reportCoordinate get the report Coordinate from coordinateArray
                            //[0] = lat
                            //[1] = lon
                            let reportCoordinate = CLLocationCoordinate2D (latitude: coordinateArray[0] as!CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                           

                            
                            let annonation = ReportsAnnotation(coordinate: reportCoordinate, key: report.key)
                            if (annonation as? ReportsAnnotation) != nil{
                                self.myMap.addAnnotation(annonation)
                                self.getAddresFromDB()
                                
                            }
                        }
                        
                    }
                    
                }
            }
        })
    }

//
    func removeStickReport()
    {
        for annotation in myMap.annotations {
            if annotation is ReportsAnnotation {
                myMap.removeAnnotation(annotation)
                
            }
            
            for annotation in myMap.annotations {
                if annotation is ReportsAnnotation {
                    myMap.removeAnnotation(annotation)
                }
                
            }
        }
        
    }
    
    func addStickForDanger(){
        
        let reportCoordinate = locationManger.location?.coordinate
        
        let reportAnnotation = ReportsAnnotation(coordinate: reportCoordinate!, key: Auth.auth().currentUser!.uid)
        myMap.addAnnotation(reportAnnotation)
    }

    @IBAction func btnReport(_ sender: Any) {
       
        self.myReportLon = self.locationManger.location!.coordinate.longitude
        self.myReportLat = self.locationManger.location!.coordinate.latitude
        self.getAdress()
        //self.getAddresFromDB()
        checkIfConnected()
        print("street: \(self.reportStreetAdressView) city: \(self.reportCityAdressView)")
        alertReport()
        
    }
    
    func alertReport()  {
        //alert for the user when he want to change his location
        
        //            let alert = UIAlertController(title: "הפעל הגנה עצמאית", message: "לשנות מקום הגנה?", preferredStyle: .alert)
        let alert = UIAlertController(title: "דיווח", message: "יש סכנת דוח?" , preferredStyle: .alert)
        
    alert.addAction(UIAlertAction(title: "כן!", style: .default, handler: { action in

            self.removeStickReport()
            self.addStickForDanger()
            self.uploadeReports()
            self.saveReportsData()
            
        }))
        alert.addAction(UIAlertAction(title: "לא, כבר לא", style: .default, handler: { action in
            return
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEvent.EventSubtype.motionShake{
            // לשים את כל הפעולות שברגע השקשוק ייקרו!!
            type = true
            lon = locationManger.location!.coordinate.longitude
            lat = locationManger.location!.coordinate.latitude
            shakaShakaAlert()
        }
    }
    
    func postReportInInstagram() {
        let alert = UIAlertController(title: "הגנת חברים", message: "שתף גם חברים מהאינסטגרם", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "שתף", style: .default, handler: { action in
        // some funcs to upload image to story instragm
            return
            
        }))
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        
    }
    
    func shakaShakaAlert() {
        let alert = UIAlertController(title: "Succes Report", message: "thank you your for your Report!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    @IBAction func btnSettings(_ sender: Any) {
//        guard  let setting = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") else
//        {return}
//        presentDetails(setting)
         delegate?.toggeLeftPanel()
    }


    func  saveReportsData()
    {
        let db = Firestore.firestore()
//        let gp = GeoFire()
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection(REPORT_REF).addDocument(data: [
            DEVICE_ID : reportsID,
            "userId" : Auth.auth().currentUser!.uid,
            TYPE : type,
            LAT :  myReportLat!,
            LON : myReportLon!,
            CREATED_REPORT : FieldValue.serverTimestamp()
            
                        
            
        ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }

    }

                                                        /////////// PARKING FUNCS //////////
    
    
    
    //alert for check if the user want to change the location parking
    func alertDialogForParking(){
         let userCurrentID = Auth.auth().currentUser?.uid
        let parkingAlert = UIAlertController(title: "הגנת רכב", message: "ברגע זה מופעלת מערכת דיווחים באיזור הרכב שלך", preferredStyle: UIAlertController.Style.alert)
        
        parkingAlert.addAction(UIAlertAction(title: "הפעל", style: .default, handler: { (action: UIAlertAction!) in
            self.makeParkingZone()
            self.removeStickForPark()
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["userIsParking": true])
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["parkCoordinate": [self.myCarLat!,self.myCarLon!]])
            self.addStickForPark()

        }))
        
        parkingAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(parkingAlert, animated: true, completion: nil)
    }
    func makeParkingZone()
    {
        myCarLat = locationManger.location?.coordinate.latitude
        myCarLon = locationManger.location?.coordinate.longitude
        parkLocation()
    }
    func alertDialogForPermission() {
        let alertController = UIAlertController (title: " not determined authorization for location", message: "please go to setting for open your location ", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //allert for the parking if the user dont parked his car yet
    func alertForHaveNoParking() {
        let alert = UIAlertController(title: "Cannot go to your parking", message: "you dont parked your car yet", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    //alert for the user when he want to change his location
    
    func alertDialogForChangeParking(){
        let userCurrentID = Auth.auth().currentUser?.uid
        let parkingAlert = UIAlertController(title: "הגנת רכב", message: "מרגע זה אנחנו נדאג לעדכן אותך אם היה דיווח על שוטר ליד הרכב שלך", preferredStyle: UIAlertController.Style.alert)
        
        parkingAlert.addAction(UIAlertAction(title: "מקום חנייה חדש", style: .default, handler: { (action: UIAlertAction!) in
            
            self.makeParkingZone()
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["userIsParking": true])
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["parkCoordinate": [self.myCarLat!,self.myCarLon!]])
            self.removeStickForPark()
            self.addStickForPark()
        }))
        
        parkingAlert.addAction(UIAlertAction(title: "בטל הגנה על הרכב", style: .default, handler: { action in
            self.removeStickForPark()
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["userIsParking": false])
            DataService.instance.REF_USERS.child(userCurrentID!).child("parkCoordinate").removeValue()
            
        }))
        parkingAlert.addAction(UIAlertAction(title: "חזור", style: .default, handler: { action in
            return
            
        }))
        present(parkingAlert, animated: true, completion: nil)
    }
    

    
    @IBAction func btnParking(_ sender: Any)
    {
         checkIfConnected()
        //check the permission when the user tap and if not show alert else add the new stick
        if authorizationStatus == .denied || authorizationStatus == .notDetermined
        {
            alertDialogForPermission()
        }
        checkParked()
    }

    
    
    
    @IBAction func centerOnCar(_ sender: Any) {
        getUserInfo()
        // if the parking dont got a stick yet show alert else take to the park location
        if userIsParked
        {
            parkLocation()
        }
        else{
            alertForHaveNoParking()
        }
    }
    
    func checkParked()
    {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for user in userSnapshot
                {
                    if user.key == Auth.auth().currentUser?.uid{
                        
                        if user.childSnapshot (forPath: "userIsParking").value as! Bool == false
                        {
                            self.userIsParked = false
                            self.alertDialogForParking()
                        }
                        else
                        {
                            self.userIsParked = true
                            self.alertDialogForChangeParking()
                        }
                        
                    }
                    
                    
                }
            }
            
            
        }
        
    }
    
    func addStickForAlert() {
        let alertCoordinate = locationManger.location?.coordinate
        
        let alertAnnotation = AlertAnnotions(coordinate: alertCoordinate!, key: Auth.auth().currentUser!.uid)


        myMap.addAnnotation(alertAnnotation)
    }
    
    func addStickForPark(){
        
        let parkCoordinate = locationManger.location?.coordinate
        
        let parkAnnotation = ParkAnnotation(coordinate: parkCoordinate!, key: Auth.auth().currentUser!.uid)
        
        myMap.addAnnotation(parkAnnotation)
        
        
        
    }
    
    //remove Stick for the park
    func removeStickForPark(){
        
        for annotation in myMap.annotations {
            if annotation is ParkAnnotation
            {
                myMap.removeAnnotation(annotation)
                return
            }
            
            
        }
    }
    
    
                                                    ///////USER FUNCS//////
    
    
    fileprivate func getUserInfo () {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with:  { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for user in userSnapshot
                {
                    //find the current user
                    if user.key == Auth.auth().currentUser?.uid
                    {   print("get user info")
                        //if is parked he have parkCoordinate child
                        if user.hasChild("parkCoordinate")
                        {   print("find user car")
                            //parkDict holding the value From the user
                            if let parkDict = user.value as? Dictionary<String , AnyObject> {
                                //coordinateArry preper to handle the values in "parkCoordinate" child as arry
                                let coordinateArray = parkDict["parkCoordinate"] as! NSArray

                                //parkCoordinate get the report Coordinate from coordinateArray
                                let parkCoordinate = CLLocationCoordinate2D (latitude: coordinateArray[0] as!CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                //set the values on myCarLat, myCarLon to show parkingPin
                                self.myCarLat = coordinateArray[0] as? Double
                                self.myCarLon = coordinateArray[1] as? Double

                                let annonation = ParkAnnotation(coordinate: parkCoordinate, key: user.key)
                                if (annonation as? ParkAnnotation) != nil{
                                    self.myMap.addAnnotation(annonation)
                                }
                            }

                        }
//                        //get user status to our variable...
                       self.userIsProtected = (user.childSnapshot(forPath: "userIsProtected").value as? Bool)!
                       self.userIsParked = (user.childSnapshot(forPath: "userIsParking").value as? Bool)!
                        //check if user is protected


                    }
                }
            }

        })


    }

    @IBAction func btnWantToHelp(_ sender: Any) {
        alertForHelp()
    }
    func alertForHelp() {
        let alert = UIAlertController(title: "עזרה", message: "מעוניין לעזור לחברים?" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "כן!", style: .default, handler: { action in
//            self.addSticksForHelp()
           self.addStickForAlert()
        }))
        alert.addAction(UIAlertAction(title: "לא, אני עסוק.", style: .default, handler: { action in
            return
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func btnTurnOnSafeZone(_ sender: Any)
    {
         checkIfConnected()
       // checkForReachsbility()
        checkProtected()
    }
    func checkProtected()
    {
//        ref.child("users").child(userID!).observeSingleEvent
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for user in userSnapshot
                {
                    if user.key == Auth.auth().currentUser?.uid
                    {
                        self.userIsProtected = (user.childSnapshot(forPath: "userIsProtected").value as? Bool)!
                        
                    if self.userIsProtected
                    {
                        self.alertForChangeSafeZone()
                        return
                    }
                    else {
                        
                        self.alertForSafeZone()

                    }
                    }
                }
                    
            }
        
        
        }
        
    }

    
    
    @IBAction func btnCenterUserLocation(_ sender: Any){
        //if the user denied the authorization ask again
        if  authorizationStatus == .denied {
            alertDialogForPermission()
        }
        else if  authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
    
    
    func alertForSafeZone() {
        let userCurrentID = Auth.auth().currentUser?.uid
        let alert = UIAlertController(title: "הפעל הגנה עצמאית", message: "ברגע שהופעלה ההגנה עצמאית אנחנו ננסה לעדכן אותך אם קיימת סכנת דוח באיזורך", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "כן", style: .default, handler:{ action in
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["userIsProtected": true])
            
            DataService.instance.REF_USERS.observe(.value, with:  { (snapshot) in
                if let usersnapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    for user in usersnapShot{
                        if user.key == Auth.auth().currentUser?.uid {
                            if user.childSnapshot(forPath: "userIsProtected").value as? Bool == true {
                                 self.getReportsAnnonationFromDB()
//                                self.getAddresFromDB()
                            }
                        
                        }
                    }
                }
                
            })
            
        }))
        
        alert.addAction(UIAlertAction(title: "לא", style: .default, handler: { action in
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues([
                "userIsProtected": false]
            )
           
            
            return
        }))
        
        
        self.present(alert, animated: true)
        
        
    }
    
    func alertForChangeSafeZone() {
        
        let userCurrentID = Auth.auth().currentUser?.uid
        let alert = UIAlertController(title: "הפעל הגנה עצמאית", message: "לשנות מקום הגנה?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "כן, השאר אותי מוגן", style: .default, handler:{ action in
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["userIsProtected": true])
            
        }))
        
        alert.addAction(UIAlertAction(title: "בטל הגנה עצמית", style: .default, handler: { action in
            DataService.instance.REF_USERS.child(userCurrentID!).updateChildValues(["userIsProtected": false])
            self.removeStickReport()
        }))
        alert.addAction(UIAlertAction(title: "חזור", style: .default, handler: { action in
            return
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }


func date2string(_ date:Date)->String{
    //date to string
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    let myString = formatter.string(from: date)
    let yourDate = formatter.date(from: myString)
    formatter.dateFormat = "dd-MMM-yyyy"
    let myStringafd = formatter.string(from: yourDate!)
    return myStringafd
}
    func calculateDistance(){
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with:  { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for user in userSnapshot
                {
                    //find the current user
                    if user.key == Auth.auth().currentUser?.uid {
                        if user.hasChild("report")  {
                            //parkDict holding the value From the user
                            if let coorDict = user.value as? Dictionary<String , AnyObject> {
                                //coordinateArry preper to handle the values in "parkCoordinate" child as arry
                                let coordinateArrayRep = coorDict["report"] as! NSArray
                                let coordinateArrayUser = coorDict["coordinate"] as! NSArray
                                
                                let reportCoor = CLLocation(latitude: coordinateArrayRep [0] as! CLLocationDegrees, longitude: coordinateArrayRep[1] as! CLLocationDegrees)
                                
                                let currentUser = CLLocation(latitude: coordinateArrayUser [0] as! CLLocationDegrees, longitude: coordinateArrayUser[1] as! CLLocationDegrees)
                                
                                print("coordinate for distance Current user : \(currentUser) reportCoor : \(reportCoor)")
                                let distanceInMeters = currentUser.distance(from: reportCoor)
                                if (distanceInMeters <= 500 ) {
                                    let distance =   String(format: "%.2f", distanceInMeters)
                                    self.distanceLabel.text = distance + "M"
                                    
                                }
                                else {
                                    self.distanceLabel.text = "too far"
                                }
                                
                                //                                    self.myReportLat = coordinateArray[0] as? Double
                                //                                    self.myReportLon = coordinateArray[1] as? Double
                                //                                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                                
                                
                            }
                        }
                    }
                }
            }
        })
    }
    

    
    func getAdress() {
        
                             let coordinateReports =  CLLocation(latitude: myReportLat!, longitude: myReportLon!)
                            self.geoCoder.reverseGeocodeLocation(coordinateReports, completionHandler:
                                {(placemarks, error) in
                                    if (error != nil)
                                    {
                                        print("reverse geodcode fail: \(error!.localizedDescription)")
                                    }
                                    //print("adress lat: \(self.myReportLat!) adress lon: \(self.myReportLon!)")
                                    let placemarks = placemarks! as [CLPlacemark]
                                    
                                    if placemarks.count > 0 {
                                        let placemarks = placemarks[0]
                                        print("0")
                                        //var address = self.addressLabel.text!
                                        if placemarks.thoroughfare != nil {
                                            
                                            print(placemarks.thoroughfare!)
                                            self.addressLabel.text = placemarks.thoroughfare!
                                            self.cityLabel.text = placemarks.locality!
                                            
                                            
                                            
                                            self.reportStreetAdressView = self.addressLabel.text!
                                            self.reportCityAdressView = self.cityLabel.text!
                                            
                                            
                                        }
                                    }
                            })
        
          }
    
    
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        relevanceView.isHidden = true
    }
    
}
    
    extension ViewController : CLLocationManagerDelegate{
        // when the app are open check if the permission not determined + zoom if determined
        func configureLocationService() {
            if authorizationStatus == .notDetermined{
                locationManger.requestWhenInUseAuthorization()
                locationManger.requestAlwaysAuthorization()
            }
            else {centerMapOnUserLocation()}
        }
        

}

extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(withCoordinate: userLocation.coordinate)

            }

    
        // annotation for the points
    
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if  let annotation = annotation as? ReportsAnnotation {
                let idetifier = "police"
                var view: MKAnnotationView
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: idetifier)
                view.image = UIImage(named: "police")
                return view
            }
            else if  let annotation = annotation as? ParkAnnotation {
                let idetifier = "parking"
                var view: MKAnnotationView
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: idetifier)
                view.image = UIImage(named: "placeholder")
                return view
            }
            
            else if  let annotation = annotation as? AlertAnnotions {
                let idetifier = "alertPin"
                var view: MKAnnotationView
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: idetifier)
                view.image = UIImage(named: "alertpin")
                return view
            }

            return nil
        }
    
            
        //when we click on the annotation
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            self.relevanceView.isHidden = false
            
            self.btnOk.isHidden = false
            self.btnDissLike.isHidden = false
            self.reliabilityLabel?.isHidden = false
            self.navigationPark?.isHidden = true
            self.logoOfView?.image = UIImage(named: "police")
            self.btnDissLike?.setImage(UIImage(named: "dislike"), for: UIControl.State.normal)
            self.btnOk?.setImage(UIImage(named: "like"), for: UIControl.State.normal)
            self.getAddresFromDB()
            self.calculateDistance()
            
        }


        // take the current location from the user
        func centerMapOnUserLocation(){
            guard let coordinate = locationManger.location?.coordinate else {return}
            let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRaduis, longitudinalMeters: regionRaduis)
            myMap.setRegion(coordinateRegion, animated: true)
        }
        //  hanging the parking location
        func parkLocation(){
            let carPlace = CLLocationCoordinate2DMake(myCarLat!,myCarLon!)
            let carCoordinateRegion = MKCoordinateRegion(center: carPlace, latitudinalMeters: regionRaduis * 0.01, longitudinalMeters: regionRaduis * 0.01)
            myMap.setRegion(carCoordinateRegion, animated: true)
        }
        
        func reportLocation(){
            let reportPlace = CLLocationCoordinate2DMake(myReportLat!, myReportLon!)
            let reportCordinateRegion = MKCoordinateRegion(center: reportPlace, latitudinalMeters: regionRaduis * 0.01, longitudinalMeters: regionRaduis * 0.01)
            myMap.setRegion(reportCordinateRegion, animated: true)
        }

 
    
    func uploadeReports()  {
       
        DataService.instance.REF_REPORTS.child(Auth.auth().currentUser!.uid).updateChildValues([
            "coordinate":  [self.myReportLat,
                            self.myReportLon],
            "key": Auth.auth().currentUser?.uid as Any,
            "streesAdress": "\(String(describing: reportStreetAdressView!))"
            , "cityAddress": "\(String(describing: reportCityAdressView!))"])
    }
    
    func getAddresFromDB() {
        print("need to load address reports")
        DataService.instance.REF_REPORTS.observeSingleEvent(of: .value, with:  { (snapshot) in
           
            if let reportsSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for report in reportsSnapshot {
                    print("searching reports..")
                    if report.hasChild("coordinate") {
                        print("find report")
                        
                        if let reportDict = report.value as? Dictionary<String , AnyObject> {
                            // coordinateArry preper to handle the values in "report" child as arry
                             let reportStreetAdressViewDB = (reportDict["streesAdress"] as! String)
                             let reportityCityAdressViewDB = (reportDict["cityAddress"] as! String)
                            
                            self.addressLabel.text = reportStreetAdressViewDB
                            self.cityLabel.text = reportityCityAdressViewDB
                            
//                            self.reportStreetAdressView = self.addressLabel.text!
//                            self.reportityCityAdressView = self.cityLabel.text!
                            
                            }
                        }
                        
                    }
                    
                }
            })
        }
    


}
