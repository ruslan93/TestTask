import UIKit
import Kingfisher
import CustomPhotosFramework

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var deleteButton: UIButton!

    var deleteHandler: (() -> Void)?
    
    var isDeletionEnabled: Bool = false {
        didSet {
            deleteButton.isHidden = !isDeletionEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.kf.indicatorType = .activity
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        deleteHandler?()
    }
    
    func configure(for photo: PhotoModel) {
        if let url = URL(string: photo.urls.thumb) {
            photoImageView.kf.setImage(with: url)
        }
    }
    
}
