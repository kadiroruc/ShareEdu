//
//  RequestsTableViewController.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 20.02.2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RequestsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var requests = [Request]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.rgb(red: 255, green: 49, blue: 48)
        
        collectionView.register(RequestsCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        
        fetchRequestsOfUser()
        
        

    }
    
    func fetchRequestsOfUser(){
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        fetchRequests(forUserId: userId) { requests in
            
            for (_,value) in requests{
                let valueDictionary = value as! [String:Any]
                let request = Request(dictionary: valueDictionary)
                self.requests.append(request)
            }
            
            self.collectionView.reloadData()
            
        }
    }
    
    func fetchRequests(forUserId userId: String, completion: @escaping ([String: Any]) -> Void){
        
        let databaseRef = Database.database().reference().child("requests")
        let query = databaseRef.queryOrdered(byChild: "receiverId").queryEqual(toValue: userId)
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            guard let requests = snapshot.value as? [String: Any] else {
                completion([:])
                return
            }
            completion(requests)
        }
    }

    // MARK: - Collection view data source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requests.count
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! RequestsCollectionViewCell
        cell.layer.cornerRadius = 18
        cell.layer.borderWidth = 3
        
        UsernameOfRequest(request: requests[indexPath.row]) { username in
            DispatchQueue.main.async {

                
                
                if let username = username{
                    cell.usernameLabel.text = "Username: \(username)"
                    
                    let email = self.requests[indexPath.row].email
                    let message = self.requests[indexPath.row].message
                    
                    cell.emailLabel.text = "E-Mail: \(email)"
                    cell.messageLabel.text = "Message: \(message)"
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width // Hücrenin genişliği, collection view'nin genişliği kadar
        let cellHeight: CGFloat = 100 // Hücrenin yüksekliği
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset: CGFloat = 10 // Sağdan ve soldan boşluk miktarı
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    
    func UsernameOfRequest(request: Request, completion: @escaping (String?) -> Void){
        let userId = request.senderId
        
        let ref = Database.database().reference().child("users").child(userId)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let dictionary = snapshot.value as? [String:Any] {
                if let username = dictionary["username"] as? String {
                    completion(username)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
        }
        
    }
    

}
