//
//  CollectionController.swift
//  Contact Book
//
//  Created by Alexsandre kikalia on 12/24/20.
//

import UIKit
import CoreData



class CollectionController: UIViewController {
    
    
    var dbContext = DBManager.shared.persistentContainer.viewContext
    
    lazy var contacts = [Contact]()

    @IBOutlet var collectionView : UICollectionView!
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            UINib(nibName: "ContactCell", bundle: nil),
            forCellWithReuseIdentifier: "ContactCell"
        )
        
        fetchContacts()
    }
    func fetchContacts() {
        let request = Contact.fetchRequest() as NSFetchRequest<Contact>
        
        do {
            contacts = try dbContext.fetch(request)
            collectionView.reloadData()
        } catch {}
    }
    func deleteContact(index: Int){
        
        dbContext.delete(contacts[index])
        do {
            try dbContext.save()
            fetchContacts()
        } catch {}
    }
    
    func addContact(name: String?, number: String?){
        let contact = Contact(context: dbContext)
        contact.name = name
        contact.phone_number = number
        do{
            try dbContext.save()
            fetchContacts()
        }catch{}
    }
    
    @IBAction func createContact(){
        var name : UITextField!
        var number : UITextField!
        let alert = UIAlertController(
            title: "Add Contact",
            message: "",
            preferredStyle: .alert)
        alert.addTextField{ textfield in
            name = textfield
            textfield.placeholder = "Contact Name"
        }
        alert.addTextField{ textfield in
            number = textfield
            textfield.placeholder = "Contact Number"
            textfield.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler:  { _ in
            self.addContact(name: name.text, number: number.text)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}


private func getInitials(name: String?) -> String{
    var res = ""
    if let name = name{
        var comp = name.split(separator: " ") //name.components(separatedBy: " ").filter(<#T##isIncluded: (String) throws -> Bool##(String) throws -> Bool#>)
        if !comp.isEmpty{
            let first = comp.removeFirst()
            res.append(first[first.startIndex])
            if comp.count > 0{
                let last = comp.removeLast()
                res.append(last[last.startIndex])
            }
        }
        
    }
    return res
}
private func getFirstName(fullName: String?) -> String{
    var res = ""
    if let name = fullName{
        var comp = name.split(separator: " ")
        if !comp.isEmpty{
            let first = comp.removeFirst()
            res.append(contentsOf:  first)
        }
    }
    return res
}

extension CollectionController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCell", for: indexPath)
        if let cellEdit: ContactCell = cell as? ContactCell{
            cellEdit.delegate = self
            cellEdit.name.text = getFirstName(fullName: contacts[indexPath.row].name)
            cellEdit.fullName = contacts[indexPath.row].name ?? ""
            cellEdit.initials.text = getInitials(name: contacts[indexPath.row].name)
            cellEdit.number.text = contacts[indexPath.row].phone_number
            cellEdit.id = indexPath.row
        }
        return cell
    }
    
}


extension CollectionController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: Constants.Insets.top, left: Constants.Insets.left, bottom: Constants.Insets.bottom, right: Constants.Insets.right)
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.spacingX
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.spacingY
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath ) -> CGSize {

        var width = CGFloat.init(125)
        
        if collectionView.frame.width <= 428{
            let innerWidth = collectionView.frame.width - Constants.Insets.left - Constants.Insets.right
           width = (innerWidth - (Constants.numCols-1) * Constants.spacingX) / Constants.numCols
        }
        
        return CGSize(width: width - 1, height: 1.3 * width)
    }

    
}
extension CollectionController: ContactCellDelegate{
    func contactCellDelegateLongPress(_ sender: ContactCell, id: Int, name: String?) {
        let alert = UIAlertController(
            title: "Delete Contact?",
            message: "contact " + (name ?? "")  + " will be deleted",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
            self.deleteContact(index: id)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension CollectionController {
    
    struct Constants {
        static let numCols : CGFloat = 3
        static let spacingX: CGFloat = 12
        static let spacingY: CGFloat = 20
        struct Insets {
            static let top : CGFloat = 12
            static let bottom : CGFloat = 12
            static let left : CGFloat = 12
            static let right : CGFloat = 12
        }
    }
}

