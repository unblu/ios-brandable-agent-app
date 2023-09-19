//
//  VisitorClientDelegate.swift
//

import Foundation
import UnbluCoreSDK


///delegate for Unblu agent client to react to events. E.g. logout when the SDK reports that the user wants to hide the Unblu UI
class AgentClientDelegate: UnbluAgentClientDelegate {
    
    let unbluAgent: UnbluAgent
    
    init(_ unbluAgent: UnbluAgent) {
        self.unbluAgent = unbluAgent
    }
    
    func unblu(didUpdatePersonActivityInfo personActivity: PersonActivityInfo) {
    }
    
    func unbluDidInitialize() {
    }
    
    func unbluDidDeinitialize() {
    }
    
    func unblu(didUpdateAgentAvailability isAvailable: Bool) {
    }
    
    func unblu(didUpdatePersonInfo personInfo: PersonInfo) {
    }
    
    func unblu(didUpdateUnreadMessages count: Int) {
    }
    
    func unblu(didChangeOpenConversation openConversation: UnbluConversation?) {
        unbluAgent.unbluUiState.isOverview  = openConversation == nil  ?  true : false
    }
    
    func unblu(didRequestHideUi reason: UnbluUiHideRequestReason, conversationId: String?) {
        AppDelegate.logout()
    }
    
    func unblu(didToggleCallUi isOpen: Bool) {
    }

    func unblu(didRequestShowUi withReason: UnbluUiRequestReason, requestedByUser: Bool) {
    }
    
    func unblu(didReceiveError type: UnbluClientErrorType, description: String) {
        if [UnbluClientErrorType.internalError,
            UnbluClientErrorType.authorization,
            UnbluClientErrorType.invalidUrl].contains(type) {
            ///it is assumed that there may be errors  (description) : "Forbidden" "Blocked" "SwError"
            AppDelegate.setOAuthState(false)
            AppDelegate.logout()
        }
    }
}
