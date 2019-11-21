import UIKit
import SKPhotoBrowser

final class PhotoListViewController: UIViewController {
    @IBOutlet private weak var photosCollectionView: UICollectionView!
    
    fileprivate var searchController: UISearchController!
    
    private var viewModel = PhotoListViewModel()

    fileprivate var itemsInRow: Int {
        return viewModel.isSearchMode ? 1 : 3
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.loadPhotos()
    }
    
    // MARK: - Methods
    // MARK: Setup

    private func setupViewModel() {
        viewModel.photosDidChangeHandler = { [weak self] in
            self?.photosCollectionView.reloadData()
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Photos"
        setupSearchController()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        photosCollectionView.register(nibWithCellClass: PhotoCollectionViewCell.self)
        photosCollectionView.keyboardDismissMode = .onDrag
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(inset: 8)
        }
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search photos"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }

}

// MARK: - UICollectionViewDataSource

extension PhotoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: PhotoCollectionViewCell.self, for: indexPath)
        cell.configure(for: viewModel.photos[indexPath.item])
        cell.isDeletionEnabled = viewModel.isSearchMode
        cell.deleteHandler = { [weak self] in
            self?.viewModel.deleteSearchedPhoto(at: indexPath.item)
            self?.photosCollectionView.reloadData()
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension PhotoListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images = viewModel.photos.map({ SKPhoto.photoWithImageURL($0.urls.full) })
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(indexPath.item)
        present(browser, animated: true, completion: {})
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.photos.count - 1 {
            viewModel.loadMorePhotos()
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.width
        let insetsForSection = 8 + 8
        let insetsBetweenItems = (itemsInRow - 1) * 8
        let totalInsets = insetsForSection + insetsBetweenItems
        let width = (totalWidth - totalInsets.cgFloat) / itemsInRow.cgFloat
        return CGSize(width: width, height: width)
    }
}

// MARK: - UISearchResultsUpdating

extension PhotoListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, query.count > 3 else { return }
        viewModel.query = query
        viewModel.searchPhotos()
    }
        
}

// MARK: - UISearchControllerDelegate

extension PhotoListViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        viewModel.isSearchMode = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.isSearchMode = false
    }
    
}
