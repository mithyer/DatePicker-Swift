//
//  RYDatePicker.swift
//  RYDatePicker-Swift-Demo
//
//  Created by ray on 2017/11/16.
//  Copyright © 2017年 ray. All rights reserved.
//

import Foundation
import UIKit

public class RYDatePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    static private let ConfirmBtnHeight: CGFloat = 50
    static public let DateFormat = "yyyy-MM-dd HH:mm"
    static public let DefaultMinSelectDate = Date.date(dateStr: "1900-01-01 00:00", format: RYDatePicker.DateFormat)!
    static public let DefaultMaxSelectDate = Date.date(dateStr: "2099-12-31 23:59", format: RYDatePicker.DateFormat)!
    private struct UsedWord {
        static let confirm = "确定", year = "年", month = "月", day = "日", hour = "时", minute = "分"
    }
    
    private var _didConfirmHandler: ((Date) -> ())?
    private var _needReload: Bool = false

    public enum ComponentsStyle {
        case yearMonthDayHourMinute, yearMonthDay, dayHourMinute, monthDay, hourMinute
    }
    
    private enum ComponentsOption: Int {
        case year = 0, month, day, hour, minute
    }
    
    static private let ComponentsStyleOptions: [ComponentsStyle: [ComponentsOption]] = [.yearMonthDayHourMinute: [.year, .month, .day, .hour, .minute],
                                                                                        .yearMonthDay: [.year, .month, .day],
                                                                                        .dayHourMinute: [.day, .hour, .minute],
                                                                                        .monthDay: [.month, .day],
                                                                                        .hourMinute: [.hour, .minute]]
    private var optionsOfCurStyle: [ComponentsOption] {
        return RYDatePicker.ComponentsStyleOptions[_style]!;
    }
    
    public convenience init(didConfirmHandler: ((Date) -> ())?, style: ComponentsStyle = .yearMonthDayHourMinute) {
        let windowBounds = UIApplication.shared.keyWindow?.bounds
        let pickerHeight = (windowBounds?.height)! * 0.4
        self.init(frame: CGRect.init(x: 0, y: (windowBounds?.height)! - pickerHeight - RYDatePicker.ConfirmBtnHeight, width: (windowBounds?.width)!, height: pickerHeight))
        self.backgroundColor = .white
        _didConfirmHandler = didConfirmHandler
        self.delegate = self
        self.dataSource = self
        self.setNeedReload()
    }
    
    public func show() {
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
        confirmBtn.setTitle(RYDatePicker.UsedWord.confirm, for: .normal)
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
    
    private lazy var _optionToUnitDic: [ComponentsOption: [Int]] = [:]
    
    private func reload() {
        DispatchQueue.main.async {[weak self] in
            if nil == self {
                return
            }
            let sSelf = self!
            if !sSelf._needReload {
                return
            }
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
            if date.year == minYear {
                minMonth = minLimitDate.month
                if date.month == minMonth {
                    minDay = minLimitDate.day
                    if date.day == minDay {
                        minHour = minLimitDate.hour
                        if date.hour == minHour {
                            minMinute = minLimitDate.minute
                        }
                    }
                }
            }
            
            var maxMonth = 12
            let calendar = Calendar.current
            let days = calendar.range(of: .day, in: .month, for: date)!
            var maxDay = days.count
            var maxHour = 23
            var maxMinute = 59
            if date.year == maxYear {
                maxMonth = maxLimitDate.month
                if date.month == maxMonth {
                    maxDay = maxLimitDate.day
                    if date.day == maxDay {
                        maxHour = maxLimitDate.hour
                        if date.hour == maxHour {
                            maxMinute = maxLimitDate.minute
                        }
                    }
                }
            }
            
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
            
            for (compoent, option) in sSelf.optionsOfCurStyle.enumerated() {
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
        return self.optionsOfCurStyle.count;
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (_optionToUnitDic[self.optionsOfCurStyle[component]]?.count) ?? 0
    }
    
    // MARK:UIPickerViewDelegate
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    static private let OptionToSuffix: [ComponentsOption: String] = [.year: RYDatePicker.UsedWord.year, .month: RYDatePicker.UsedWord.month, .day:RYDatePicker.UsedWord.day, .hour:RYDatePicker.UsedWord.hour, .minute:RYDatePicker.UsedWord.minute]
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .center
        
        let option = self.optionsOfCurStyle[component]
        label.text = "\(_optionToUnitDic[option]![row])" + RYDatePicker.OptionToSuffix[option]!
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectDate = self.selectDate
        var year = selectDate.year
        var month = selectDate.month
        var day = selectDate.day
        var hour = selectDate.hour
        var minute = selectDate.minute
        let option = self.optionsOfCurStyle[component]
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



