//
//  ItemAdder.swift
//  merchant-app
//
//  Created by Aashish Thoutam on 6/27/20.
//  Copyright © 2020 Aashish Thoutam. All rights reserved.
//

import SwiftUI
import CarBode
import Alamofire
import SDWebImageSwiftUI

struct ItemAdder: View {
    
    @Binding var items: [Item]
    @Binding var sheetOption: sheetOption?
    @Binding var showSheet: Bool
    
    @State var barcode: String?
    
    @State var itemName: String = ""
    @State var itemPrice: String = ""
    @State var itemDescription: String = ""
    
    @State var loading = false
    @State var loadingMessage = ""
    
    @State var imageURL: String = ""
    @State var itemImage: UIImage?
    @State var showImagePicker = false
    
    var body: some View {
        ZStack {
            VStack {
                if sheetOption == .barcode {
                    ZStack {
                        CBScanner(supportBarcode: [.ean13])
                            .interval(delay: 50.0) //Event will trigger every 5 seconds
                            .found{
                                
                                self.loadingMessage = "Predicting Product Data ..."
                                self.loading = true
                                
                                print($0)
                                self.barcode = $0
                                
                                let url = "https://b7d42b2bc448.ngrok.io/productData"
                                let parameters: Parameters = [
                                    "barcode": self.barcode!
                                ]
                                
                                AF.request(url, method: .post, parameters: parameters).responseJSON { response in
                                    switch response.result {
                                    case .success(let jsonData):
                                        self.loading = false
                                        
                                        let response = jsonData as! NSDictionary
                                        let newItem = Item(name: response["name"] as! String, description: response["description"] as! String, price: (response["price"] as! NSString).doubleValue, imageURL: response["imageURL"] as! String)
                                        
                                        print(newItem)
                                        self.itemName = newItem.name
                                        self.itemPrice = String(newItem.price)
                                        self.imageURL = newItem.imageURL
                                        self.itemDescription = newItem.description
                                        
                                        self.sheetOption = .custom
                                    case .failure(let err):
                                        print(err)
                                    }
                                }
                                
                        }
                        // .simulator(mockBarCode: "MOCK BARCODE DATA 1234567890")
                        VStack {
                            Text("Please point the camera at the barcode")
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 15)
                            Spacer()
                        }
                    }
                } else if sheetOption == .custom {
                    ScrollView {
                        
                        ZStack(alignment: .bottomTrailing) {
                            
                            if self.imageURL != "" {
                                WebImage(url: URL(string: self.imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.height * 0.5 )
                                .cornerRadius(15)
                            }
                            else if self.itemImage == nil {
                                Image("placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .cornerRadius(15)
                            } else {
                                Image(uiImage: self.itemImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                                    .cornerRadius(15)
                            }
                            
                            Button(action: {
                                self.showImagePicker = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 25))
                                    .padding([.trailing, .bottom], 10)
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(sourceType: .photoLibrary) { (image) in
                                    self.itemImage = image
                                }
                            }
                        }
                        
                        VStack(spacing: 25) {
                            TextField("Name", text: $itemName)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                            TextField("Price", text: $itemPrice)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 5)
                                .keyboardType(.decimalPad)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                            MultilineTextField("Description", text: $itemDescription) {
                                //
                            }
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                        }
                        .padding(.top, 10)
                        
                        Button(action: {
                            if self.itemName.trimmingCharacters(in: .whitespaces) == "" || self.itemPrice.trimmingCharacters(in: .whitespaces) == "" || self.itemDescription.trimmingCharacters(in: .whitespaces) == "" {
                                print("Missing something")
                            } else {
                                let newItem = Item(name: self.itemName, description: self.itemDescription, price: (self.itemPrice as NSString).doubleValue, imageURL: self.imageURL)
                                print(newItem)
                            }
                        }) {
                            Text("Add item")
                        }
                        .padding(.top, 30)
                        
                        Button(action: {
                            self.showSheet = false
                        }) {
                            Text("Cancel")
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            if self.loading {
                VStack(spacing: 15) {
                    LottieView(filename: "loading")
                    .frame(width: 80, height: 80)
                    Text(self.loadingMessage)
                }
                .padding()
                .background(Color(red: 236/255, green: 240/255, blue: 241/255))
                .cornerRadius(25)
                .offset(y: -40)
                
            }
        }
            
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}




struct ItemAdder_Previews: PreviewProvider {
    static var previews: some View {
        ItemAdder(items: .constant([]), sheetOption: .constant(.custom), showSheet: .constant(false))
    }
}
