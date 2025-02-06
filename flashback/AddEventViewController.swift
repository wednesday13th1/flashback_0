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
    let pickedDate: Date
}


class AddEventViewController: UIViewController, PHPickerViewControllerDelegate {
    
    let addPhotoButton = UIButton()
    var events: [Event] = []
    let saveButton = UIButton()
    let dateButton = UIButton()
    let textview = UITextView()
    let imageView = UIImageView()
    let datePicker = UIDatePicker()
    
    
    var selectedImageData: Data?
    var selectedDate: Date = Date()
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPhotoButton.setTitle("写真を追加する", for: .normal)
        addPhotoButton.setTitleColor(.black, for: .normal)
        addPhotoButton.setTitleColor(.systemGreen, for: .selected)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.addTarget(self, action: #selector(AddEventViewController.addphoto), for: .touchUpInside)
        self.view.addSubview(addPhotoButton)
        // Do any additional setup after loading the view.
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        view.addSubview(imageView)
        
        
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.layer.borderColor = UIColor.gray.cgColor
        textview.layer.borderWidth = 1.0
        textview.layer.cornerRadius = 8.0
        textview.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textview)
        
        saveButton.setTitle("保存する", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .black
        saveButton.layer.cornerRadius = 8.0
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveEventStory), for: .touchUpInside)
        view.addSubview(saveButton)
        
        //1/29
        dateButton.setTitle("日付", for: .normal)
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.setTitleColor(.systemGreen, for: .selected)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.addTarget(self, action: #selector(showdatePicker), for: .touchUpInside)
        view.addSubview(dateButton)
        
        //UIDate Picker の設定
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        //Auto Layout 制約の適用
        NSLayoutConstraint.activate([
            //画像ボタンの制約
            addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 200),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 40),
            
            //日付ボタンの制約
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateButton.widthAnchor.constraint(equalToConstant: 200),
            dateButton.heightAnchor.constraint(equalToConstant: 40),
            
            //画像viewの制約
            imageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            //テキストビューの制約
            textview.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            textview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textview.heightAnchor.constraint(equalToConstant: 100),
            
            //保存ボタンの制約
            saveButton.topAnchor.constraint(equalTo: textview.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            if UIDevice.current.orientation.isLandscape {
                print("横向きになりました")
                updateLayoutForLandscape()
            } else {
                print("横向きになりました")
                updateLayoutForPortrait()
            }
        }
        
        //縦レイアウト更新
        func updateLayoutForLandscape() {
            NSLayoutConstraint.deactivate(view.constraints)
            NSLayoutConstraint.activate([
                
                addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                addPhotoButton.widthAnchor.constraint(equalToConstant: 150),
                addPhotoButton.heightAnchor.constraint(equalToConstant: 40),
                
                dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                dateButton.widthAnchor.constraint(equalToConstant: 150),
                dateButton.heightAnchor.constraint(equalToConstant: 40),
                
                imageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 20),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.5),
                imageView.heightAnchor.constraint(equalToConstant: 150),
                
                textview.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                textview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                textview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textview.heightAnchor.constraint(equalToConstant: 150),
                
                saveButton.topAnchor.constraint(equalTo: textview.bottomAnchor, constant: 20),
                saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                saveButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        func updateLayoutForPortrait() {
            NSLayoutConstraint.deactivate(view.constraints)
            NSLayoutConstraint.activate([
                
                addPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                addPhotoButton.widthAnchor.constraint(equalToConstant: 200),
                addPhotoButton.heightAnchor.constraint(equalToConstant: 40),
                
                dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                dateButton.widthAnchor.constraint(equalToConstant: 200),
                dateButton.heightAnchor.constraint(equalToConstant: 40),
                
                imageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 20),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                imageView.heightAnchor.constraint(equalToConstant: 200),
                
                textview.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                textview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
                textview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textview.heightAnchor.constraint(equalToConstant: 100),
                
                saveButton.topAnchor.constraint(equalTo: textview.bottomAnchor, constant: 20),
                saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                saveButton.heightAnchor.constraint(equalToConstant: 50)
                
            ])
        }
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
    
    @objc func showdatePicker() {
        let datePickerVC = UIViewController()
        datePickerVC.preferredContentSize = CGSize(width: 300, height: 350)
        
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(dateChanged(_ :)), for: .valueChanged)
        
        datePickerVC.view.addSubview(picker)
        
        //Auto Layout設定 (上下中央&横幅いっぱい)
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: datePickerVC.view.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: datePickerVC.view.centerYAnchor),
            picker.widthAnchor.constraint(equalTo: datePickerVC.view.widthAnchor, multiplier: 0.9),
            picker.heightAnchor.constraint(equalToConstant: 250)//高さを適切に確保
        ])
        
        let alert = UIAlertController(title: "日付を選択", message: nil, preferredStyle: .alert)
        alert.setValue(datePickerVC, forKey: "contentViewController")
        
        let selectAction = UIAlertAction(title: "決定", style: .default) { _ in
            self.selectedDate = picker.date
            self.updateDateButtonTitle()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alert.addAction(selectAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @objc func dateChanged(_ sender: UIDatePicker){
        selectedDate = sender.date
    }
    private func updateDateButtonTitle() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateButton.setTitle(formatter.string(from: selectedDate), for: .normal)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
//    
//    @objc func saveEvent() {
//            guard let text = textview.text, !text.isEmpty else {
//                print("テキストが入力されていません")
//                return
//            }
//            
//            guard let imageData = selectedImageData else {
//                print("画像が選択されていません。")
//                return
//            }
//            
//        let selectedDate = datePicker.date
//        print(selectedDate)
//        let newEvent = Event(text: text, imageData: imageData, pickedDate: selectedDate)
//        let saveData = UserDefaults.standard
//        events.append(newEvent)
//            
//            do {
//                let encoder = JSONEncoder()
//                let data = try encoder.encode(events)
//                saveData.set(data, forKey: "stories")
//                saveData.synchronize()
//                print("ストーリーが保存されました。")
//                
//                // アラートを表示する
//                showSaveAlert()
//                
//            } catch {
//                print("ストーリーの保存に失敗しました。", error)
//            }
//            
//            // 入力フィールドをリセット
//            textview.text = ""
//            imageView.image = nil
//            selectedImageData = nil
//        }
    @IBAction func saveEventStory() {
        let selectedImage = UIImage(named: "eventImage")
        let storyText = "This is an event story."

        RealmManager.shared.saveStory(image: selectedImage, text: storyText, type: "event")
    }

        private func showSaveAlert() {
            let alert = UIAlertController(title: "保存完了", message: "ストーリーが保存されました！", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}
