//
//  AddStoryViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/24.
//

import UIKit
import PhotosUI

struct Story: Codable{
    let text: String
    let imageData: Data
}

class AddStoryViewController: UIViewController, PHPickerViewControllerDelegate {
    
    let addPhotoButton = UIButton()
    var stories: [Story] = []
    let saveButton = UIButton()
    let textview = UITextView()
    var selectedImageData: Data?
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPhotoButton.setTitle("写真を追加する", for: .normal)
        addPhotoButton.setTitleColor(.systemBlue, for: .normal)
        addPhotoButton.setTitleColor(.systemGreen, for: .selected)
        addPhotoButton.frame = CGRect(x:0, y:100, width: 370, height: 30)
        addPhotoButton.addTarget(self, action: #selector(AddStoryViewController.addphoto), for: .touchUpInside)
        self.view.addSubview(addPhotoButton)
        // Do any additional setup after loading the view.
        
        textview.frame = CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 100)
        textview.layer.borderColor = UIColor.gray.cgColor
        textview.layer.borderWidth = 1.0
        textview.layer.cornerRadius = 8.0
        textview.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textview)
        
        saveButton.setTitle("保存する", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 8.0
        saveButton.frame = CGRect(x: 20, y: 280, width: view.frame.width - 40, height: 50)
        saveButton.addTarget(self, action: #selector(saveStory), for: .touchUpInside)
        view.addSubview(saveButton)
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
    @objc func saveStory() {
        guard let text = textview.text, !text.isEmpty else {
            print("テキストが入力されていません")
            return
        }
        
        
        guard let imageData = selectedImageData else {
            print("画像が選択されていません。")
            return
        }
        let newStory = Story(text: text, imageData: imageData)
        stories.append(newStory)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(stories)
            saveData.set(data, forKey: "stories")
            saveData.synchronize()
            print("ストーリーが保存されました。")
        } catch {
            print("ストーリーの保存に失敗しました。", error)
        }
        
        textview.text = ""
        selectedImageData = nil
    }
}


