//
//  ProductViewModelTests.swift
//  NotInMyBreakfastTests
//
//  Created by Ishraq Mahid on 12/14/25.
//

import Foundation
import XCTest
import Combine
@testable import NotInMyBreakfast

final class ProductViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolMock.self)
        URLProtocolMock.reset()
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolMock.self)
        URLProtocolMock.reset()
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchProductSuccessSetsProduct() {
        let json = """
        {"code":"12345","product":{"product_name":"Cereal","ingredients_text":"Sugar","ingredients":[{"id":"1","text":"Sugar"}],"image_url":"https://example.com/img.jpg"}}
        """.data(using: .utf8)!
        URLProtocolMock.stubResponseData = json
        URLProtocolMock.stubStatusCode = 200

        let viewModel = ProductViewModel()
        let exp = expectation(description: "Product decoded")

        viewModel.fetchProduct(barcode: "12345")

        viewModel.$product
            .dropFirst()
            .sink { product in
                if let product = product {
                    XCTAssertEqual(product.productName, "Cereal")
                    XCTAssertNil(viewModel.errorMessage)
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }

    func testFetchProductHandlesNotFoundError() {
        URLProtocolMock.stubResponseData = Data()
        URLProtocolMock.stubStatusCode = 404

        let viewModel = ProductViewModel()
        let exp = expectation(description: "Error surfaced")

        viewModel.fetchProduct(barcode: "99999")

        viewModel.$errorMessage
            .dropFirst()
            .sink { message in
                if let message = message {
                    XCTAssertTrue(message.contains("not found") || message.contains("Barcode"))
                    XCTAssertNil(viewModel.product)
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 2)
    }
}

final class URLProtocolMock: URLProtocol {
    static var stubResponseData: Data?
    static var stubStatusCode: Int = 200
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let error = URLProtocolMock.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://example.com")!,
            statusCode: URLProtocolMock.stubStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = URLProtocolMock.stubResponseData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        stubResponseData = nil
        stubStatusCode = 200
        error = nil
    }
}
