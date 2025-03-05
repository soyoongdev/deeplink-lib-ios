//
//  DLDynamicLinksCommon.swift
//  SampleDynamicLink
//
//  Created by NGUYEN HAU on 14/2/25.
//

import Foundation
import UIKit

public typealias DLDynamicLinkResolverHandler = (URL?, Error?) -> Void

public typealias DLDynamicLinkUniversalLinkHandler = (DLDynamicLink?, Error?) -> Void

public typealias DLDynamicLinkResultHandler = (Data?, Error?) -> Void
