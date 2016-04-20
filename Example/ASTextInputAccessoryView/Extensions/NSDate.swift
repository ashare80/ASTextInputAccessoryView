//
//  NSDate.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

extension NSDate {
    
    var headerFormattedString: String {
        let dateFormatter = NSDateFormatter()
        let template = "MMM dd, hh:mm"
        let locale = NSLocale.currentLocale()
        let format = NSDateFormatter.dateFormatFromTemplate(template, options:0, locale:locale)
        
        dateFormatter.setLocalizedDateFormatFromTemplate(format!)
        
        var dateTimeString = dateFormatter.stringFromDate(self)
        
        if NSCalendar.currentCalendar().isDateInToday(self) {
            dateTimeString = "Today, " + dateTimeString
        }
        else {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
            let weekDay = dateFormatter.stringFromDate(self)
            dateTimeString = weekDay + ", " + dateTimeString
        }
        
        return dateTimeString
    }
}