//
// Created by p4rtiz4n on 20/12/2020.
//

import UIKit

protocol AssetsView: class {

    func update(with viewModel: AssetsViewModel)
    func update(with viewModel: AssetsViewModel, at idxPath: IndexPath)
}

// MARK: - DefaultAssetsView

class DefaultAssetsView: UITableViewController {

    private var viewModel: AssetsViewModel = .loading
    private let searchController = UISearchController(
        searchResultsController: nil
    )

    var presenter: AssetsPresenter! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search coins"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        presenter.present()
        setupRefreshControl()
        #if targetEnvironment(macCatalyst)
        navigationItem.largeTitleDisplayMode = .never
        #endif
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.handleEvent(.viewDidAppear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.handleEvent(.viewDidDisAppear)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsCount()
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch viewModel {
        case let .partialLoad(sections), let .loaded(sections):
            return sections[section].assets.count
        case .loading:
            return 0
        case .failedToLoad:
            return 1
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch viewModel {
        case .partialLoad, .loaded:
            return deque(idxPath: indexPath, viewModel: viewModel)
        case .loading:
            fatalError("No cells in loading state")
        case .failedToLoad:
            let cell = tableView.dequeue(AssetCell.self, for: indexPath)
            cell.titleLabel?.text = "Failed to load"
            return cell
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let favourite = UIContextualAction(
            style: .normal,
            title: nil,
            handler: { [weak self] (_, _, completion) in
                self?.presenter.handleEvent(.favourite(indexPath))
                completion(true)
            }
        )
        favourite.image = UIImage(systemName: "star.fill")
        favourite.backgroundColor = .systemYellow
     
        let config = UISwipeActionsConfiguration(actions: [favourite])
        return config
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections()[section].title
    }

    func deque(idxPath: IndexPath, viewModel: AssetsViewModel) -> AssetCell {
        let cell = tableView.dequeue(AssetCell.self, for: idxPath)
        if let asset = viewModel.asset(at: idxPath) {
            cell.update(with: asset)
        }
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 72
    }

    // MARK: - UITableViewDelegate

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        presenter.handleEvent(.didSelect(indexPath))
    }

    // MARK: - UIScrollViewDelegate

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        presenter.handleEvent(.didBeginScrolling)
    }

    override func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updatePresenterWithVisibleIndexPaths()
        }
    }

    override func scrollViewDidEndScrollingAnimation(
        _ scrollView: UIScrollView
    ) {
        updatePresenterWithVisibleIndexPaths()
    }

    // MARK: - Actions

    @IBAction func refreshAction(_ sender: Any) {
        presenter.handleEvent(.refreshAction)
    }

}

// MARK: - AssetsView

extension DefaultAssetsView: AssetsView {

    func update(with viewModel: AssetsViewModel) {
        self.viewModel = viewModel
        updateRefreshControl(viewModel)

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.updatePresenterWithVisibleIndexPaths()
        }

        tableView.beginUpdates()

        if tableView.numberOfSections > viewModel.sectionsCount() {
            tableView.deleteSections(
                IndexSet(viewModel.sectionsCount()..<tableView.numberOfSections),
                with: viewModel.sectionsCount() == 1 ? .fade :.automatic
            )
        }

        if viewModel.sectionsCount() > tableView.numberOfSections {
            tableView.insertSections(
                IndexSet(tableView.numberOfSections..<viewModel.sectionsCount()),
                with: viewModel.sectionsCount() == 2 ? .fade : .automatic
            )
        }

        tableView.reloadSections(
            IndexSet(0..<min(viewModel.sectionsCount(), tableView.numberOfSections)),
            with: viewModel.sectionsCount() == 1 ? .fade : .automatic
        )

        tableView.endUpdates()
        CATransaction.commit()
    }

    func update(with viewModel: AssetsViewModel, at idxPath: IndexPath) {
        self.viewModel = viewModel

        let visible = tableView.indexPathsForVisibleRows
        guard visible?.contains(idxPath) ?? false else {
            return
        }

        guard let asset = viewModel.asset(at: idxPath) else {
            return
        }

        (tableView.cellForRow(at: idxPath) as? AssetCell)?.update(with: asset)
    }
}

// MARK: - Utilities

extension DefaultAssetsView {

    func updatePresenterWithVisibleIndexPaths() {
        presenter.handleEvent(
            .didComeToRest(tableView.indexPathsForVisibleRows ?? [])
        )
    }
    
    func setupRefreshControl() {
        #if !targetEnvironment(macCatalyst)
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(
            string: " ↓ Refresh ↓ "
        )
        refreshControl?.addTarget(
            self,
            action: #selector(refreshAction(_:)),
            for: .valueChanged
        )
        #endif
    }

    func updateRefreshControl(_ viewModel: AssetsViewModel) {
        #if !targetEnvironment(macCatalyst)
        switch viewModel {
        case .loading, .partialLoad:
            if refreshControl?.isRefreshing ?? false {
                refreshControl?.beginRefreshing()
            }
        default:
            if refreshControl?.isRefreshing ?? false {
                refreshControl?.endRefreshing()
            }
        }
        #endif
    }
}

// MARK: - UISearchResultsUpdating

extension DefaultAssetsView: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let term = searchController.searchBar.text
        presenter.handleEvent(.search(term))
    }
}

// MARK: - AssetsTableViewController

private extension DefaultAssetsView {

    func handle(_ error: Error) {
        print(error)
    }
}

