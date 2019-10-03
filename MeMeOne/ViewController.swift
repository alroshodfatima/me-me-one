//
//  ViewController.swift
//  MeMeOne
//
//  Created by Fatimah on 01/02/1441 AH.
//  Copyright © 1441 Fatimah. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var memeNavigator: UINavigationBar!
    @IBOutlet weak var shareActionButton: UIBarButtonItem!
    
    // MARK: override functions
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        cancelButton.isEnabled = false
        shareActionButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField(topTextField, text: "TOP")
        configureTextField(bottomTextField, text: "BOTTOM")
      }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: function to configure text fields properties and style
    func configureTextField(_ textField: UITextField, text: String) {
            textField.text = text
            textField.delegate = self
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            textField.defaultTextAttributes = [
                .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2,
                .backgroundColor: UIColor.clear,
                .paragraphStyle: paragraphStyle
            ]
    }
    
    // MARK: meme Struct
    struct MeMe {
        
        let topText: String!
        let bottomText: String!
        let originalImage: UIImage!
        let meMedImage: UIImage!
    }
    
    func save() {
            // Create the meme
            let meme = MeMe(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, meMedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {

        // TODO: Hide toolbar and navbar
        toolBar.isHidden = true
        memeNavigator.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolBar.isHidden = false
        memeNavigator.isHidden = false

        return memedImage
    }
    
    // MARK: functions for image and image picker
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(.photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(.camera)
    }
    
    func pickAnImage(_ source: UIImagePickerController.SourceType) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = source
            present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: {
            self.shareActionButton.isEnabled = true
            self.cancelButton.isEnabled = true
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: text field delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            return true
        }else {
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textFieldShouldClear(textField) {
            textField.text = ""
        }
        
    }
    
    // MARK: keyboard notification
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if view.frame.origin.y == 0 && bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: share action
    @IBAction func shareMeMe(_ sender: Any) {
        let memeImage:UIImage = self.generateMemedImage()
        
        let controller = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in

            if completed  {
                self.save()
            }
        }
    }
    
    // MARK: cancel action
    @IBAction func cancelPressed(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        shareActionButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    
}

