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
}

class ListView: UIView, UITableViewDelegate, UITableViewDataSource {

    var delegate:ListViewDelegate?
    var listOfPlaces:[SavePlacesObject] = []
    
    var reOrganizedListOfPlaces:[SavePlacesObject] = []
    
    var mainTableView:UITableView?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.createCustomView()
    }
    
    
    func getListOfPlaces(list:[SavePlacesObject]){
        listOfPlaces = list
        self.reOrganizeList(list: listOfPlaces)
        
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
        return reOrganizedListOfPlaces.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListViewTableViewCell
        cell!.mainLabel?.text = reOrganizedListOfPlaces[indexPath.row].name!
        
        
        if(reOrganizedListOfPlaces[indexPath.row].distanceFromUser! == 1){
            cell?.distanceLabel?.text = "\(reOrganizedListOfPlaces[indexPath.row].distanceFromUser!) Mile Away"
        }else if(reOrganizedListOfPlaces[indexPath.row].distanceFromUser! < 1){
            cell?.distanceLabel?.text = "< 1 Mile Away"
        }else{
            cell?.distanceLabel?.text = "\(reOrganizedListOfPlaces[indexPath.row].distanceFromUser!) Miles Away"
        }
        return cell!
    }
    
    
    @objc func doneButtonOnClick(){
        self.delegate?.returnDoneButtonCalled()
    }
    
    // sorting the list of places //
    func reOrganizeList(list:[SavePlacesObject]){
        reOrganizedListOfPlaces = list.sorted(by: {$0.distanceFromUser! < $1.distanceFromUser!})
        mainTableView?.reloadData()
    }
    
    
    
    
    
    
    

}
