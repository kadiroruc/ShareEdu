//
//  RequestsTableViewCell.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 20.02.2024.
//

import UIKit

class RequestsCollectionViewCell: UICollectionViewCell {
    
    
    lazy var usernameLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .white
        return lb
    }()
    lazy var emailLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .white
        return lb
    }()
    lazy var messageLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .white
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(usernameLabel)
        addSubview(emailLabel)
        addSubview(messageLabel)

        usernameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        emailLabel.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        messageLabel.anchor(top: emailLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
