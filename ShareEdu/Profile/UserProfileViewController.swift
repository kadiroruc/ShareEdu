//
//  UserProfileViewControllerr.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 20.02.2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileViewController: UIViewController {
    
    var user:User? {
        didSet{
            guard let profileImageUrl = user?.profileImageUrl else{return}
            
            profileImageView.loadImage(urlString: profileImageUrl)
            
            usernameLabel.text = self.user?.username
            
            setupEditFollowButton()
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        return imageView
    }()
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont(name: "helvetica", size: 20)
        label.textColor = .black
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor.black.cgColor
        label.textAlignment = .center
        label.layer.cornerRadius = 15
        return label
    }()
    let postsLabel:UILabel = {
        let label = UILabel()
        
        let firstString = NSAttributedString(string: "0\n",attributes: [.font : UIFont.boldSystemFont(ofSize: 14),.foregroundColor : UIColor.white])
        let secondString = NSAttributedString(string: "posts",attributes: [.foregroundColor : UIColor.white,.font : UIFont.boldSystemFont(ofSize: 14)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        
        combinedString.append(secondString)
        label.attributedText = combinedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let followersLabel:UILabel = {
        let label = UILabel()
        let firstString = NSAttributedString(string: "0\n",attributes: [.font : UIFont.boldSystemFont(ofSize: 14),.foregroundColor : UIColor.white])
        let secondString = NSAttributedString(string: "followers",attributes: [.foregroundColor : UIColor.white,.font : UIFont.boldSystemFont(ofSize: 14)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        
        combinedString.append(secondString)
        label.attributedText = combinedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let followingLabel:UILabel = {
        let label = UILabel()
        let firstString = NSAttributedString(string: "0\n",attributes: [.font : UIFont.boldSystemFont(ofSize: 14),.foregroundColor : UIColor.white])
        let secondString = NSAttributedString(string: "following",attributes: [.foregroundColor : UIColor.white,.font : UIFont.boldSystemFont(ofSize: 14)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        
        combinedString.append(secondString)
        label.attributedText = combinedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    lazy var editProfileFollowButton:UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    
    var userId: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setUpLogOutButton()
        fetchUser()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo.stack"), style: .done, target: self, action: #selector(userPostsTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        
        
    }
    func setupViews(){
        view.backgroundColor = UIColor.rgb(red: 255, green: 49, blue: 48)
        setUpLogOutButton()
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.topAnchor, left: view.centerXAnchor, bottom: nil, right: nil, paddingTop: 100, paddingLeft: -100, paddingBottom: 0, paddingRight: 0, width: 200, height: 200)

        profileImageView.layer.cornerRadius = 200/2
        profileImageView.clipsToBounds = true
        
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: -60, paddingBottom: 0, paddingRight: 0, width: 120, height: 30)
        
        setupUsersStatsView()
        
        view.addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: nil, paddingTop: 250, paddingLeft: -90, paddingBottom: 0, paddingRight: 0, width: 180, height: 42)
    }
    
    fileprivate func setUpLogOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut(){
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Log Out", style: .destructive,handler: {[weak self] _ in
            do{
                try Auth.auth().signOut()
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController,animated: true)
                
            }catch{
                print("Failed to sign out")
            }
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac,animated: true)
    }
    
    fileprivate func setupUsersStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: usernameLabel.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: -100, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
    }
    
    @objc func handleEditProfileOrFollow(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow"{
            //unfollow
            Database.database().reference().child("following").child(currentUserId).child(userId).removeValue {[weak self] error, ref in
                if let error = error{
                    print("Failed to unfollow user",error)
                    return
                }
                DispatchQueue.main.async {
                    self?.setupFollowStyle()
                }
            }
        }else{
            //follow
            let ref = Database.database().reference().child("following").child(currentUserId)
            let values = [userId:1]
            ref.updateChildValues(values) {[weak self] error, ref in
                if let error = error{
                    print("Failed to follow user",error)
                    return
                }
                DispatchQueue.main.async {
                    self?.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    self?.editProfileFollowButton.setTitleColor(.white, for: .normal)
                }
            }
        }
    }
    fileprivate func setupFollowStyle(){
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
    }
    
    fileprivate func fetchUser(){
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid: uid) {[weak self] user in
            self?.user = user
            
        }
    }
    
    fileprivate func setupEditFollowButton(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if currentUserId != userId{
            
            //check if following
            Database.database().reference().child("following").child(currentUserId).child(userId).observeSingleEvent(of: .value) {[weak self] snapshot in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1{
                    DispatchQueue.main.async {
                        self?.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    }
                }else{
                    DispatchQueue.main.async {
                        self?.setupFollowStyle()
                    }
                }
            }
        }
    }
    
    @objc func userPostsTapped(){
        navigationController?.pushViewController(UserProfilePostsController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
    }
    

}
