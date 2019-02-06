//
//  AddItemViewController.swift
//  ToDoList
//
//  Created by Alex Paul on 1/11/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
  
  @IBOutlet weak var itemTitleTextView: UITextView!
  @IBOutlet weak var itemDescriptionTextView: UITextView!
  
  private var itemTitlePlaceholder = "Title"
  private var itemDescriptionPlaceholder = "Item description..."
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTextViews()
    itemTitleTextView.becomeFirstResponder()
  }
  
  private func setupTextViews() {
    itemTitleTextView.delegate = self
    itemDescriptionTextView.delegate = self
    itemTitleTextView.text = itemTitlePlaceholder
    itemDescriptionTextView.text = itemDescriptionPlaceholder
    itemTitleTextView.textColor = .lightGray
    itemDescriptionTextView.textColor = .lightGray
  }
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func addItem(_ sender: UIBarButtonItem) {
    guard let itemTitle = itemTitleTextView.text,
      let itemDescription = itemDescriptionTextView.text else {
        fatalError("title, description nil")
    }
    
    // timestamp base on the current time
    let date = Date()
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withFullDate,
                                      .withFullTime,
                                      .withInternetDateTime,
                                      .withTimeZone,
                                      .withDashSeparatorInDate]
    let timestamp = isoDateFormatter.string(from: date)
    
    // create an item
    let item = Item.init(title: itemTitle, description: itemDescription, createdAt: timestamp)
    
    // save item to documents directory
    ItemModel.addItem(item: item)
    
    
    dismiss(animated: true, completion: nil)
  }
}

extension AddItemViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if itemTitleTextView.text == itemTitlePlaceholder {
      textView.text = ""
      textView.textColor = .black
    }
    if itemDescriptionTextView.text == itemDescriptionPlaceholder {
      textView.text = ""
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      if textView == itemTitleTextView || textView == itemDescriptionTextView {
        if textView == itemTitleTextView {
          textView.text = itemTitlePlaceholder
          textView.textColor = .lightGray
        } else if textView == itemDescriptionTextView {
          textView.text = itemDescriptionPlaceholder
          textView.textColor = .lightGray
        }
      }
    }
  }
}
