//
//  DetailViewController.swift
//  flashback
//
//  Created by 井上　希稟 on 2025/01/25.
//

import UIKit

class DetailViewController: UIViewController {
    
    var story: Story?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textlabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        if let story = story {
            imageView.image = UIImage(data: story.imageData)
            textlabel.text = story.text
        }        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(textlabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            
            textlabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            textlabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textlabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
