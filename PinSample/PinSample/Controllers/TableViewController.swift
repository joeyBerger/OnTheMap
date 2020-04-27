//
//  TableViewController.swift
//  PinSample
//
//  Created by Joey Berger on 4/11/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TableViewController :  UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellReuseIdentifier = "ViewCell"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 203/255, green: 235/255, blue: 254/255, alpha: 1.0)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func handleNewPin(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewPinViewController") as! OnTheMap.NewPinViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
    
    @IBAction func handleLogout(_ sender: Any) {
        UdacityClient.deleteSession()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! OnTheMap.LoginViewController
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInfo.studentInfo.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier)!
        cell.imageView?.image = UIImage(named: "mappin")
        let cellInfo = StudentInfo.studentInfo[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(cellInfo.firstName) \(cellInfo.lastName)"
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = StudentInfo.studentInfo[(indexPath as NSIndexPath).row].mediaURL
        if url != "" {
            let app = UIApplication.shared
            app.openURL(URL(string: url)!)
        }
    }
}
