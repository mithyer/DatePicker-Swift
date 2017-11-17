//
//  NSDate+RYExtension.swift
//  RYDatePicker-Swift-Demo
//
//  Created by ray on 2017/11/16.
//  Copyright © 2017年 ray. All rights reserved.
//

import Foundation

extension Date {
    
    static public var currentCalendar: Calendar = Calendar.autoupdatingCurrent;
    
    static public func date(dateStr: String!, format: String!) -> Date? {
        let dateFormatter: DateFormatter = DateFormatter();
        dateFormatter.locale = Locale.current;
        dateFormatter.timeZone = TimeZone.current;
        dateFormatter.dateFormat = format;
        let date = dateFormatter.date(from: dateStr);
        return date;
    }
    
    public var year: Int {
        return Date.currentCalendar.component(.year, from: self);
    }

    public var month: Int {
        return Date.currentCalendar.component(.month, from: self);
    }
    public var day: Int {
        return Date.currentCalendar.component(.day, from: self);
    }
    
    public var hour: Int {
        return Date.currentCalendar.component(.hour, from: self);
    }
    
    public var minute: Int {
        return Date.currentCalendar.component(.minute, from: self);
    }
}
