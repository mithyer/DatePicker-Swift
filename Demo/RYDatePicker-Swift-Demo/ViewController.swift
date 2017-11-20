//
//  ViewController.swift
//  RYDatePicker-Swift-Demo
//
//  Created by ray on 2017/11/16.
//  Copyright © 2017年 ray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var datePicker: RYDatePicker = {
        let picker = RYDatePicker.init(didConfirmHandler: { [weak self] date in
            self?.dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: .full)
        })
        return picker
    }()
    
    lazy var dateLabel: UILabel = {
        let dateLabel: UILabel = .init()
        dateLabel.font = .systemFont(ofSize: 10)
        return dateLabel
    }();
    
    lazy var switchStyleBtn: UIButton = {
        let btn: UIButton = .init(type: .roundedRect)
        btn.setTitle("切换样式：\(_style)", for: .normal)
        btn.backgroundColor = .lightGray
        btn.titleLabel?.textAlignment = .left
        btn.frame = .init(x: 0, y: 50, width: 0, height: 0)
        btn.sizeToFit()
        return btn
    }()
    
    lazy var minDateField: UITextField = {
        let field: UITextField = .init(frame: CGRect(x: 0, y: 90, width: 350, height: 20))
        field.font = .systemFont(ofSize: 15)
        field.placeholder = "设置最小选择时间 格式为：yyyy-MM-dd HH:mm"
        return field
    }()
    
    lazy var maxDateField: UITextField = {
        let field: UITextField = .init(frame: CGRect(x: 0, y: 130, width: 350, height: 20))
        field.font = .systemFont(ofSize: 15)
        field.placeholder = "设置最大选择时间 格式为：yyyy-MM-dd HH:mm"
        return field
    }()
    
    lazy var selectDateField: UITextField = {
        let field: UITextField = .init(frame: CGRect(x: 0, y: 170, width: 350, height: 20))
        field.font = .systemFont(ofSize: 15)
        field.placeholder = "设置当前选择时间 格式为：yyyy-MM-dd HH:mm"
        return field
    }()
    
    lazy var showBtn: UIButton = {
        let btn: UIButton = .init(type: .roundedRect)
        btn.setTitle("show", for: .normal)
        btn.backgroundColor = .lightGray
        btn.frame = .init(x: 0, y: 210, width: 0, height: 0)
        btn.sizeToFit()
        return btn
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.minDateField)
        self.view.addSubview(self.maxDateField)
        self.view.addSubview(self.selectDateField)
        self.view.addSubview(self.showBtn)
        self.showBtn.addTarget(self, action: #selector(ViewController.showBtnTapped), for: .touchUpInside)
        
        self.dateLabel.frame = self.view.bounds
        self.view.addSubview(self.dateLabel)
        
        self.view.addSubview(self.switchStyleBtn)
        self.switchStyleBtn.addTarget(self, action: #selector(ViewController.swithBtnTapped), for: .touchUpInside)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    static let StyleList: [RYDatePickerComponentsStyle] = [.yearMonthDayHourMinute,
                                                            .yearMonthDay,
                                                            .dayHourMinute,
                                                            .monthDay,
                                                            .hourMinute]
    
    var _style: RYDatePickerComponentsStyle = .yearMonthDayHourMinute
    @objc func swithBtnTapped(sender: UIButton) {
        let nextIdx = ViewController.StyleList.index(of: _style)! + 1
        let nextStyle = ViewController.StyleList[nextIdx%ViewController.StyleList.count]
        _style = nextStyle
        sender.setTitle("切换样式：\(_style)", for: .normal)

    }
    
    @objc func showBtnTapped(sender: UIButton) {
        let minDate: Date = Date.date(dateStr: self.minDateField.text ?? "", format: RYDatePicker.DateFormat) ?? {
            self.minDateField.text = nil
            return RYDatePicker.DefaultMinSelectDate
        }()
        let maxDate: Date = Date.date(dateStr: self.maxDateField.text ?? "", format: RYDatePicker.DateFormat) ?? {
            self.maxDateField.text = nil
            return RYDatePicker.DefaultMaxSelectDate
            }()
        let selectDate: Date = Date.date(dateStr: self.selectDateField.text ?? "", format: RYDatePicker.DateFormat) ?? {
            self.selectDateField.text = nil;
            return Date()
        }()
        self.datePicker.minLimitDate = minDate
        self.datePicker.maxLimitDate = maxDate
        self.datePicker.selectDate = selectDate
        self.datePicker.style = _style
        self.view.endEditing(true)
        self.datePicker.show()
    }
}

