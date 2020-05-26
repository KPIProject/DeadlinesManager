//
//  EditProjectViewController.swift
//  DeadlinesManager
//
//  Created by Головаш Анастасия on 19.05.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit

protocol EditProjectViewControllerDelegate {
    func transmitEditDeadlineInformation(parameters: [String : Any])
}

class EditProjectViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: EditProjectViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var deadlineDateTextField: UITextField!
    
    public var project: Project?
//    private var dataToChange: [String : Any] = [:]
    
    private let datePicker = UIDatePicker()
    /// date of the deadline
    private var timeIntervalFromDatePicker: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let project = project {
            nameTextField.text  = project.projectName
            descriptionTextView.text = project.projectDescription
//            deadlineDateTextField.text = project.projectExecutionTime.toDateString()
        }
        
        setupDatePicker()
 
    }
    
    // MARK: - date Picker funcs
    
    private func setupDatePicker() {
        nameTextField.delegate = self
        deadlineDateTextField.delegate = self
        
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        deadlineDateTextField.inputView = datePicker
        deadlineDateTextField.inputAccessoryView = toolbar
        deadlineDateTextField.text = project?.projectExecutionTime.toDateString()
    }
    
    @objc func doneAction() {
        timeIntervalFromDatePicker = Int(datePicker.date.timeIntervalSince1970)
        view.endEditing(true)
    }
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        deadlineDateTextField.text = formatter.string(from: datePicker.date)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        return true
    }
    @IBAction func didPressDoneButton(_ sender: UIButton) {
        let parameters = ["projectName" : nameTextField.text ?? "", "projectDescription" : descriptionTextView.text ?? "", "projectExecutionTime" : timeIntervalFromDatePicker] as [String : Any]
        delegate?.transmitEditDeadlineInformation(parameters: parameters)
        
        self.dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func didPressDoneButton(_ sender: UIBarButtonItem) {
//        let parameters = ["projectName" : nameTextField.text ?? "", "projectDescription" : descriptionTextView.text ?? "", "projectExecutionTime" : timeIntervalFromDatePicker] as [String : Any]
//        delegate?.transmitEditDeadlineInformation(parameters: parameters)
//        
//        self.dismiss(animated: true, completion: nil)
//    }
    
}
