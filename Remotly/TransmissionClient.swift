//
//  TransmissionClient.swift
//  Remotly
//
//  Created by Marcin Czachurski on 30.07.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import Foundation
import SwiftyJSON

class TransmissionClient
{
    static var sessionIds:Dictionary<String, String> = Dictionary<String,String>()
    var transmissionUrl:String = ""
    var userName:String = ""
    var password:String = ""
    
    init(address:String, userName:String, password:String)
    {
        prepareTransmissionUrl(address)
        self.userName = userName
        self.password = password
    }
    
    private func prepareTransmissionUrl(address:String)
    {
        if(address.rangeOfString("http://", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == nil)
        {
            transmissionUrl = "http://" + address
        }
        
        transmissionUrl = transmissionUrl + "/transmission/rpc"
    }
    
    // MARK: Add torrent
    
    func addTorrent(fileUrl:NSURL, isExternal:Bool, onCompletion:((NSError!) -> Void)?)
    {
        let requestJson = addTorrentPrepareJson(fileUrl, isExternal: isExternal)
        addTorrentSendRequest(requestJson, onCompletion: onCompletion)
    }
    
    private func addTorrentPrepareJson(fileUrl:NSURL, isExternal:Bool) -> String
    {
        var requestJson = ""
        if(isExternal == true)
        {
            requestJson += "{ \"arguments\": {\"filename\": \""
            requestJson += fileUrl.absoluteString!
            requestJson += "\" }, \"method\": \"torrent-add\"}"
        }
        else
        {
            let dataContent = NSData(contentsOfURL: fileUrl)
            let base64Content = dataContent?.base64EncodedStringWithOptions(nil)
            
            requestJson += "{ \"arguments\": {\"metainfo\": \""
            requestJson += base64Content!
            requestJson += "\" }, \"method\": \"torrent-add\" }"
        }
        
        return requestJson
    }
    
    private func addTorrentSendRequest(requestJson:String, onCompletion:((NSError!) -> Void)?)
    {
        sendRequest(requestJson, completionHandler: { data, response, error -> Void in
            var internalError = error
            if(internalError == nil)
            {
                let json:JSON = JSON(data: data)
                var result = json["result"].stringValue
                
                if(result != "success")
                {
                    internalError = TransmissionErrorsHandler.createError(NSTransmissionAddErrorDomain, message: result)
                }
            }
            
            onCompletion?(internalError)
        })
    }
    
    // MARK: Remove torrent
    
    func removeTorrent(torrentId:Int64, onCompletion:((NSError!) -> Void)?)
    {
        var requestJson = removeTorrentPrepareJson(torrentId)
        removeTorrentSendRequest(requestJson, onCompletion: onCompletion)
    }
    
    private func removeTorrentPrepareJson(torrentId:Int64) -> String
    {
        var requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-remove\" }"
        return requestJson
    }
    
    private func removeTorrentSendRequest(requestJson:String, onCompletion:((NSError!) -> Void)?)
    {
        sendRequest(requestJson, completionHandler: { (data, response, error) -> Void in
            var internalError = error
            if(internalError == nil)
            {
                let json:JSON = JSON(data: data)
                var result = json["result"].stringValue
                
                if(result != "success")
                {
                    internalError = TransmissionErrorsHandler.createError(NSTransmissionRemoveErrorDomain, message: result)
                }
            }
            
            onCompletion?(internalError)
        })
    }
    
    // MARK: Reasume torrent
    
    func reasumeTorrent(torrentId:Int64, onCompletion:((NSError!) -> Void)?)
    {
        var requestJson = reasumeTorrentPrepareJson(torrentId)
        reasumeTorrentSendRequest(requestJson, onCompletion: onCompletion)
    }
    
    private func reasumeTorrentPrepareJson(torrentId:Int64) -> String
    {
        var requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-start\" }"
        return requestJson
    }
    
    private func reasumeTorrentSendRequest(requestJson:String, onCompletion:((NSError!) -> Void)?)
    {
        sendRequest(requestJson, completionHandler: { data, response, error -> Void in
            var internalError = error
            if(internalError == nil)
            {
                let json:JSON = JSON(data: data)
                var result = json["result"].stringValue
                
                if(result != "success")
                {
                    internalError = TransmissionErrorsHandler.createError(NSTransmissionReasumeErrorDomain, message: result)
                }
            }
            
            onCompletion?(internalError)
        })
    }
    
    // MARK: Pause torrent
    
    func pauseTorrent(torrentId:Int64, onCompletion:((NSError!) -> Void)?)
    {
        var requestJson = pauseTorrentPrepareJson(torrentId)
        pauseTorrentSendRequest(requestJson, onCompletion: onCompletion)
    }
    
    private func pauseTorrentPrepareJson(torrentId:Int64) -> String
    {
        var requestJson = "{ \"arguments\": {\"ids\": [ \(torrentId) ]}, \"method\": \"torrent-stop\" }"
        return requestJson
    }
    
    private func pauseTorrentSendRequest(requestJson:String, onCompletion:((NSError!) -> Void)?)
    {
        sendRequest(requestJson, completionHandler: { data, response, error -> Void in
            var internalError = error
            if(internalError == nil)
            {
                let json:JSON = JSON(data: data)
                var result = json["result"].stringValue
                
                if(result != "success")
                {
                    internalError = TransmissionErrorsHandler.createError(NSTransmissionPauseErrorDomain, message: result)
                }
            }
            
            onCompletion?(internalError)
        })
    }
    
    // MARK: Get torrents
    
    func getTorrents(onCompletion: (([TorrentInformation]!, NSError!) -> Void)?)
    {
        var requestJson = getTorrentsPrepareJson()
        getTorrentsSendRequest(requestJson, onCompletion: onCompletion)
    }
    
    private func getTorrentsPrepareJson() -> String
    {
        var requestJson = "{ \"arguments\": {\"fields\": [ \"status\",\"id\", \"name\", \"totalSize\", \"files\", \"priorities\", \"percentDone\", \"leftUntilDone\", \"sizeWhenDone\", \"peersConnected\", \"peersSendingToUs\", \"rateDownload\", \"rateUpload\", \"isFinished\", \"peersGettingFromUs\", \"hashString\", \"addedDate\" ]}, \"method\": \"torrent-get\" }"
        return requestJson
    }
    
    private func getTorrentsSendRequest(requestJson:String, onCompletion:(([TorrentInformation]!, NSError!) -> Void)?)
    {
        sendRequest(requestJson, completionHandler: { data, response, error -> Void in
            
            var torrentInformations = [TorrentInformation]()
            var internalError = error
            if(internalError == nil)
            {
                let json:JSON = JSON(data: data)
                var result = json["result"].stringValue
                
                if(result != "success")
                {
                    internalError = TransmissionErrorsHandler.createError(NSTransmissionGetErrorDomain, message: result)
                }
                else
                {
                    var torrents = json["arguments"]["torrents"]
                    
                    for (key: String, subJson: JSON) in torrents
                    {
                        var torrentInformation = TorrentInformation()
                        torrentInformation.id = subJson["id"].int64Value
                        torrentInformation.status = subJson["status"].int32Value
                        torrentInformation.name = subJson["name"].stringValue
                        torrentInformation.totalSize = subJson["totalSize"].int64Value
                        torrentInformation.percentDone = subJson["percentDone"].doubleValue
                        torrentInformation.leftUntilDone = subJson["leftUntilDone"].int64Value
                        torrentInformation.sizeWhenDone = subJson["sizeWhenDone"].int64Value
                        torrentInformation.peersConnected = subJson["peersConnected"].int32Value
                        torrentInformation.peersSendingToUs = subJson["peersSendingToUs"].int32Value
                        torrentInformation.rateDownload = subJson["rateDownload"].int64Value
                        torrentInformation.rateUpload = subJson["rateUpload"].int64Value
                        torrentInformation.isFinished = subJson["isFinished"].boolValue
                        torrentInformation.peersGettingFromUs = subJson["peersGettingFromUs"].int32Value
                        torrentInformation.hashString = subJson["hashString"].stringValue
                        torrentInformation.addedDate = subJson["addedDate"].doubleValue
                        
                        torrentInformations.append(torrentInformation)
                    }
                }
            }
            
            onCompletion?(torrentInformations, internalError)
        })
    }
    
    // MARK: Sending request
    
    private func sendRequest(requestJson: String, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?)
    {
        let request = sendRequestPrepareRequest(requestJson)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if(error != nil)
            {
                completionHandler?(data, response, error)
            }
            else
            {
                if(self.checkIfErrorIsMissingSessionId(response))
                {
                    // If error was missing session Id we have to do request again (now we should have proper session Id).
                    let sessionId = self.getSessionIdForServer()
                    request.setValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
                    
                    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                        completionHandler?(data, response, error)
                    })
                    
                    task.resume();
                }
                else
                {
                    completionHandler?(data, response, error)
                }
            }
        })
        
        task.resume();
    }
    
    private func sendRequestPrepareRequest(requestJson: String) -> NSMutableURLRequest
    {
        let request = NSMutableURLRequest(URL: NSURL(string: transmissionUrl)!)
        request.HTTPMethod = "POST"
        
        let sessionId = getSessionIdForServer()
        request.addValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        if(!userName.isEmpty && !password.isEmpty)
        {            
            let credentials = "\(userName):\(password)"
            let credentialsData = credentials.dataUsingEncoding(NSUTF8StringEncoding)
            let authorization = credentialsData?.base64EncodedStringWithOptions(nil)
            
            request.setValue("Basic \(authorization!)", forHTTPHeaderField: "Authorization")
        }

        request.HTTPBody = requestJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        return request
    }
    
    // MARK: Manage sessions
    
    private func getSessionIdForServer() -> String?
    {
        return TransmissionClient.sessionIds[transmissionUrl];
    }
    
    private func setSessionIdForServer(sessionId:String)
    {
        TransmissionClient.sessionIds[transmissionUrl] = sessionId
    }
    
    private func checkIfErrorIsMissingSessionId(response:NSURLResponse) -> Bool
    {
        var httpResponse = response as! NSHTTPURLResponse
        if(httpResponse.statusCode == 409)
        {
            let sessionId = httpResponse.allHeaderFields["X-Transmission-Session-Id"] as! String
            self.setSessionIdForServer(sessionId)
            return true
        }
        
        return false
    }
}