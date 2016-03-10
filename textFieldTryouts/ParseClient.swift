//
//  ParseClient.swift
//  textFieldTryouts
//
//  Created by Ethan Haley on 3/7/16.
//  Copyright © 2016 Ethan Haley. All rights reserved.
//

import Foundation

class ParseClient {
    
    let appKey = "D0TRAES0OguZr5vr4DMYYhLKONjXzReebXvN9cWP"
    let clientKey = "S8pWuVoRbmIUHsPkaRLLSzyXt4qV5O28ehJz4Voe"
    let restApiKey = "fgBearnsCNxyQDMTubf7mRbbZeKMH72qIOlxXpzd"
    let baseUrl = "https://api.parse.com/1/classes/HighScore"
    
    static let sharedInstance = ParseClient()
    
    func getHighScores(completion: (result: [(String, Int, String)]?, error: String?) -> Void) {
        
        self.getFromParseTask("", parameters: ["order": "-score"]) { result, error in
                
            if let err = error {
                
                completion(result: nil, error: err.localizedDescription)
                
            } else {
                var resultList = [(String, Int, String)]()
                let results = result.valueForKey("results") as! [[String: AnyObject]]
                
                for highScore in results {
                    resultList.append((highScore["player"] as! String, highScore["score"] as! Int, highScore["objectId"] as! String))
                }
                completion(result: resultList, error: nil)
            }
        }
    }
    
    func saveScoreAndName(name: String, score: Int, completion: (error: String?) -> Void) {
        
        var params = [String: AnyObject]()
        params["player"] = name
        params["score"] = score
        
        postToParseTask("", parameters: params) { success, result, error in
            
            if success {
                completion(error: nil)
                
            } else {
                completion(error: error)
            }
        }
    }
    
    // add a new object to Parse
    func postToParseTask(method: String, parameters: [String: AnyObject], completionHandler: (success: Bool, result: AnyObject?, errorString: String?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseUrl + method)!)
        request.HTTPMethod = "POST"
        request.addValue(appKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        } catch _ as NSError {
            request.HTTPBody = nil
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                completionHandler(success: false, result: response, errorString: error!.localizedDescription)
                
            } else {
                // parse the results
                let results = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                // use presence of "createdAt" key as a test of success
                if let _ = results["createdAt"] as? String {
                    
                    completionHandler(success: true, result: results, errorString: nil)
                    
                } else {
                    completionHandler(success: false, result: nil, errorString: "Could not create the Object in Parse.")
                }
            }
        }
        task.resume()
        return task
    }
    
    // GET objects from Parse
    func getFromParseTask(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set the parameters
        let mutableParameters = parameters
        
        // Build the URL and configure the request
        let urlString = baseUrl + method + ParseClient.escapedParameters(mutableParameters)
    
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(appKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
        
                completionHandler(result: nil, error: error!)
                
            } else {
                let results = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
               
                completionHandler(result: results, error: nil)
            }
        }
        task.resume()
        
        return task
    }
    
    // DELETE an object from Parse
    func deleteFromParseTask(method: String, objectId: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the request
        let urlString = baseUrl + method + objectId
        let url = NSURL(string: urlString)!
       
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue(appKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                
                completionHandler(result: nil, error: error!)
                
            } else {
                let results = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                completionHandler(result: results, error: nil)
            }
        }
        task.resume()
        
        return task
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a URL.
    Copied and pasted from Jarrod Parkes' Movie Manager app on Udacity, since the Parse REST API docs examples are for Python
    */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}