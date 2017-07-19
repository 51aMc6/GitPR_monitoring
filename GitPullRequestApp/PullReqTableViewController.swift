//
//  PullReqTableViewController.swift
//  GitPullRequestApp
//
//  Created by Siamac 6 on 7/18/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

class PullReqTableViewController: UITableViewController {

    var pullReqData = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Refreash Table Data from remote API - rightButtonBarItem
    @IBAction func refreashPRlist(_ sender: UIBarButtonItem) {
        NetworkServices.fetchGithubRepos(with: nil, callback:{ payload in
            self.pullReqData = payload
            self.tableView.reloadData()
        })
        let ip = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: ip, at: .top, animated: false)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.pullReqData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)

        let prObj : Dictionary = pullReqData[indexPath.row] as Dictionary
        
        cell.textLabel?.text = prObj["title"] as! String?
        let createDate = prObj["created_at"] as! String
        let myDate = self.dateFormatter(strDate: createDate)
        var name = ""
        if let user = prObj["user"] {
            if let UsrName = user["login"] {
                name = UsrName as! String
            }
        }
        cell.detailTextLabel?.text = "#\(prObj["number"]!) opened on \(myDate) by \(name)"
        
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("pressed")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 25))
        sectionView.backgroundColor = UIColor.darkGray
        let sectionLabel = UILabel(frame: CGRect(x: 5, y: 2, width: sectionView.bounds.size.width, height: 20))
        sectionLabel.textColor = UIColor.white
        sectionLabel.text = "/magicalpanda/MagicalRecord/"
        sectionLabel.adjustsFontSizeToFitWidth = true
        sectionView.addSubview(sectionLabel)
        
        return sectionView
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Date Formatter
    func dateFormatter(strDate : String)-> String {
        var dateStr = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let dateObj = formatter.date(from: strDate)
        let dateYear = Calendar.current.component(.year, from: dateObj!)
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        if dateYear == currentYear {
            formatter.dateFormat = "MMM dd"
        } else {
            formatter.dateFormat = "MMM dd, yyyy"
        }
        dateStr = formatter.string(from: dateObj!)
        return dateStr
    }

}
