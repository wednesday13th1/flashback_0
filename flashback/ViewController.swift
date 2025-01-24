//
//  ViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/08.
//

import UIKit
import PhotosUI


class ViewController: UIViewController, PHPickerViewControllerDelegate {
    //
    
    var collectionView: UICollectionView
    var displayedStories: [Story] = []
    var timer: Timer?
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedStories = pickRandomStories()
        
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
    
    func pickRandomStories() -> [Story] {
        // 全ての画像からランダムに2つ選択
        guard let savedData = saveData(forKey: "stories") else { return [] }
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
}

// MARK: - カスタムセル
class ImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with story: Story) {
        imageView.image = UIImage(data: story.imageData)
    }
}


