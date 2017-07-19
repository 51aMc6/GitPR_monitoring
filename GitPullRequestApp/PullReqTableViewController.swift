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
        fetchGithubRepos()
        self.tableView.reloadData()
    }
    
    @IBAction func refreashPRlist(_ sender: UIBarButtonItem) {
        fetchGithubRepos()
        self.tableView.reloadData()
    }
    
    func fetchGithubRepos() {
        let req : URLRequest = URLRequest(url: URL(string: "https://api.github.com/repos/magicalpanda/MagicalRecord/pulls")! as URL)
        let dataTask = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            if response != nil {
                print("Response: \(response)")
                do {
                    let theJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:AnyObject]]
                    print("Result: OK")
                    if theJson != nil {
                        self.pullReqData = theJson!
                        DispatchQueue.main.async {
                            print("res: \(self.pullReqData)")
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print ("ErrorJson: \(error)")
                }
                
            }
        }
        dataTask.resume()
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
