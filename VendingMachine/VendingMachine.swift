//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Jay Zalawadia on 1/16/17.
//  Copyright © 2017 Jay Zalawadia. All rights reserved.
//

import Foundation
import UIKit

enum VendingSelection : String {
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
    
    
    
    func image() -> UIImage{
        switch self{
        case .candyBar: return UIImage(named: "CandyBar")!
        case .chips: return UIImage(named: "Chips")!
        case .cookie: return UIImage(named: "Cookie")!
        case .dietSoda: return UIImage(named: "DietSoda")!
        case .fruitJuice: return UIImage(named: "FruitJuice")!
        case .gum: return UIImage(named: "Gum")!
        case .popTart: return UIImage(named: "PopTart")!
        case .sandwich: return UIImage(named: "Sandwich")!
        case .soda: return UIImage(named: "Soda")!
        case .sportsDrink: return UIImage(named: "sportsDrink")!
        case .water: return UIImage(named: "Water")!
        case .wrap: return UIImage(named: "Wrap")!
        }
        
       /* if let image = UIImage(named: self.rawValue){
            return image
        }else{
            return #imageLiteral(resourceName: "Default")
        }*/

    }
    
    
}


protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
}

protocol vendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection:VendingItem] { get set }
    
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection:VendingItem])

    func vend(_ selection: VendingSelection, _ quantity: Int) throws
    func deposit(_ amountDeposited: Double)
    func item(forSelection selection: VendingSelection) -> VendingItem?
}

struct Item: VendingItem{
    let price: Double
    var quantity: Int
}

enum InventoryError:Error{
    case invalidResource
    case conversionError
    case invalidSelection
}

class PlistConverter{
    static func dictionary(fromFile name:String, ofType type:String) throws -> [String : AnyObject]{
        
        guard let file = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        guard let dictConversion = NSDictionary(contentsOfFile: file) as? [String : AnyObject] else{
            throw InventoryError.conversionError
        }
        return dictConversion
        
    }
}

class InventoryConverter{
    static func vendingInventory(fromDict dict: [String : AnyObject]) throws -> [VendingSelection:VendingItem]{
    
        var inventory : [VendingSelection:VendingItem] = [:]
        
        for(key , value) in dict {
            if let itemDict = value as? [String : Any], let price = itemDict["price"] as? Double, let quantity = itemDict["quantity"] as? Int{
                let item = Item(price: price, quantity: quantity)
                
                guard let selection = VendingSelection(rawValue: key) else{
                    throw InventoryError.invalidSelection
                }
                
                inventory.updateValue(item, forKey: selection)
            }
        
        }
        return inventory
    }

}

enum VendingMachineError : Error {
    case invalidSelection
    case insufficientAmount(required : Double)
    case outOfStock
}



class FoodVendingMachine: vendingMachine {
    var selection: [VendingSelection] = [.candyBar,.chips,.cookie,.dietSoda,.fruitJuice, .gum, .popTart , .sandwich]
    
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.00
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(_ selection: VendingSelection, _ quantity: Int) throws {
        guard var item = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        
        guard item.quantity >= quantity else{
            throw VendingMachineError.outOfStock
        }
        
        let totalPrice = item.price * Double(quantity)
        
        if amountDeposited >= totalPrice{
            amountDeposited -= totalPrice
            item.quantity -= quantity
            
            inventory.updateValue(item, forKey: selection)
        }
        
        else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientAmount(required: amountRequired)
        }
    }
    
    func deposit(_ amountDeposited: Double) {
        
    }
    
    func item(forSelection selection: VendingSelection) -> VendingItem? {
        return inventory[selection]
    }
}
