//
//  WatchConnectivityService.swift
//  ALP MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityService: NSObject, WCSessionDelegate {
    
    static let shared = WatchConnectivityService()
    
    private override init() {
        super.init()
    }
    
    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func sendTimeBlocks(_ blocks: [TimeBlockModel]) {
        guard WCSession.default.isReachable else { return }
        
        let payload = blocks.map { block in
            [
                "id": block.id.uuidString,
                "title": block.title,
                "startTime": block.startTime.timeIntervalSince1970,
                "endTime": block.endTime.timeIntervalSince1970,
                "interestId": block.interestId.uuidString
            ] as [String: Any]
        }
        
        WCSession.default.sendMessage(
            ["timeBlocks": payload],
            replyHandler: nil,
            errorHandler: nil
        )
    }
    
    //WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
