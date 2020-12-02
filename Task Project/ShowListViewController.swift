//
//  WorkoutViewController.swift
//  BJAutoScrollingCollectionViewExample
//
//  Created by BadhanGanesh on 15/01/18.
//  Copyright © 2018 Badhan Ganesh. All rights reserved.
//

import UIKit
import AVKit
import Toast_Swift

class ShowListViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var tableview: UITableView!
   
    var subtitles : [AVMediaSelectionOption]?
    var audio : [AVMediaSelectionOption]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.decorateUI()
    }
    
    override func viewDidLayoutSubviews() {
        popupView.layer.borderWidth = 0.5
        popupView.layer.borderColor = UIColor.white.cgColor
    }
    
    func decorateUI(){
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.isOpaque = false
        
        let savedLink = UserDefaults.standard.string(forKey: "HLSPATH")

        let baseUrl = URL(fileURLWithPath: NSHomeDirectory())
        let assetUrl = baseUrl.appendingPathComponent(savedLink!)
        let asset = AVAsset(url: assetUrl)
        subtitles = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible)?.options
        audio = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible)?.options
        
        tableview.tableFooterView = UIView()
        tableview.reloadData()
    }
    
    
    
////////////////////////////////////////////////////////////////////////////////
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            self.dismiss(animated: true, completion: nil)
      }
    }
    
   
        
}

extension ShowListViewController : UITableViewDelegate , UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "AUDIO"
        }else{
            return "SUBTITLES"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return audio?.count ?? 0
        }else{
            return subtitles?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! listCell
            let option = audio?[indexPath.row]
            cell.lblName.text = option?.displayName
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! listCell
            let option = subtitles?[indexPath.row]
            cell.lblName.text = option?.displayName
            return cell
        }
       
    }
    
    
}

