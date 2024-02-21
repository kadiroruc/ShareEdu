//
//  UserProfileViewController.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 19.02.2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserProfilePostsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let cellId = "cellId"
    
    var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.rgb(red: 255, green: 49, blue: 48)

        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchUser()
        
        navigationController?.navigationBar.tintColor = .black
    }
    var posts = [Post]()
    
    fileprivate func fetchOrderedPosts(){
        guard let uid = self.user?.uid else {return}
        
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded) {[weak self] snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let user = self?.user else {return}
            
            
            let post = Post(user: user, dictionary: dictionary)
            
            self?.posts.insert(post, at: 0)
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell

        cell.post = posts[indexPath.item]
        return cell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
//        cell.backgroundColor = .white
//        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width-2)/3
        return CGSize(width: width, height: width)
    }
    
    
    var user:User?
    fileprivate func fetchUser(){
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid: uid) {[weak self] user in
            self?.user = user
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.fetchOrderedPosts()
            }
        }
    }
}

