//
//  AddStoryViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/24.
//

import UIKit
import PhotosUI

//struct Story: Codable{
//    let text: String
//    let imageData: Data
//}

class AddStoryViewController: UIViewController, PHPickerViewControllerDelegate {
    
    let addPhotoButton = UIButton()
    var stories: [Story] = []
    let saveButton = UIButton()
    let textview = UITextView()
    let imageView = UIImageView()
    var selectedImageData: Data?
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPhotoButton.setTitle("写真を追加する", for: .normal)
        addPhotoButton.setTitleColor(.black, for: .normal)
        addPhotoButton.setTitleColor(.systemGreen, for: .selected)
//        addPhotoButton.frame = CGRect(x:20, y:100, width: 200, height: 40)
        addPhotoButton.addTarget(self, action: #selector(AddStoryViewController.addphoto), for: .touchUpInside)
        self.view.addSubview(addPhotoButton)
        // Do any additional setup after loading the view.
        
//        imageView.frame = CGRect(x: 20, y:160, width: view.frame.width - 40, height: 200)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        view.addSubview(imageView)
        
        
//        textview.frame = CGRect(x: 20, y: 380, width: view.frame.width - 40, height: 100)
        textview.layer.borderColor = UIColor.gray.cgColor
        textview.layer.borderWidth = 1.0
        textview.layer.cornerRadius = 8.0
        textview.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textview)
        
        saveButton.setTitle("保存する", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .black
        saveButton.layer.cornerRadius = 8.0
//        saveButton.frame = CGRect(x: 20, y:500, width: view.frame.width - 40, height: 50)
        saveButton.addTarget(self, action: #selector(savePhotoStory), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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
//    @objc func saveStory() {
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
//            let newStory = Story(text: text, imageData: imageData)
//            stories.append(newStory)
//            
//            do {
//                let encoder = JSONEncoder()
//                let data = try encoder.encode(stories)
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
    @IBAction func savePhotoStory() {
        let selectedImage = UIImage(named: "samplePhoto")
        let storyText = "This is a photo story."

        RealmManager.shared.saveStory(image: selectedImage, text: storyText, type: "photo")
    }

        private func showSaveAlert() {
            let alert = UIAlertController(title: "保存完了", message: "ストーリーが保存されました！", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}


