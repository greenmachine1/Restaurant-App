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
    func returnSelectedItem(selectedItem:SavePlacesObject)
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
        //self.createCustomView()
    }
    
    
    func getListOfPlaces(list:[SavePlacesObject]){
        listOfPlaces = list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.mainTableView?.reloadData()
        })
        
    }

    func makeItemAppearSelected(item:SavePlacesObject){
        
        for(_index, _) in self.listOfPlaces.enumerated(){
            // deselecting everything first //
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.mainTableView?.deselectRow(at: IndexPath(row: _index, section: 0), animated: true)
            })
        }
        
        
        
        
        // going through the list and selecting the item //
        for (index, items) in self.listOfPlaces.enumerated(){
            if(item.name! == items.name!){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                    self.mainTableView?.selectRow(at: IndexPath(row: index, section: 0), animated: true,   scrollPosition: UITableViewScrollPosition.middle)
                })
                self.mainTableView?.reloadData()
            }
        }
    }
    
    

    
    func createCustomView(){
        let doneButton:UIButton = UIButton(frame: CGRect(x: self.frame.size.width - 110, y: 10, width: 100, height: 30))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(self.doneButtonOnClick), for: UIControlEvents.touchUpInside)
        doneButton.backgroundColor = Colors.sharedInstance.lightBlue
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
        mainTableView?.backgroundColor = UIColor.clear
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
        
        if(listOfPlaces[indexPath.row].isSaved == true){
            cell?.starImage?.image = UIImage(named: "Star")
        }else{
            cell?.starImage?.image = nil
        }
        
        
        if(distance == 1){
            cell?.distanceLabel?.text = "\(distance) Mile Away"
        }else if(distance < 1){
            cell?.distanceLabel?.text = "<1 Mile Away"
        }else{
            cell?.distanceLabel?.text = "\(distance) Miles Away"
        }
        
        let thisView:UIView = UIView()
        thisView.backgroundColor = Colors.sharedInstance.lightBlue
        cell?.selectedBackgroundView = thisView
        
        return cell!
    }
    
    // passing back the item that was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.returnSelectedItem(selectedItem: self.listOfPlaces[indexPath.row])
    }

    
    @objc func doneButtonOnClick(){
        self.delegate?.returnDoneButtonCalled()
    }

}
