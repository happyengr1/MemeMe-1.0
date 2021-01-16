//
//  MemeEditorViewController.swift
//  MemeMe 2.0
//
//  Created by Frances Koo on 9/14/20.
//  Copyright © 2020 happyengr1. All rights reserved.
//
//  History
//  8 Oct 2020  MemeMe 1.0 submitted'
// 28 Nov 2020  Added memes.append in save()
// 13 Dec 2020  Next: Add Cancel Button to get to Meme Editor in Storyboard
// 21 Dec 2020  Change imagePickerController -->> imagePicker in pickAnImage()
// 02 Jan 2021  Added cancelButton IBOutlet and IBAction
// 10 Jan 2021  Table and Collection presented using Push; Dismiss using Pop
// 15 Jan 2021  completionWIthItemsHandler logic
//

import Foundation
import UIKit

class MemeEditorViewController: UIViewController {

    // MARK: - Constants
    let animated : Bool = true
    let alignCenter : Int = 1

    // MARK: Variables
    var rearCameraButtonIsEnabled : Bool = false
    var image : UIImage!
    var memedImage : UIImage!
    var actionButtonIsEnabled : Bool = false
    var imageIsValid : Bool = false
    var memedImageIsValid : Bool = false
    
    // MARK: - Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    // MARK: Attributed String
    let memeTextAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: -3.0,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!
    ]

    // MARK: - View

    //--------------------------------------
    func setupTextField(_ textField: UITextField, text: String) {
 
        textField.delegate    = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text

    }   /* setupTextField */
    
    //--------------------------------------
    // viewDidLoad is only triggered once
    //--------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupTextField(topTextField, text: "TOP")
        setupTextField(bottomTextField, text: "BOTTOM")

        self.modalPresentationStyle = .fullScreen
        
    }   /* viewDidLoad */

    //--------------------------------------
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.

        // Check if rear camera is available
        rearCameraButtonIsEnabled = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear)
        // print("camera button is \(rearCameraButtonIsEnabled)")
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        // Subscribe to keyboard notifications to allow the view to be raised
        subscribeToKeyboardNotifications()

    }   /* viewWillAppear */

    //--------------------------------------
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscribeToKeyboardNotifications()
    }   /* viewWillDisappear */
    
    
    // MARK: - Memed Object
    //--------------------------
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!,
                        bottomText: bottomTextField.text!,
                        originalImage: imagePickerView.image!,
                        memedImage: memedImage)
        
        // UIKit 8.4: Add it to the memes array on the Application Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)

    }   /* save */

    //--------------------------
    func hideToolbars(_ isHidden: Bool) {
        
        self.navigationController?.setToolbarHidden(isHidden, animated: false)
        self.navigationController?.setNavigationBarHidden(isHidden, animated: false)

    }   /* hideToolbars */
    
    //--------------------------
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        hideToolbars(true)

        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        let memedImage:UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        hideToolbars(false)

        self.memedImageIsValid = true
        self.memedImage = memedImage

        return memedImage
        
    }   /* generateMemedImage */

    
    //--------------------------
    // MARK: - Action / Share Button

    func checkForValidInfo() -> Bool {

        var isValidInfo: Bool = true
        
        if (topTextField.text == "TOP" || topTextField.text == "") {
            isValidInfo = false
        }

        if (bottomTextField.text == "BOTTOM" || bottomTextField.text == "") {
            isValidInfo = false
        }

        if (self.imageIsValid == false) {
            isValidInfo = false
        }

        return isValidInfo

    }   /* checkForValidInfo */
    

    //--------------------------
    func checkForValidMeme() -> Bool {

        var isValidMeme: Bool = true
        
        isValidMeme = checkForValidInfo()
        
        if (self.memedImageIsValid == false) {
            isValidMeme = false
        }

        return isValidMeme

    }   /* checkForValidMeme */
    
    
    //--------------------------
    func showActivityView() {
        
        var memedImg : UIImage = generateMemedImage() as UIImage
        
        if (checkForValidMeme() == true) {
            
            // Launch the activity view controller
            let activityController = UIActivityViewController(activityItems: [memedImg], applicationActivities: nil)
            
            // Screen for iPhone
            if (UIDevice.current.userInterfaceIdiom != .phone) {

                // Exit if not an iPhone
                print(UIDevice.current.model, terminator: "")
                print(" is not a supported device for this app")

            } else {
                
                // Save the memed image
                print("showActivityView: iPhone detected")
                self.present(activityController, animated: true, completion: nil)

                activityController.completionWithItemsHandler = {
                    (activity, success, items, error) in
                    // if (success && (error == nil)) {
                    if success {
                        // Save the info into the meme structure
                        self.save()
                    }
                }
            }   /* iPhone */
        } else {
            print("showActivityView: showActivityView: No meme was generated")
        }
    }   /* showActivityView */
    
    //--------------------------
    @IBAction func actionButton(_ sender: Any) {

        /* Check if meme has been created, by checking all the meme fields */
        if (checkForValidInfo() == true) {
            /* Allow user to share the meme */
            showActivityView()
        } else {
            print("actionButton: Meme data is incomplete")
        }
    }   /* actionButton */
    
    
    //--------------------------
    // MARK: Cancel Button
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        
        /// View was presented using Push segue, so use Pop to dismiss
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }   /* cancelButton*/

}   /* MemeEditorViewController */


// MARK: - Image Pickers

// MemedEditorViewController Extension for Image Picker
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //-------------------------------------------
    @IBAction func pickAnImage(_ sender: Any) {            /* IBAction: pick button */
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
    }   /* pickAnImage */

    //--------------------------------------
    func chooseImageFromSource(source: UIImagePickerController.SourceType) {

        let pickerController = UIImagePickerController()

        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
        imageIsValid = true

    }   /* chooseImageFromSource */

    //--------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            chooseImageFromSource(source: .photoLibrary)
            dismiss(animated: true, completion: nil)
        }
    }   /* imagePickerController */

    //-------------------------------------------
    @IBAction func pickAnImageFromCamera(_ sender: Any, idFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                
        if (rearCameraButtonIsEnabled) {
            
            if let image = info[.originalImage] as? UIImage {
                imagePickerView.image = image
                chooseImageFromSource(source: .camera)
                dismiss(animated: true, completion: nil)
            }

        } else {
            print("**** Rear camera not available ****")
        }
    }  /* IBAction: pickAnImageFromCamera */


    //--------------------------
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //--------------------------
        dismiss(animated: true, completion: nil)
    }
}   /* MemeEditorViewController Extension for Imiage Picker */



// MARK: - Text Fields

// MemedEditorViewController Extension for Text Fields
extension MemeEditorViewController: UITextFieldDelegate {

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

    // MARK: - Keyboard

    //--------------------------
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue   // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //--------------------------
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing, view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }   /* keyboardWillShow */
    
    //--------------------------
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isEditing, view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
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
    
}   /* MemeEditorViewController Extension for Text Fields*/
