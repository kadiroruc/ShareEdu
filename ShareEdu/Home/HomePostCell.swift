//
//  HomePostCell.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 18.02.2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol HomePostCellDelegate{
    func didTapComment(post: Post)
}

class HomePostCell: UICollectionViewCell{
    
    var delegate: HomePostCellDelegate?
    
    var post: Post?{
        didSet{
            guard let postImageUrl = post?.imageUrl else {return}
            
            photoImageView.loadImage(urlString: postImageUrl)
            
            usernameLabel.text = post?.user.username
            guard let profileImageView = post?.user.profileImageUrl else {return}
            userProfileImageView.loadImage(urlString: profileImageView)
            
            setupAttributedCaption()
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let optionsButton: UIButton = {
        let button = UIButton()
        button.setTitle("...", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        return button
    }()

    let requestButton: UIButton = {
        let button = UIButton()
        button.setTitle("Request", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 255, green: 49, blue: 48)
        button.layer.cornerRadius = 7
        button.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func requestButtonTapped(){
        
        let alertController = UIAlertController(title: "Request", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Your E-Mail"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Message"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancelled.")
        }
        
        let okAction = UIAlertAction(title: "Send", style: .default) { _ in
            // Tamam seçildiğinde yapılacak işlemler
            if let email = alertController.textFields?.first?.text, let message = alertController.textFields?.last?.text {
                
                self.saveRequestToDatabese(email: email, message: message)
                // Burada, aldığınız bilgilerle istediğiniz işlemleri yapabilirsiniz.
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        if let collectionView = superview as? UICollectionView, let viewController = collectionView.delegate as? UIViewController {
             viewController.present(alertController, animated: true, completion: nil)
         }
        

    }
    
    func saveRequestToDatabese(email:String, message: String){

        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = post?.user.uid else {return}
        
        let databaseRef = Database.database().reference()
            let followRequestRef = databaseRef.child("requests").childByAutoId()
            
            let request = ["senderId": currentUserId,
                           "receiverId": userId,
                           "status": "pending",
                           "email": email,
                           "message": message
            ]
            
            followRequestRef.setValue(request)
    }
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    @objc func handleComment(){
        guard let post = self.post else {return}
        delegate?.didTapComment(post: post)
    }
    
    fileprivate func setupAttributedCaption(){
        guard let post = self.post else {return}
        
        let firstString = NSAttributedString(string: post.user.username ,attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        let secondString = NSAttributedString(string: "  \(post.caption)",attributes: [.font : UIFont.systemFont(ofSize: 14)])
        let thirdString = NSAttributedString(string: "\n\n",attributes: [.font: UIFont.systemFont(ofSize: 4)]) //small gap
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let fourthString = NSAttributedString(string: timeAgoDisplay,attributes: [.font: UIFont.systemFont(ofSize: 14),.foregroundColor: UIColor.gray])

        let combinedString = NSMutableAttributedString(attributedString: firstString)

        combinedString.append(secondString)
        combinedString.append(thirdString)
        combinedString.append(fourthString)
        
        captionLabel.attributedText = combinedString
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    
        addSubview(userProfileImageView)
        addSubview(photoImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 44, height: 0)
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
        //setupActionButtons()
        addSubview(requestButton)
        requestButton.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: requestButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
