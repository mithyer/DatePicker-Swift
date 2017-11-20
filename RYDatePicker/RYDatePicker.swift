//
//  RYDatePicker.swift
//  RYDatePicker-Swift-Demo
//
//  Created by ray on 2017/11/16.
//  Copyright © 2017年 ray. All rights reserved.
//

import Foundation
import UIKit

open class RYDatePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    public enum ComponentsStyle {
        case yearMonthDayHourMinute, yearMonthDay, dayHourMinute, monthDay, hourMinute
        
        fileprivate enum Option: Int {
            case year = 0, month, day, hour, minute
            var localizedString: String {
                switch self {
                case .year:return NSLocalizedString("RYDatePicker.year", comment: "year")
                case .month:return NSLocalizedString("RYDatePicker.month", comment: "month")
                case .day:return NSLocalizedString("RYDatePicker.day", comment: "day")
                case .hour:return NSLocalizedString("RYDatePicker.hour", comment: "hour")
                case .minute:return NSLocalizedString("RYDatePicker.minute", comment: "minute")
                }
            }
        }
        fileprivate var options: [Option] {
            switch self {
            case .yearMonthDayHourMinute:return [.year, .month, .day, .hour, .minute]
            case .yearMonthDay:return [.year, .month, .day]
            case .dayHourMinute:return [.day, .hour, .minute]
            case .monthDay:return [.month, .day]
            case .hourMinute:return [.hour, .minute]
            }
        }
    }
    
    static private let ConfirmBtnHeight: CGFloat = 50
    static open let DateFormat = "yyyy-MM-dd HH:mm"
    static open let DefaultMinSelectDate = Date.date(dateStr: "1900-01-01 00:00", format: RYDatePicker.DateFormat)!
    static open let DefaultMaxSelectDate = Date.date(dateStr: "2099-12-31 23:59", format: RYDatePicker.DateFormat)!
   

    private var _didConfirmHandler: ((Date) -> ())?
    private var _needReload: Bool = false

    convenience init(didConfirmHandler: ((Date) -> ())?, style: ComponentsStyle = .yearMonthDayHourMinute) {
        let windowBounds = UIApplication.shared.keyWindow?.bounds
        let pickerHeight = (windowBounds?.height)! * 0.4
        self.init(frame: CGRect.init(x: 0, y: (windowBounds?.height)! - pickerHeight - RYDatePicker.ConfirmBtnHeight, width: (windowBounds?.width)!, height: pickerHeight))
        self.backgroundColor = .white
        _didConfirmHandler = didConfirmHandler
        self.delegate = self
        self.dataSource = self
        self.setNeedReload()
    }
    
    open func show() {
        let window = UIApplication.shared.keyWindow
        if self.superview?.superview == window {
            return
        }
        let container = UIView()
        container.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.2)
        container.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(RYDatePicker.dismiss)))
        container.frame = window!.bounds
        container.addSubview(self)
        
        let confirmBtn = UIButton.init(type: .custom)
        confirmBtn.setTitle(NSLocalizedString("RYDatePicker.confirm", comment: "confirm"), for: .normal)
        confirmBtn.setTitleColor(.black, for: .normal)
        confirmBtn.layer.borderWidth = 0.5
        confirmBtn.layer.borderColor = UIColor.lightGray.cgColor
        confirmBtn.backgroundColor = .white
        confirmBtn.addTarget(self, action: #selector(RYDatePicker.didConfirm), for: .touchUpInside)
        confirmBtn.frame = CGRect.init(x: 0, y: self.frame.maxY, width: self.frame.width, height: RYDatePicker.ConfirmBtnHeight)
        container.addSubview(confirmBtn)
        
        window?.addSubview(container)
    }
    
    @objc private func dismiss() {
        self.superview?.removeFromSuperview()
    }
    
    private var _style: ComponentsStyle = .yearMonthDayHourMinute
    public var style: ComponentsStyle {
        get {
            return _style
        }
        set(newStyle) {
            if _style != newStyle {
                _style = newStyle
                self.setNeedReload()
            }
        }
    }
    
    private var _minLimitDate: Date = RYDatePicker.DefaultMinSelectDate
    public var minLimitDate: Date {
        get {
            return _minLimitDate
        }
        set(newDate) {
            if newDate != minLimitDate {
                _minLimitDate = newDate
            }
        }
    }
    
    private var _maxLimitDate: Date = RYDatePicker.DefaultMaxSelectDate
    public var maxLimitDate: Date {
        get {
            return _maxLimitDate
        }
        set(newDate) {
            if newDate != _maxLimitDate {
                _maxLimitDate = newDate
            }
        }
    }
    
    private var _selectDate: Date = Date()
    public var selectDate: Date {
        get {
            if _selectDate < self.minLimitDate {
                _selectDate = self.minLimitDate
            } else if _selectDate > self.maxLimitDate {
                _selectDate = self.maxLimitDate
            }
            return _selectDate
        }
        set(newDate) {
            if _selectDate != newDate {
                _selectDate = newDate
                self.setNeedReload()
            }
        }
    }
    
    @objc private func didConfirm(sender: UIButton!) {
        _didConfirmHandler?(_selectDate)
        self.dismiss()
    }
    
    private func setNeedReload() {
        if _needReload {
            return
        }
        _needReload = true
        self.reload()
    }
    
    private lazy var _optionToUnitDic: [ComponentsStyle.Option: [Int]] = [:]
    
    private func reload() {
        DispatchQueue.main.async {[weak self] in
            guard let sSelf = self else {return}
            guard sSelf._needReload else {return}
            
            sSelf._needReload = false
            let date = sSelf.selectDate
            
            var yearArray: [Int] = []
            var monthArray: [Int] = []
            var dayArray: [Int] = []
            var hourArray: [Int] = []
            var minuteArray : [Int] = []
            
            let minLimitDate = sSelf.minLimitDate
            let maxLimitDate = sSelf.maxLimitDate
            let minYear = minLimitDate.year
            let maxYear = maxLimitDate.year
            for i in minYear...maxYear {
                yearArray.append(i)
            }
            
            var minMonth = 1
            var minDay = 1
            var minHour = 0
            var minMinute = 0
            
            repeat {
                guard date.year == minYear else {break}
                minMonth = minLimitDate.month
                guard date.month == minMonth else {break}
                minDay = minLimitDate.day
                guard date.day == minDay else {break}
                minHour = minLimitDate.hour
                guard date.hour == minHour else {break}
                minMinute = minLimitDate.minute
            } while(false)
            
            var maxMonth = 12
            let calendar = Calendar.current
            let days = calendar.range(of: .day, in: .month, for: date)!
            var maxDay = days.count
            var maxHour = 23
            var maxMinute = 59
            
            repeat {
                guard date.year == maxYear else {break}
                maxMonth = maxLimitDate.month
                guard date.month == maxMonth else {break}
                maxDay = maxLimitDate.day
                guard date.day == maxDay else {break}
                maxHour = maxLimitDate.hour
                guard date.hour == maxHour else {break}
                maxMinute = maxLimitDate.minute
            } while(false)
            
            for i in minMonth...maxMonth {
                monthArray.append(i)
            }
            for i in minDay...maxDay {
                dayArray.append(i)
            }
            for i in minHour...maxHour {
                hourArray.append(i)
            }
            for i in minMinute...maxMinute {
                minuteArray.append(i)
            }
            sSelf._optionToUnitDic[.year] = yearArray
            sSelf._optionToUnitDic[.month] = monthArray
            sSelf._optionToUnitDic[.day] = dayArray
            sSelf._optionToUnitDic[.hour] = hourArray
            sSelf._optionToUnitDic[.minute] = minuteArray
            
            sSelf.reloadAllComponents()
            
            for (compoent, option) in sSelf.style.options.enumerated() {
                var row: Int? = nil
                switch option {
                case .year:
                    row = yearArray.index(of: date.year)
                case .month:
                    row = monthArray.index(of: date.month)
                case .day:
                    row = dayArray.index(of: date.day)
                case .hour:
                    row = hourArray.index(of: date.hour)
                case .minute:
                    row = minuteArray.index(of: date.minute)
                }
                sSelf.selectRow(row!, inComponent: compoent, animated: false)
            }
            
        }
    }
    
    // MARK:UIPickerViewDataSource

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.style.options.count;
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (_optionToUnitDic[self.style.options[component]]?.count) ?? 0
    }
    
    // MARK:UIPickerViewDelegate
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .center
        
        let option = self.style.options[component]
        label.text = "\(_optionToUnitDic[option]![row])" + option.localizedString
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectDate = self.selectDate
        var year = selectDate.year
        var month = selectDate.month
        var day = selectDate.day
        var hour = selectDate.hour
        var minute = selectDate.minute
        let option = self.style.options[component]
        let t = _optionToUnitDic[option]![row]
        switch option {
        case .year:
            year = t
        case .month:
            month = t
        case .day:
            day = t
        case .hour:
            hour = t
        case .minute:
            minute = t
        }
        let date = Date.date(dateStr: "\(year)-\(month)-01 00:00", format: RYDatePicker.DateFormat)
        let days = Calendar.current.range(of: .day, in: .month, for: date!)
        self.selectDate = Date.date(dateStr: "\(year)-\(month)-\(min(day, days!.count)) \(hour):\(minute)", format: RYDatePicker.DateFormat)!
    }

}



