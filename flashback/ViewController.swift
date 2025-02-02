//
//  ViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/08.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var displayedStories: [Story] = []
    var timer: Timer?
    var saveData: UserDefaults = UserDefaults.standard
    
    let dateLabel = UILabel()
    let datePicker = UIDatePicker()
    let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedStories = pickRandomStories()
        
        dateLabel.text = getDate()
        // DatePickerの設定
        //datePicker.preferredDatePickerStyle = .compact
        //datePicker.datePickerMode = .dateAndTime
        //datePicker.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(datePicker)
        
        // 保存ボタンの設定
        //saveButton.setTitle("保存", for: .normal)
        //saveButton.addTarget(self, action: #selector(saveDate), for: .touchUpInside)
        //saveButton.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(saveButton)

        
        // レイアウトを設定
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing: CGFloat = 10
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - (spacing * 3)) / 2 // 2列にする計算
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        // コレクションビューを初期化
        let screenHeight = UIScreen.main.bounds.height
        let frame = CGRect(x: 0, y: screenHeight/2 - itemWidth/2, width: screenWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        
        // Timerのセットアップ
        startImageAnimation()
    }
    
    deinit {
        // Timerを解放
        timer?.invalidate()
    }
    
    func startImageAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateDisplayedImages()
        }
    }
    @objc func saveDate() {
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = formatter.string(from: selectedDate)
        
        // UserDefaultsへ保存
        saveData.set(dateString, forKey: "selectedDate")
        
        // ラベルに反映
        dateLabel.text = dateString
    }
    
        
        func pickRandomStories() -> [Story] {
            // 全ての画像からランダムに2つ選択
            guard let savedData = saveData.data(forKey: "stories") else { return [] }
            do {
                let decoder = JSONDecoder()
                let stories = try decoder.decode([Story].self, from: savedData)
                return Array(stories.shuffled().prefix(2))
            } catch {
                print("デコードに失敗しました")
                return []
            }
            
        }
        
        func updateDisplayedImages() {
            // 新しい画像をランダムに選び、コレクションビューを更新
            displayedStories = pickRandomStories()
            collectionView.reloadData()
        }
        func getDate() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            return formatter.string(from: Date())
        }
        
        
    }
    
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
    extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return displayedStories.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.configure(with: displayedStories[indexPath.item])
            return cell
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let detailVC = DetailViewController()
            detailVC.story = displayedStories[indexPath.item]
            present(detailVC, animated: true)
        }
    }
    
    // MARK: - カスタムセル
    class ImageCell: UICollectionViewCell {
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        private let textLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 2
            return label
        } ()
        private let dateLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 2
            return label
        } ()
        override init(frame: CGRect) {

        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
            contentView.addSubview(dateLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        
        textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
        textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        
        dateLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 10),
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with story: Story) {
            imageView.image = UIImage(data: story.imageData)
            textLabel.text = story.text
        }
    }


