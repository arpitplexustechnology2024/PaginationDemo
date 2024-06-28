//
//  ViewController.swift
//  PaginationDemo
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

import UIKit
import Alamofire

class QuotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private let footerActivityIndicator = UIActivityIndicatorView(style: .medium)
    private let viewModel = QuotesViewModel()
    private let noInternetView = NoInternetView()
    var noDataView: NoDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNoDataView()
        setupReachability()
        fetchQuotes()
    }
    
    func setupNoDataView() {
        noDataView = NoDataView()
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataView)
        
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: view.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        noDataView.isHidden = true
    }
    
    private func setupUI() {
        setupTableViewFooter()
        
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noInternetView)
        
        NSLayoutConstraint.activate([
            noInternetView.topAnchor.constraint(equalTo: view.topAnchor),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        noInternetView.isHidden = true
        noInternetView.retryButton.addTarget(self, action: #selector(retryFetchingQuotes), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupTableViewFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        footerActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(footerActivityIndicator)
        
        NSLayoutConstraint.activate([
            footerActivityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            footerActivityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        tableView.tableFooterView = footerView
    }
    
    private func fetchQuotes() {
        footerActivityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.footerActivityIndicator.stopAnimating()
        }
        
        viewModel.fetchQuotes { [weak self] success, error in
            guard let self = self else { return }
            if success {
                self.tableView.reloadData()
            } else if let error = error {
                self.showNoDataView()
            }
        }
    }
    
    private func setupReachability() {
        let reachability = NetworkReachabilityManager()
        
        reachability?.startListening(onQueue: .main, onUpdatePerforming: { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .reachable(_), .unknown:
                self.noInternetView.isHidden = true
                self.fetchQuotes()
            case .notReachable:
                self.noInternetView.isHidden = false
            }
        })
    }
    
    @objc private func retryFetchingQuotes() {
        if let reachability = NetworkReachabilityManager(), reachability.isReachable {
            noInternetView.isHidden = true
            fetchQuotes()
        } else {
            let alert = UIAlertController(title: "Error", message: "No Internet Connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func showNoDataView() {
        noDataView.isHidden = false
        tableView.isHidden = true
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteTableViewCell", for: indexPath) as? QuoteTableViewCell else {
            return UITableViewCell()
        }
        let quote = viewModel.quotes[indexPath.row]
        cell.contentLabel.text = "\"\(quote.content)\""
        cell.authorLabel.text = "- \(quote.author)"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.quotes.count - 1 {
            footerActivityIndicator.startAnimating()
            fetchQuotes()
        }
    }
}
