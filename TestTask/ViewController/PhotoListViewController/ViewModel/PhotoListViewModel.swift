import Foundation
import CustomPhotosFramework

class PhotoListViewModel {
    fileprivate var allPhotos: [PhotoModel] = []
    fileprivate var searchPhotos: [PhotoModel] = []
    fileprivate var pageForAllPhotos: Int = 1
    fileprivate var pageForSearchPhotos: Int = 1
    fileprivate var maxPageCount: Int = 10
    fileprivate var canLoadMorePhotos: Bool {
        return (isSearchMode ? pageForSearchPhotos : pageForAllPhotos) <= maxPageCount
    }

    private let networkManager = PhotosNetworkManager()

    var photosDidChangeHandler: (() -> Void)?

    var photos: [PhotoModel] {
        return isSearchMode ? searchPhotos : allPhotos
    }

    var query: String = "" {
        didSet { pageForSearchPhotos = 1 }
    }
    
    var isSearchMode = false {
        didSet {
            pageForSearchPhotos = 1
            searchPhotos = []
            photosDidChangeHandler?()
        }
    }

    // MARK: - Methods
    
    func loadMorePhotos() {
        isSearchMode ? searchPhotos(isLoadingMore: true) : loadPhotos(isLoadingMore: true)
    }
    
    func deleteSearchedPhoto(at index: Int) {
        searchPhotos.remove(at: index)
        photosDidChangeHandler?()
    }

    // MARK: Networking

    func loadPhotos(isLoadingMore: Bool = false) {
        if isLoadingMore && !canLoadMorePhotos { return }
        let pageForLoading = isLoadingMore ? pageForAllPhotos + 1 : pageForAllPhotos
        networkManager.getPhotos(page: pageForLoading) { [weak self] (result) in
              guard let strongSelf = self else { return }
              switch result {
              case .success(let photos):
                  strongSelf.allPhotos = strongSelf.allPhotos + photos
                  strongSelf.pageForAllPhotos = pageForLoading
                  strongSelf.photosDidChangeHandler?()
              case .failure(let error):
                  print(error.localized())
              }
          }
      }
    
    func searchPhotos(isLoadingMore: Bool = false) {
        if isLoadingMore && !canLoadMorePhotos { return }
        let pageForLoading = isLoadingMore ? pageForSearchPhotos + 1 : pageForSearchPhotos
        networkManager.searchPhotos(query: query, page: pageForLoading) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let response):
                strongSelf.searchPhotos = strongSelf.searchPhotos + response.results
                strongSelf.pageForSearchPhotos = pageForLoading
                strongSelf.photosDidChangeHandler?()
            case .failure(let error):
                print(error.localized())
            }
        }
    }
    
}
