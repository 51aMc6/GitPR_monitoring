//
//  NetworkServices.swift
//  GitPullRequestApp
//
//  Created by Siamac 6 on 7/19/17.
//  Copyright © 2017 Siamac6. All rights reserved.
//

import UIKit

class NetworkServices: NSObject {

    static func fetchGithubRepos(with uri: String?, callback:@escaping (([[String:AnyObject]])->())) {
        var urlStr = "https://api.github.com/repos/magicalpanda/MagicalRecord/pulls"
        if let theUri = uri {
            urlStr += theUri
        }
        let url = URL(string: urlStr)
        let req : URLRequest = URLRequest(url: url! as URL)
        let dataTask = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
//                    var errorDict = [String:AnyObject]()
//                    errorDict["statusCode"] = httpResponse.statusCode as AnyObject?
//                    errorDict["status"] = httpResponse.allHeaderFields["Status"] as AnyObject?
//                    callback([errorDict])
                    return
                }
                do {
                    let theJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:AnyObject]]
                    if theJson != nil {
                        DispatchQueue.main.async {
                            callback(theJson!)
                        }
                    }
                } catch {
                    print ("ErrorJson: \(error)")
                }
            }
        }
        dataTask.resume()
    }

}
