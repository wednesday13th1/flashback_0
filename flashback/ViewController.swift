//
//  ViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/08.
//

import UIKit
import PhotosUI
import RealmSwift

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var displayedStories: [Story] = []
    var timer: Timer?
    var saveData: UserDefaults = UserDefaults.standard
    
    let dateLabel = UILabel()
    let datePicker = UIDatePicker()
    let saveButton = UIButton(type: .system)
    
    // 追加: 同一画面で詳細情報を表示するためのオーバーレイ用ビュー
    let detailContainerView = UIView()
    let detailContentView = UIView()
    let detailImageView = UIImageView()
    let detailCommentLabel = UILabel()
    let detailDateLabel = UILabel()
    let detailCloseButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedStories = pickRandomStories()
        
        //UserDefaultsに保存された日付があれば表示、なければ現在の日付を表示
        if let savedDate = saveData.string(forKey: "selectedDate") {
            dateLabel.text = savedDate
        } else {
            dateLabel.text = getDate()
        }
        
        // 画面上部に日付表示用のサブビューを追加
        let dateContainerView = UIView()
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateContainerView)
        dateContainerView.addSubview(dateLabel)
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            dateLabel.centerXAnchor.constraint(equalTo: dateContainerView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateContainerView.centerYAnchor)
        ])
        
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
        
        view.addSubview(collectionView)
        
        // Timerのセットアップ
        startImageAnimation()
        
        // --- Detail Overlayのセットアップ ---
        detailContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        detailContainerView.translatesAutoresizingMaskIntoConstraints = false
        detailContainerView.isHidden = true
        view.addSubview(detailContainerView)
        NSLayoutConstraint.activate([
            detailContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            detailContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            detailContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // detailContentViewの設定
        detailContentView.backgroundColor = .white
        detailContentView.layer.cornerRadius = 10
        detailContentView.translatesAutoresizingMaskIntoConstraints = false
        detailContainerView.addSubview(detailContentView)
        NSLayoutConstraint.activate([
            detailContentView.centerXAnchor.constraint(equalTo: detailContainerView.centerXAnchor),
            detailContentView.centerYAnchor.constraint(equalTo: detailContainerView.centerYAnchor),
            detailContentView.widthAnchor.constraint(equalTo: detailContainerView.widthAnchor, multiplier: 0.8),
            detailContentView.heightAnchor.constraint(equalTo: detailContainerView.heightAnchor, multiplier: 0.5)
        ])
        
        // detailCloseButtonの設定
        detailCloseButton.setTitle("閉じる", for: .normal)
        detailCloseButton.addTarget(self, action: #selector(closeDetailView), for: .touchUpInside)
        detailCloseButton.translatesAutoresizingMaskIntoConstraints = false
        detailContentView.addSubview(detailCloseButton)
        NSLayoutConstraint.activate([
            detailCloseButton.topAnchor.constraint(equalTo: detailContentView.topAnchor, constant: 10),
            detailCloseButton.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor, constant: -10)
        ])
        
        // detailImageViewの設定
        detailImageView.contentMode = .scaleAspectFill
        detailImageView.clipsToBounds = true
        detailImageView.translatesAutoresizingMaskIntoConstraints = false
        detailContentView.addSubview(detailImageView)
        NSLayoutConstraint.activate([
            detailImageView.topAnchor.constraint(equalTo: detailContentView.topAnchor, constant: 40),
            detailImageView.centerXAnchor.constraint(equalTo: detailContentView.centerXAnchor),
            detailImageView.widthAnchor.constraint(equalTo: detailContentView.widthAnchor, multiplier: 0.8),
            detailImageView.heightAnchor.constraint(equalTo: detailContentView.heightAnchor, multiplier: 0.5)
        ])
        
        // detailCommentLabelの設定
        detailCommentLabel.textAlignment = .center
        detailCommentLabel.numberOfLines = 0
        detailCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        detailContentView.addSubview(detailCommentLabel)
        NSLayoutConstraint.activate([
            detailCommentLabel.topAnchor.constraint(equalTo: detailImageView.bottomAnchor, constant: 10),
            detailCommentLabel.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 10),
            detailCommentLabel.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor, constant: -10)
        ])
        
        // detailDateLabelの設定
        detailDateLabel.textAlignment = .center
        detailDateLabel.translatesAutoresizingMaskIntoConstraints = false
        detailContentView.addSubview(detailDateLabel)
        NSLayoutConstraint.activate([
            detailDateLabel.topAnchor.constraint(equalTo: detailCommentLabel.bottomAnchor, constant: 10),
            detailDateLabel.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 10),
            detailDateLabel.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor, constant: -10),
            detailDateLabel.bottomAnchor.constraint(equalTo: detailContentView.bottomAnchor, constant: -10)
        ])
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
    
    @objc func closeDetailView() {
        detailContainerView.isHidden = true
    }
        
    func pickRandomStories() -> [Story] {
        let realm = try! Realm()  // Realmインスタンスを取得
        let stories = realm.objects(Story.self) // 全てのStoryを取得
        
        // ストーリーが2つ未満なら、そのまま返す
        guard stories.count >= 2 else { return Array(stories) }

        // シャッフルして2つだけ取得
        return Array(stories.shuffled().prefix(2))
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! ImageCell
        cell.configure(with: displayedStories[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        // 詳細情報をオーバーレイに反映
        
        //ストーリーをとってくる処理
        let story = displayedStories[indexPath.item]
        detailImageView.image = UIImage(data: story.imageData!)
        detailCommentLabel.text = story.text
        
        
        //イベントをとってくる処理
        //        do {
        //            let data = saveData.data(forKey: "stories")!
        //            // Event型の配列としてデコード
        //            let decodedEvents = try JSONDecoder().decode([Event].self, from: data)
        //            // indexPath.item に対応するイベントを取得
        //            let event = decodedEvents[indexPath.item]
        //
        //            // 日付を文字列に変換するためのフォーマッターを用意
        //            let formatter = DateFormatter()
        //            formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //            let dateString = formatter.string(from: event.pickedDate)
        //
        //            // detailDateLabelに設定
        //            detailDateLabel.text = dateString
        //        } catch {
        //            print("データ取得に失敗しました", error)
        //        }
        //
        //        if let savedDate = saveData.string(forKey: "selectedDate") {
        //            detailDateLabel.text = savedDate
        //        } else {
        //            detailDateLabel.text = getDate()
        //        }
        //        detailContainerView.isHidden = false
        //    }
        //}
        
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
            }()
            private let dateLabel: UILabel = {
                let label = UILabel()
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 14)
                label.numberOfLines = 2
                return label
            }()
            
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
                imageView.image = UIImage(data: story.imageData!)
                textLabel.text = story.text
            }
        }
    }
}

