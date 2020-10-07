//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Frances Koo on 9/14/20.
//  Copyright © 2020 happyengr1. All rights reserved.
//
//  History
//  20 Sep 2020     viewWillAppear(_:) gets called, bottom text field moves when keyboard is shown
//  21 Sep 2020     remove debug statements
//  29 Sep 2020     added share button
//                  check if memeImage is valid
//  2 Oct 2020      added checkForValidMeme(), showActivityView()
//                  added completionWithItemsHandler(), save()
//  3 Oct 2020      added checkForValidInfo(), activity view is shown
//  4 Oct 2020      only allow Activity View Controller for iPhone
//  6 Oct 2020      Feedback: Add chooseImageFromSource() to reduce redundancy
//                  Feedback: Add Navigation Bar and Action Button
//                  Feedback: Disable Camera Button if camera not available
//  7 Oct 2020      Code Review: Renamed ViewController to MemeEditorViewController
//                  Code Review: Added setupTextField() to reduce redundancy
//                  Code Review: Removed redundancies in chooseImageFromSource()
//

import Foundation
import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Constants
    let animated : Bool = true
    let alignCenter : Int = 1

    // MARK: Variables
    var rearCameraButtonIsEnabled : Bool = false
    var image : UIImage!
    var memedImage : UIImage!
    var actionButtonIsEnabled : Bool = false
    var imageIsValid : Bool = false
    var memedImageIsValid : Bool = false

    // MARK: Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    // MARK: Attributed String
    let memeTextAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: -3.0,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!
    ]

    // MARK: View

    //--------------------------------------
    func setupTextField(_ textField: UITextField, text: String) {
 
        textField.delegate    = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text

    }   /* setupTextField */
    
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
    
    
    // MARK: Image Pickers
    
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

    // MARK: Memed Object
    
    //--------------------------
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    //--------------------------
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!,
                        bottomText: bottomTextField.text!,
                        originalImage: imagePickerView.image!,
                        memedImage: memedImage)
    }   /* save */
    
    //--------------------------
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        let memedImage:UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.memedImageIsValid = true
        self.memedImage = memedImage

        return memedImage
        
    }   /* generateMemedImage */
    
    // MARK: Share

    //--------------------------
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
        
        var goAhead: Bool = false

        var memedImg : UIImage = generateMemedImage() as UIImage
        
        if (checkForValidMeme() == true) {
            
            // Launch the activity view controller
            let activityController = UIActivityViewController(activityItems: [memedImg], applicationActivities: nil)
            
            // for iPhone
            if (UIDevice.current.userInterfaceIdiom == .phone) {
                print("showActivityView: running on iPhone")
                self.present(activityController, animated: true, completion: nil)
                goAhead = true

            // for other devices
            } else {
                print(UIDevice.current.model, terminator: "")
                print(" is not a supported device for this app")
                goAhead = false
            }
            
            if goAhead {
                activityController.completionWithItemsHandler = {
                    (activity, success, items, error) in
                    if (success && (error != nil)) {
                        // Save the info into the meme structure
                        self.save()
                    }
                }
            }
        } else {
            print("showActivityView: showActivityView: No meme was generated")
        }
    }   /* showActivityView */
    
    //--------------------------
    @IBAction func actionButton(_ sender: Any) {            /* IBAction: action button */

        /* Check if meme has been created, by checking all the meme fields */
        if (checkForValidInfo() == true) {
            /* Allow user to share the meme */
            showActivityView()
        } else {
            print("actionButton: Meme data is incomplete")
        }
    }   /* actionButton */
    
}
