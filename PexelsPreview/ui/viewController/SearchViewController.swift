//
//  SearchViewController.swift
//  PexelsPreview
//
//  Created by tatsuki on 2024/02/27.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var searchResult: UICollectionView! {
        didSet {
            searchResult.register(UINib(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: "SearchCell")
        }
    }
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    
    private var viewModel = SearchViewModel()
    
    private var selectedItem: SearchItemViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 文字色を白に設定
        searchText.searchTextField.textColor = .white
        
        // 検索イベント
        searchText.rx.searchButtonClicked.subscribe({ event in
            self.searchText.resignFirstResponder()
            self.viewModel.load(query: self.searchText.text ?? "")
        }).disposed(by: disposeBag)
        
        // アイテム押下イベント
        searchResult.rx.itemSelected.subscribe(onNext: { [unowned self] indexPath in
            self.searchResult.deselectItem(at: indexPath, animated: true)
            // PreviewDialogを表示
            self.selectedItem = self.viewModel.searchResults.value[indexPath.row]
            self.performSegue(withIdentifier: "ShowPreview", sender: nil)
        })
        
        // ページング処理
        searchResult.rx.contentOffset.asDriver()
            .map { _ in self.shouldRequestNextPage() }
            .distinctUntilChanged()
            .filter { $0 }
            .drive(onNext: { _ in self.viewModel.loadMore() })
            .disposed(by: disposeBag)
        
        // データバインディング
        viewModel.searchResults.bind(to: searchResult.rx.items(cellIdentifier: "SearchCell", cellType: SearchCell.self)) { row, element, cell in
            // セルではsmallの画像を表示
            cell.setData(thumbnailUrl: element.small, photographerName: element.photographer)
        }.disposed(by: disposeBag)
        
        // デリゲートの設定
        searchResult.rx.setDelegate(self).disposed(by: disposeBag)
        
        // indicatorの設定
        viewModel.isLoading.asDriver()
            .drive(indicator.rx.isAnimating)
            .disposed(by: disposeBag)
        viewModel.isLoading.asDriver()
            .map { !$0 }
            .drive(indicator.rx.isHidden)
            .disposed(by: disposeBag)
    
        viewModel.errorMessage.observe(on: MainScheduler.instance)
            .subscribe({ message in
            print("showAlert")
            let dialog = UIAlertController(title: "エラー", message: message.element, preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPreview" {
            // プレビューダイアログではmediumの画像を表示
            let url = selectedItem?.medium
            let photographer = selectedItem?.photographer
            let previewDialog = segue.destination as? PreviewDialogViewController
            previewDialog?.url = url
            previewDialog?.photographerName = photographer
        }
    }

    private func shouldRequestNextPage() -> Bool {
        return searchResult.contentSize.height > 0 && searchResult.isNearBottomEdge()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = (width - 30) / 3
        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
}
