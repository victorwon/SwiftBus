//
//  TransitAgency.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

private let kAgencyTagEncoderString = "kAgencyTagEncoder"
private let kAgencyTitleEncoderString = "kAgencyTitleEncoder"
private let kAgencyShortTitleEncoderString = "kAgencyShortTitleEncoder"
private let kAgencyRegionEncoderString = "kAgencyRegionEncoder"
private let kAgencyRoutesEncoderString = "kAgencyRoutesEncoder"

class TransitAgency: NSObject, NSCoding {
    
    var agencyTag:String = ""
    var agencyTitle:String = ""
    var agencyShortTitle:String = ""
    var agencyRegion:String = ""
    var agencyRoutes:[String : TransitRoute] = [:]
    
    //Convenvience
    override init() { }
    
    init(agencyTag:String, agencyTitle:String, agencyRegion:String) {
        self.agencyTag = agencyTag
        self.agencyTitle = agencyTitle
        self.agencyRegion = agencyRegion
    }

    //MARK : NSCoding
    
    required init(coder aDecoder: NSCoder) {
        agencyTag = aDecoder.decodeObjectForKey(kAgencyTagEncoderString) as! String
        agencyTitle = aDecoder.decodeObjectForKey(kAgencyTitleEncoderString) as! String
        agencyShortTitle = aDecoder.decodeObjectForKey(kAgencyShortTitleEncoderString) as! String
        agencyRegion = aDecoder.decodeObjectForKey(kAgencyRegionEncoderString) as! String
        agencyRoutes = aDecoder.decodeObjectForKey(kAgencyRoutesEncoderString) as! [String : TransitRoute]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(agencyTag, forKey: kAgencyTagEncoderString)
        aCoder.encodeObject(agencyTitle, forKey: kAgencyTitleEncoderString)
        aCoder.encodeObject(agencyShortTitle, forKey: kAgencyShortTitleEncoderString)
        aCoder.encodeObject(agencyRegion, forKey: kAgencyRegionEncoderString)
        aCoder.encodeObject(agencyRoutes, forKey: kAgencyRoutesEncoderString)
    }
}