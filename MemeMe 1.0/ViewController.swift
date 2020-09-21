//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Frances Koo on 9/14/20.
//  Copyright © 2020 happyengr1. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Constants
    let animated : Bool = true
    let alignCenter : Int = 1

    // MARK: Variables
    var rearCameraButtonIsEnabled : Bool = false

    // MARK: Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!

    // MARK: Attributed String
    let memeTextAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: -3.0,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!
    ]

    // MARK: View

    //--------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.topTextField.delegate    = self
        self.bottomTextField.delegate = self
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes

        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        self.modalPresentationStyle = .fullScreen
        
    }   /* viewDidLoad */
        
    //--------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.

        // Check if rear camera is available
        rearCameraButtonIsEnabled = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear)
        print("camera button is \(rearCameraButtonIsEnabled)")

        // Subscribe to keyboard notifications to allow the view to be raised
        subscribeToKeyboardNotifications()
                
    }   /* viewWillAppear */

    //--------------------------------------
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscribeToKeyboardNotifications()
    }   /* viewWillDisappear */
    
    
    // MARK: Image Pickers
    
    //-------------------------------------------
    @IBAction func pickAnImage(_ sender: Any) {            /* IBAction: pick button */
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }   /* pickAnImage */
    
    //--------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            picker.sourceType = .photoLibrary
            dismiss(animated: true, completion: nil)
        }
    }   /* imagePickerController */

    //-------------------------------------------
    @IBAction func pickAnImageFromCamera(_ sender: Any) {  /* IBAction: camera button */
        if (rearCameraButtonIsEnabled) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            pickerController.allowsEditing = false
            self.present(pickerController, animated: true, completion: nil)

        } else {
            print("**** Rear camera not available ****")
        }
        
    }   /* pickAnImageFromCamera */
    
    //--------------------------
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //--------------------------
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: Text Field

    //-------------------------------------------
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Figure out what next text will be if we return true
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        // returning true gives text field permission to change its text
        return true;
        
    }   /* textField */

    
    //-------------------------------------------
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Clear text when user clicks in text field
        textField.text = ""
        
        // Automatically show the keyboard
        textField.becomeFirstResponder()
        
    }   /* textFieldDidBeginEditing */
    
    //-------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when the user presswa return
        textField.resignFirstResponder()
        return true
    }   /* textFieldShouldReturn */

    // MARK: Keyboard

    //--------------------------
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        print("getKeyboardHeight")
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue   // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //--------------------------
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing, view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        print("keyboardWillShow: y = \(view.frame.origin.y)")   /* debug */
    }   /* keyboardWillShow */
    
    //--------------------------
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isEditing, view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
        print("keyboardWillHide: y = \(view.frame.origin.y)")   /* debug */
    }   /* keyboardWillShow */
    
    //--------------------------
    func subscribeToKeyboardNotifications() {

        // Subscribe to keyboardWillShow
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Subscribe to keyboardWillHide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }   /* subscribeToKeyboardNotifications */

    //--------------------------
    func unsubscribeToKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    } /* unsubscribeToKeyboardNotifications */


}
