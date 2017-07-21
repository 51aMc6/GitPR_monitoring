//
//  DiffPReqCollectionViewController.swift
//  GitPullRequestApp
//
//  Created by Siamac 6 on 7/19/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"
extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}

class DiffPReqCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var diffData = [[String:AnyObject]]()
    var rowData = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uriStr = "/\(pullReqNum)!/files?diff=split"
        NetworkServices.fetchGithubRepos(with: uriStr, callback: { payload in
            self.diffData = payload
            self.collectionView?.reloadData()
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.diffData.count
//        return rowData.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
//        return rowData[section].keys.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        cell.backgroundColor = UIColor.white
        cell.lbl.sizeToFit()

        var patch = self.diffData[indexPath.section]["patch"] as! String
        
        if indexPath.row == 0 {
            cell.lbl.textColor = UIColor.red
            if let str = patch.slice(from: "\n+", to: "\n") {
                let range = patch.range(of: str)
                patch.removeSubrange(range!)
                let signPos = patch.distance(from: patch.characters.startIndex, to: (range?.lowerBound)!) as Int
                let prevIndx = signPos - 1
                print(signPos)
                let lowerBnd = patch.index(patch.startIndex, offsetBy: prevIndx)
                let upperBnd = patch.index(patch.startIndex, offsetBy: signPos)
                patch.removeSubrange(lowerBnd..<upperBnd)
            }
            cell.lbl.text = patch
        } else if indexPath.row == 1 {
            cell.lbl.textColor = UIColor.green
            if let str = patch.slice(from: "\n-", to: "\n") {
                let range = patch.range(of: str)
                patch.removeSubrange(range!)
                let signPos = patch.distance(from: patch.characters.startIndex, to: (range?.lowerBound)!) as Int
                let prevIndx = signPos - 1
                print(signPos)
                let lowerBnd = patch.index(patch.startIndex, offsetBy: prevIndx)
                let upperBnd = patch.index(patch.startIndex, offsetBy: signPos)
                patch.removeSubrange(lowerBnd..<upperBnd)

            }
            cell.lbl.text = patch
        }

        return cell
    }

    // MARK: UICollectionViewDelegate
//    func collectionView(_ collectionView: UICollectionView,
//                                 layout collectionViewLayout: UICollectionViewLayout,
//                                 referenceSizeForHeaderInSection section: Int) -> CGSize
//    {
//        let size = CGSize(width: screenWidth, height: 20)
//        return size
//    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect: CGRect = UIScreen.main.bounds
        let screenWidth : CGFloat = screenRect.size.width
        let cellWidth : CGFloat = screenWidth / 2
        let size = CGSize(width: cellWidth, height: screenWidth/1.5)
        return size
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowlayout.invalidateLayout()
    }
    
    
}

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbl : UILabel!
    
}
