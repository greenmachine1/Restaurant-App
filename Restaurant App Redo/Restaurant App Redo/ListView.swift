//
//  ListView.swift
//  Restaurant App Redo
//
//  Created by Cory Green on 10/26/17.
//  Copyright © 2017 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ListViewDelegate{
    func returnDoneButtonCalled()
    func returnSelectedItem(selectedItem:Int)
}

class ListView: UIView, UITableViewDelegate, UITableViewDataSource {

    var delegate:ListViewDelegate?
    var listOfPlaces:[SavePlacesObject] = []
    
    var reOrganizedListOfPlaces:[SavePlacesObject] = []
    
    var mainTableView:UITableView?
    var selectedIndex:Int?
    var selectedPlace:SavePlacesObject?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.createCustomView()
    }
    
    
    func getListOfPlaces(list:[SavePlacesObject]){
        listOfPlaces = list
    }

    func makeItemAppearSelected(item:SavePlacesObject){
        
        print("Hey there passed in item -->\(item.name!)")
        
        for (index, items) in self.listOfPlaces.enumerated(){
            if(item.name! == items.name!){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                    self.mainTableView?.selectRow(at: IndexPath(row: index, section: 0), animated: true,   scrollPosition: UITableViewScrollPosition.middle)
                })
                self.mainTableView?.reloadData()
            }
        }
        
        
        /*
        let index = listOfPlaces.index(of: item)
        if(index != nil){
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.mainTableView?.selectRow(at: IndexPath(row: index!, section: 0), animated: true,   scrollPosition: UITableViewScrollPosition.middle)
            })
            self.mainTableView?.reloadData()
        }
        */
            
        
        
        /*
        for places in self.listOfPlaces{
            print("count -> \(self.listOfPlaces.count)")
            if(item == places){
                let index = self.listOfPlaces.index(of: places)
                print(index)
            }
        }
        */
        
        /*
        for places in self.listOfPlaces{
            

            let index = self.listOfPlaces.index(of: places)
            if(places == item){
                print("things are good from in here...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                    self.mainTableView?.selectRow(at: IndexPath(row: index!, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
                })
                self.mainTableView?.reloadData()
            }
        }
 
        */
    }
    
    

    
    func createCustomView(){
        let doneButton:UIButton = UIButton(frame: CGRect(x: self.frame.size.width - 110, y: 10, width: 100, height: 30))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(self.doneButtonOnClick), for: UIControlEvents.touchUpInside)
        doneButton.backgroundColor = UIColor.white
        doneButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        doneButton.layer.cornerRadius = 5.0
        doneButton.clipsToBounds = true
        self.addSubview(doneButton)
        
        self.addListView()
    }
    
    func addListView(){
        mainTableView = UITableView(frame: CGRect(x: 10, y: 50, width: self.frame.size.width - 20, height: (self.frame.size.height) - 100))
        
        mainTableView?.delegate = self
        mainTableView?.dataSource = self
        mainTableView?.backgroundColor = UIColor.white
        mainTableView?.layer.cornerRadius = 5.0
        mainTableView?.clipsToBounds = true
        mainTableView?.register(ListViewTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        self.addSubview(mainTableView!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPlaces.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListViewTableViewCell
        cell!.mainLabel?.text = listOfPlaces[indexPath.row].name!
        
        let distance = listOfPlaces[indexPath.row].distanceFromUser!
        
        if(distance == 1){
            cell?.distanceLabel?.text = "\(distance) Mile Away"
        }else if(distance < 1){
            cell?.distanceLabel?.text = "< 1 Mile Away"
        }else{
            cell?.distanceLabel?.text = "\(distance) Miles Away"
        }
        return cell!
    }
    
    // passing back the item that was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.returnSelectedItem(selectedItem: indexPath.row)
        
        tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.blue
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at:indexPath)?.backgroundColor = UIColor.white
    }
    
    
    
    @objc func doneButtonOnClick(){
        self.delegate?.returnDoneButtonCalled()
    }

}
