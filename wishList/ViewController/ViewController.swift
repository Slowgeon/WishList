//
//  ViewController.swift
//  wishList
//
//  Created by t2023-m0074 on 4/9/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    // currentProduct set될때 imageView, titleLabel, descriptionLabel, priceLabel에 적절한 값 지정
    private var currentProduct: RemoteProduct? = nil {
        didSet {
            guard let currentProduct = self.currentProduct else { return }
            
            DispatchQueue.main.async {
                self.imageView.image = nil
                self.titleLabel.text = currentProduct.title
                self.descriptionLabel.text = currentProduct.description
                self.priceLabel.text = "\(currentProduct.price)$"
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let data = try? Data(contentsOf: currentProduct.thumbnail), let image = UIImage(data: data) {
                    DispatchQueue.main.async { self?.imageView.image = image }
                }
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchRemoteProduct()
    }
    
    
    // 다른 상품 보기 버튼 클릭시 호출되는 IBAction
    @IBAction func tappedSkipButton(_ sender: UIButton) {
        self.fetchRemoteProduct() // 새로운 상품을 불러오는 함수 호출
    }
    
    // 위시리스트 담기 버튼 클릭 시 호출되는 IBAction
    @IBAction func tappedSaveProductButton(_ sender: UIButton) {
        self.saveWishProduct() // CoreData에 상품을 저장하는 함수 호출
    }
    
    // 위시 리스트 보기 버튼 클릭 시 호출되는 IBAction
    @IBAction func tappedPresentWishList(_ sender: UIButton) {
   
        guard let nextVC = self.storyboard?
            .instantiateViewController(
                identifier: "WishListViewController"
            ) as? WishListViewController else { return }
        
        self.present(nextVC, animated: true)
    }
    
    
    private func fetchRemoteProduct() { // 서버에서 데이터 가져오기
        let productID = Int.random(in: 1 ... 100)
        
        
        if let url = URL(string: "https://dummyjson.com/products/\(productID)") {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        let product = try JSONDecoder().decode(RemoteProduct.self, from: data)
                        self.currentProduct = product
                    } catch {
                        print("Decode Error: \(error)")
                    }
                }
            }
            
            task.resume()
        }
    }
    private func saveWishProduct() {
        guard let context = self.persistentContainer?.viewContext else { return }
        
        guard let currentProduct = self.currentProduct else { return }
        
        let wishProduct = Product(context: context)
        
        wishProduct.id = Int64(currentProduct.id)
        wishProduct.title = currentProduct.title
        wishProduct.price = currentProduct.price
        
        try? context.save()
    }
}



