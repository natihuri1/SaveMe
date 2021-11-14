import UIKit
import Firebase

class LoginVC: UIViewController, UITextViewDelegate{

    
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var authBtn: ShadowButton!
    
    override func viewDidLoad() {
        //checkIfConnected()
        super.viewDidLoad()
        //        emailField.delegate = self
        //        passwordField.delegate = self
        
        view.bindToKeyBoard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    

    
   
    @IBAction func authBtnWasPressed(_ sender: Any)
    {
        if emailField.text != nil && passwordField.text != nil {
            authBtn.animatedButton(shuldLoad: true, withMessege: "")
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text{
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            let userData = ["provider": user.user.providerID, "userIsProtected": false,
                                            "userIsParking": false, "parkingNotification": true, "protectNotification": true] as [String: Any]
                            
                            DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData)
                           
                            }
                        
                    print("auth succes with fireBase")
                    self.dismiss (animated: true, completion: nil)
                }
                    else {
                        if let errorCode = AuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .emailAlreadyInUse:
                                print("email already use")
                            case .wrongPassword:
                                print("password wrong")
                            default:
                                self.dismiss(animated: true, completion: nil)
                                print("error code plz try agian \(String(describing: error))")
                            }
                        }
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                if let errorCode = AuthErrorCode(rawValue: error!._code){
                                    switch errorCode {
                                    case .emailAlreadyInUse:
                                        print("email already use")
                                    case .invalidEmail:
                                        print("invaild email")
                                        
                                    default:
                                        self.dismiss(animated: true, completion: nil)
                                        print("error code plz try agian \(String(describing: error))")
                                    }
                                    
                                }
                                
                            } else {
                                if let user = user {
                                    let userData = ["provider": user.user.providerID, "userIsProtected": false,
                                                    "userIsParking": false, "parkingNotification": true, "protectNotification": true] as [String: Any]
                                    DataService.instance.createFirebaseDBUser(uid: user.user.uid, userData: userData)
                                    
                                }
                                print("succes auth new user")
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            }
        }
    }
//
    }

