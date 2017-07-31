//
//  DiffPReqCollectionViewController.swift
//  GitPullRequestApp
//
//  Created by Siamac 6 on 7/19/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"
var diffData = [[String:AnyObject]]()

class DiffPReqCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    enum status {
        case added, removed, modified, renamed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.navigationItem.title = "diff #\(pullReqNum)"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reloadDataButtonAction(_ sender: Any) {
        print(" pressed")
        let uriStr = "/\(pullReqNum)!/files?diff=split"
        NetworkServices.fetchGithubRepos(with: uriStr, callback: { payload in
            diffData = payload
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        })

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func matchStringWithRegex(text: String, withpattern pttrn: String) -> String {
        var newString = text
        do {
            let regex = try NSRegularExpression(pattern: pttrn, options: [])
            let nsString = text as NSString
            let result = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            let matched = result.map {
                nsString.substring(with: $0.range)
            }
            for item in matched {
                newString = newString.replacingOccurrences(of: item, with: "\n")
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return newString
    }
    
    func matchStringForDiff(with data: [String:AnyObject], for indexPathRow: Int)-> String {
        var newString = ""
        let itemStatus = setItemStatus(with: data["status"] as! String)
        
        if (itemStatus == .removed && indexPathRow == 0) || (itemStatus == .added && indexPathRow == 1) {
            newString = data["patch"] as! String
            return newString
        } else if itemStatus == .modified || itemStatus == .renamed {
            let patch = data["patch"] as! String
            switch indexPathRow {
            case 0:
                // cut out added new line
                newString = self.matchStringWithRegex(text: patch, withpattern: "\n\\+.*")
                break
            case 1:
                // trim string on old line
                newString = self.matchStringWithRegex(text: patch, withpattern: "\n\\-.*")
                break
            default:
                newString = ""
            }
        }
        
        return newString
    }
    
    func setItemStatus(with statusString: String)-> status {
        var itemStatus = status.renamed
        switch statusString {
        case "modified":
            itemStatus = status.modified
            break
        case "removed":
            itemStatus = status.removed
            break
        case "added":
            itemStatus = status.added
        default:
            itemStatus = status.renamed
            break
        }
        return itemStatus
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return diffData.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        cell.lbl.text = ""
        var diffString = ""
        DispatchQueue.global().async{
            diffString =  self.matchStringForDiff(with: diffData[indexPath.section], for: indexPath.row)
            DispatchQueue.main.async {
                cell.lbl.text = diffString
            }
        }
        cell.backgroundColor = UIColor.white
        cell.lbl.sizeToFit()
        switch indexPath.row {
        case 0:
            cell.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 204/255, alpha: 0.25)
            break
        case 1:
            cell.backgroundColor = UIColor(red: 204/255, green: 255/255, blue: 153/255, alpha: 0.26)
        default:
            cell.backgroundColor = UIColor.white
        }

        return cell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowlayout.invalidateLayout()
    }

     // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect: CGRect = UIScreen.main.bounds
        let screenWidth : CGFloat = screenRect.size.width
        let cellWidth : CGFloat = (screenWidth / 2) - 0.5
        var cellHeight : CGFloat = 2000.0
//        let padding : CGFloat = 3.0
        let size = CGSize(width: cellWidth, height: cellHeight)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)]
//        let text = diffData[indexPath.section]["patch"] as! String
        let text = self.matchStringForDiff(with: diffData[indexPath.section], for: indexPath.row)
        let newSize = NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        cellHeight = newSize.height //+ padding

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
//        func collectionView(_ collectionView: UICollectionView,
//                                     layout collectionViewLayout: UICollectionViewLayout,
//                                     referenceSizeForHeaderInSection section: Int) -> CGSize
//        {
//            let size = CGSize(width: UIScreen.main.bounds.size.width, height: 20)
//            return size
//        }

    
}

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbl : UILabel!
    
}
