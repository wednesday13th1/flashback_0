//
//  AddEventViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/29.
//


//
//  AddStoryViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/24.
//


import UIKit
import PhotosUI

struct Event: Codable{
    let text: String
    let imageData: Data
}


class AddEventViewController: UIViewController, PHPickerViewControllerDelegate {
    
    let addPhotoButton = UIButton()
    var events: [Event] = []
    let saveButton = UIButton()
    let dateButton = UIButton()
    let textview = UITextView()
    let imageView = UIImageView()
    
    
    var selectedImageData: Data?
    var saveData: UserDefaults = UserDefaults.standard
    
        public enum UIDatePickerStyle : Int {
            case automatic = 0
            case wheels = 1
            case compact = 2

            @available(iOS 14.0, *)
            case inline = 3
    }

    @IBOutlet weak var datePicker: UIDatePicker!
    
    datePicker;.preferredDatePickerStyle() = .inline
    datePicker;.datePickerMode = .dateAndTime()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPhotoButton.setTitle("写真を追加する", for: .normal)
        addPhotoButton.setTitleColor(.black, for: .normal)
        addPhotoButton.setTitleColor(.systemGreen, for: .selected)
        addPhotoButton.frame = CGRect(x:20, y:100, width: 200, height: 40)
        addPhotoButton.addTarget(self, action: #selector(AddEventViewController.addphoto), for: .touchUpInside)
        self.view.addSubview(addPhotoButton)
        // Do any additional setup after loading the view.
        
        imageView.frame = CGRect(x: 20, y:160, width: view.frame.width - 40, height: 200)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        view.addSubview(imageView)
        
        
        textview.frame = CGRect(x: 20, y: 380, width: view.frame.width - 40, height: 100)
        textview.layer.borderColor = UIColor.gray.cgColor
        textview.layer.borderWidth = 1.0
        textview.layer.cornerRadius = 8.0
        textview.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textview)
        
        saveButton.setTitle("保存する", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .black
        saveButton.layer.cornerRadius = 8.0
        saveButton.frame = CGRect(x: 20, y:500, width: view.frame.width - 40, height: 50)
        saveButton.addTarget(self, action: #selector(saveEvent), for: .touchUpInside)
        view.addSubview(saveButton)
        
        //1/29
        dateButton.setTitle("日付", for: .normal)
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.setTitleColor(.systemGreen, for: .selected)
        dateButton.frame = CGRect(x: view.frame.width - 220, y:100, width: 200, height: 40)
        view.addSubview(dateButton)
        
        }
    @objc func addphoto() {
        var configuration = PHPickerConfiguration()
        
        let filter = PHPickerFilter.images
        configuration.filter = filter
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let itemProvider = results.first?.itemProvider else {
            dismiss(animated: true)
            return
        }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("画像習得に失敗しました", error)
                    return
                    
                }
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage, let imageData = selectedImage.pngData(){
                        self.selectedImageData = imageData
                        self.imageView.image = selectedImage
                        print("画像が選択されました")
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc func saveEvent() {
            guard let text = textview.text, !text.isEmpty else {
                print("テキストが入力されていません")
                return
            }
            
            guard let imageData = selectedImageData else {
                print("画像が選択されていません。")
                return
            }
            
            let newEvent = Event(text: text, imageData: imageData)
        events.append(newEvent)
            
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(events)
                saveData.set(data, forKey: "stories")
                saveData.synchronize()
                print("ストーリーが保存されました。")
                
                // アラートを表示する
                showSaveAlert()
                
            } catch {
                print("ストーリーの保存に失敗しました。", error)
            }
            
            // 入力フィールドをリセット
            textview.text = ""
            imageView.image = nil
            selectedImageData = nil
        }

        private func showSaveAlert() {
            let alert = UIAlertController(title: "保存完了", message: "ストーリーが保存されました！", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}


