//
//  ViewController.swift
//  VendingMachine
//
//  Created by Jay Zalawadia on 1/14/17.
//  Copyright © 2017 Jay Zalawadia. All rights reserved.
//

import UIKit
private let screenWidth = UIScreen.main.bounds.width
private let reuseIdentifier = "vendingItem"

class ViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
        
    @IBOutlet weak var balanceLabel: UILabel!
    
    var vendingMachine : vendingMachine
    var currentSelection : VendingSelection?
    var quantity = 1
    
    required init?(coder aDecoder: NSCoder) {
        do{
            let dict = try PlistConverter.dictionary(fromFile: "VendingInventory", ofType: "plist")
            let inventory = try InventoryConverter.vendingInventory(fromDict: dict)
            self.vendingMachine = FoodVendingMachine(inventory: inventory)
        }
        catch let error{
            fatalError("\(error)")
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpCollectionViewCells()
      //  print(vendingMachine.inventory)
        
        balanceLabel.text = "$\(vendingMachine.amountDeposited)"
        totalLabel.text = "$00.00"
       // quantityLabel.text = "0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
    
    func setUpCollectionViewCells(){
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding : CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        
        
    }
    
    @IBAction func purchase(_ sender: Any) {
        
        if let currentSelection = currentSelection{
            do{
                try vendingMachine.vend(currentSelection, quantity)
                balanceLabel.text = "$\(vendingMachine.amountDeposited)"
            }catch VendingMachineError.insufficientAmount(required: vendingMachine.amountDeposited) {
                showAlert(title: "out of stock", message: nil, preferredStyle: .alert)
            }catch let error{
                fatalError("\(error)")
            }
            
        }else{
        
        }
    }
    
    func showAlert(title:String, message:String? = nil, preferredStyle: UIAlertControllerStyle =     .alert){
        let alertController = UIAlertController(title: title   , message: message, preferredStyle: preferredStyle)
        let okAction =  UIAlertAction(title: "OK", style: .default, handler: nil)
       
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true , completion: nil)
    }
    
        //below the functions comes from UICollectionViewDataSource protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return vendingMachine.selection.count
       //return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
     guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VendingItemCell
        else{ fatalError() }
        
        let item = vendingMachine.selection[indexPath.row]
        
        cell.iconView.image = item.image()
        return cell
    }
    
    func updateValue(){
        
    
    }
    
    //below the functions comes from UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
        
        currentSelection = vendingMachine.selection[indexPath.row]
        updateTotalBalance()
        
       // quantityLabel.text = String(1.0)

        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }

    func updateCell(having indexPath: IndexPath, selected: Bool) {
        
        let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0)
        let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
        }
    }


    @IBAction func valueChanger(_ sender: UIStepper) {
        //print(sender.value)
        
        quantity = Int(sender.value)
        quantityLabel.text = String(sender.value)
        
        updateTotalBalance()
    }
    
    func updateTotalBalance(){
        
        
        if let currentSelection = currentSelection {
            let item = vendingMachine.item(forSelection: currentSelection)
            
            priceLabel.text = "$\(item!.price)"
           // quantityLabel.text = "\(item!.quantity)"
            
            
            totalLabel.text = "$\(item!.price * Double(quantity))"
            
        }
    
    }
    
    @IBAction func addFund(_ sender: Any) {
        
        vendingMachine.amountDeposited += 5.00
        balanceLabel.text = "$\(vendingMachine.amountDeposited)"

    }
    

}

