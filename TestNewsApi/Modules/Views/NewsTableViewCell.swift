//
//  NewsTableViewCell.swift
//  TestNewsApi
//
//  Created by Alina Protsiuk on 15.12.2020.
//

import UIKit
import RxSwift

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var publishedTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    let kImageHeight: CGFloat = 50.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsImageView.image = nil
        imageViewHeightConstraint.constant = 70
    }
    
    func setup(_ article: Article) {
        publishedTimeLabel.text = article.publishedAt?.toDate()?.timeStringDate
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        authorLabel.text = article.author
        
        if let stringURL = article.urlToImage,
           let url = URL(string: stringURL) {
            downloadImage(url: URLRequest(url: url))
                .observeOn(MainScheduler.instance)
                .subscribe { [weak self] (image) in
                    self?.newsImageView.image = image
                    self?.activityIndicator.stopAnimating()
                } onError: { [weak self] (_) in
                    self?.activityIndicator.stopAnimating()
                    self?.imageViewHeightConstraint.constant = 0
                }
                .disposed(by: disposeBag)
        } else {
            imageViewHeightConstraint.constant = 0
        }
    }
    
    private func downloadImage(url: URLRequest) -> Observable<UIImage?> {
        return URLSession.shared.rx
            .data(request: url)
            .map { data in UIImage(data: data) }
            .catchErrorJustReturn(nil)
    }
}
