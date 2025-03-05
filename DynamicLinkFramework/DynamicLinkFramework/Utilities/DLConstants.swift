//
//  TPConstants.swift
//  Runner
//
//  Created by soyoongdev on 4/2/25.
//

import Foundation


public let DL_PRE_LAST_DYNAMICLINK = "dl_pre_last_dynamiclink"

// We should only read the deeplink after install once. We use the following key to store the state
// in the user defaults.
public let kDLReadDeepLinkAfterLaunchApp = "DLReadDeepLinkAfterLaunchApp"
public let kDLAppWasTerminated = "DLAppWasTerminated"

// Custom domains to be allowed are optionally added as an array to the info.plist.
public let kInfoPlistCustomDomainsKey = "DLDynamicLinksCustomDomains"
