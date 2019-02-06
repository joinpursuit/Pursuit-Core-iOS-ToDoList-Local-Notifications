//
//  ItemDetailViewController.swift
//  ToDoList
//
//  Created by Alex Paul on 1/11/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit
import UserNotifications

private enum EditMode: String {
  case edit = "Edit"
  case done = "Done"
  public func updateBarButtonTile() -> String {
    switch self {
    case .done:
      return "Edit"
    case .edit:
      return "Done"
    }
  }
}

class ItemDetailViewController: UIViewController {
  @IBOutlet weak var itemTitleTextView: UITextView!
  @IBOutlet weak var itemDescriptionTextView: UITextView!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  public var item: Item!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
    updateTextViewEditingState(isEditingItem: false)
    
    configureInputAccessoryView()
    
    // local notifications: step 4 (optional)
    // only if you want in-app notifications
    UNUserNotificationCenter.current().delegate = self
  }
  
  // TODO: fix toolbar bug
  private func configureInputAccessoryView() {
    let dismissBarItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissKeyboard))
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
    toolbar.items = [dismissBarItem]
    itemTitleTextView.inputAccessoryView = toolbar
    itemDescriptionTextView.inputAccessoryView = toolbar
  }
  
  @objc private func dismissKeyboard() {
    itemTitleTextView.resignFirstResponder()
    itemDescriptionTextView.resignFirstResponder()
  }
  
  private func updateUI() {
    itemTitleTextView.text = item.title
    itemDescriptionTextView.text = item.description
  }
  
  @IBAction func editItem(_ sender: UIBarButtonItem) {
    updateRightBarItem(editMode:  EditMode.edit)
    updateTextViewEditingState(isEditingItem: true)
  }
  
  private func updateRightBarItem(editMode: EditMode) {
    switch editMode {
    case .edit:
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneEditing))
    case .done:
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editItem(_:)))
    }
  }
  
  @objc private func doneEditing() {
    updateRightBarItem(editMode:  EditMode.done)
    updateTextViewEditingState(isEditingItem: false)
    guard let itemTitle = itemTitleTextView.text,
      let itemDescription = itemDescriptionTextView.text else {
        print("itemTitle, itemDescription is nil")
        return
    }
    // modified date
    let date = Date()
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withFullDate, .withInternetDateTime, .withTimeZone, .withDashSeparatorInDate]
    let modifiedTimestamp = isoDateFormatter.string(from: date)
    let updatedItem = Item.init(title: itemTitle, description: itemDescription, createdAt: modifiedTimestamp)
    
    // find item index and update to documents directory
    let index = ItemModel.getItems().firstIndex { $0 == item }
    if let itemIndex = index {
      ItemModel.updateItem(updatedItem: updatedItem, atIndex: itemIndex)
    }
  }
  
  private func updateTextViewEditingState(isEditingItem: Bool) {
    if isEditingItem {
      itemTitleTextView.isEditable = true
      itemDescriptionTextView.isEditable = true
      itemTitleTextView.becomeFirstResponder()
    } else {
      itemTitleTextView.isEditable = false
      itemDescriptionTextView.isEditable = false
    }
  }
  
  // local notifications: step 3
  // using date picker to configure a calender notification
  @IBAction func datePickerChanged(_ sender: UIDatePicker) {
    // create the notification content
    // title, body, sound
    let content = UNMutableNotificationContent()
    content.title = NSString.localizedUserNotificationString(forKey: item.title, arguments: nil)
    content.body = NSString.localizedUserNotificationString(forKey: item.description, arguments: nil)
    content.sound = UNNotificationSound.default

    // current selected date from picker
    let date = datePicker.date
    
    // create a Calender instance
    let calender = Calendar.current // gregorian calendar
    let hour = calender.component(.hour, from: date)
    let minutes = calender.component(.minute, from: date)

    // create date component
    var dateComonents = DateComponents()
    dateComonents.hour = hour
    dateComonents.minute = minutes
    dateComonents.timeZone = TimeZone.current
    
    // create notification trigger
    // local notification triggers allowed:
    /*
     Time Interval - UNTimeIntervalNotificationTrigger()
     Calendar - UNCalendarNotificationTrigger()
     Location - UNLocationNotificationTrigger()
    */
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComonents, repeats: false)
    
    // create notification request
    let request = UNNotificationRequest(identifier: "To do list Alert", content: content, trigger: trigger)
    
    // add notification for delivery
    UNUserNotificationCenter.current().add(request) { (error) in
      if let error = error {
        print("adding notification error: \(error)")
      } else {
        print("successfully added notification")
      }
    }
  }
}

// local notifications: step 4 (optional)
// only if you want in-app notifications
extension ItemDetailViewController: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
}
