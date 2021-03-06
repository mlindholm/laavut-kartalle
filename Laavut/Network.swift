//
//  Network.swift
//  Laavut
//
//  Created by Mathias Lindholm on 21.7.2016.
//  Copyright © 2016 Mathias Lindholm. All rights reserved.
//

import Foundation
import SwiftyXMLParser

struct Network {

    static func load(completion: ([Location]) -> Void) -> NSURLSessionTask? {
        let urlString = NSURL(string: "https://laavu.org/lataa.php?paikkakunta=kaikki")
        let request = NSURLRequest(URL: urlString!)

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let error = error {
                    print(error.localizedDescription)
                    completion([])
                    return
                }

                guard let data = data where error == nil else {
                    completion([])
                    return
                }

                let optionalLaavu = parse(data)
                completion(optionalLaavu)
            })
        })
        
        task.resume()
        return task
    }

    static func parse(data: NSData) -> [Location] {
        var locationsArray = [Location]()
        let xmlObject = try! XML.parse(data)

        for item in xmlObject["gpx", "wpt"] {
            guard let location = Location(xml: item) else { continue }
            locationsArray.append(location)
        }

        return locationsArray
    }
}