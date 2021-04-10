//
//  ContactCell.swift
//  Contact Book
//
//  Created by Alexsandre kikalia on 12/24/20.
//

import UIKit

protocol ContactCellDelegate: AnyObject{
    func contactCellDelegateLongPress(_ sender: ContactCell, id: Int, name: String?)
}

class ContactCell: UICollectionViewCell {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet var initialsBGView: UIView!
    @IBOutlet var initials: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var number: UILabel!
    var fullName =  ""
    var id: Int?
    
    weak var delegate: ContactCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let touchDown = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTouchDown(_:)))
        wrapperView.addGestureRecognizer(touchDown)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        initialsBGView.layer.cornerRadius = initialsBGView.frame.height / 2
        wrapperView.layer.cornerRadius = 10
        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @objc
    func handleTouchDown(_ sender: UILongPressGestureRecognizer? = nil) {
       if sender?.state == .began{
        if let contactId = id{
            delegate?.contactCellDelegateLongPress(self, id: contactId, name: fullName)
        } else {
            print("contact id not set")
        }
       }
    }
}
