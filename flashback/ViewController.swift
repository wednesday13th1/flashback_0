//
//  ViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/08.
//

import UIKit



class ViewController: UIViewController, PHPickerViewControllerDelegate {
    //
    @IBOutlet var collectionView: UICollectionView!
    let addButton = UIButton()
    // let allImageNames = ["image1", "image2", "image3", "image4", "image5", "image6", "image7", "image8"] // 8個の画像
    // var displayedImageNames: [String] = [] // 表示中の2つの画像を格納
    var photoDataArray: [NSData] = []
    var displayedPhotoDataArray: [NSData] = []
    var timer: Timer?
    var saveData: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedPhotoDataArray = pickRandomImages()
        
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
    
    func pickRandomImages() -> [NSData] {
        // 全ての画像からランダムに2つ選択
        return Array(photoDataArray.shuffled().prefix(2))
    }
    
    func updateDisplayedImages() {
        // 新しい画像をランダムに選び、コレクションビューを更新
        displayedPhotoDataArray = pickRandomImages()
        collectionView.reloadData()
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPhotoDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.configure(with: displayedPhotoDataArray[indexPath.item])
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
    
    func configure(with displayedPhotoData: NSData) {
        imageView.image = UIImage(data: displayedPhotoData as Data)
    }
}


