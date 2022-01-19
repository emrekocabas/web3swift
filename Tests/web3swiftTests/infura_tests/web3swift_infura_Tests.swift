//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest

@testable import web3swift
import BigInt

// MARK: Works only with network connection
class web3swift_infura_Tests: XCTestCase {
    
    func testGetBalance() throws {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let balance = try web3.eth.getBalance(address: address)
            let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
            print(balString!)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByHash() throws {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let result = try web3.eth.getBlockByHash("0x6d05ba24da6b7a1af22dc6cc2a1fe42f58b2a5ea4c406b19c8cf672ed8ec0695", fullTransactions: true)
            print(result)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByNumber1() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = try web3.eth.getBlockByNumber("latest", fullTransactions: true)
        print(result)
    }
    
    func testGetBlockByNumber2() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = try web3.eth.getBlockByNumber(UInt64(5184323), fullTransactions: true)
        print(result)
        let transactions = result.transactions
        for transaction in transactions {
            switch transaction {
            case .transaction(let tx):
                print(String(describing: tx))
            default:
                break
            }
        }
    }
    
    func testGetBlockByNumber3() throws {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let _ = try web3.eth.getBlockByNumber(UInt64(1000000000), fullTransactions: true)
            XCTFail()
        } catch {
            
        }
    }
    
    func testGasPrice() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = try web3.eth.getGasPrice()
        print(response)
    }
    
    func testGetIndexedEventsPromise() throws {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
        var filter = EventFilter()
        filter.fromBlock = .blockNumber(UInt64(5200120))
        filter.toBlock = .blockNumber(UInt64(5200120))
        filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
        filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), (nil as [EventFilterable]?)]
        let eventParserResult = try contract!.getIndexedEventsPromise(eventName: "Transfer", filter: filter, joinWithReceipts: true).wait()
        print(eventParserResult)
        XCTAssert(eventParserResult.count == 2)
        XCTAssert(eventParserResult[0].transactionReceipt != nil)
        XCTAssert(eventParserResult[0].eventLog != nil)
    }
    
    func testEventParsingBlockByNumberPromise() throws {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
        var filter = EventFilter()
        filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
        filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), ([EthereumAddress("0xd5395c132c791a7f46fa8fc27f0ab6bacd824484")!] as [EventFilterable])]
        guard let eventParser = contract?.createEventParser("Transfer", filter: filter) else {return XCTFail()}
        let present = try eventParser.parseBlockByNumberPromise(UInt64(5200120)).wait()
        print(present)
        XCTAssert(present.count == 1)
    }
    
    func testUserCaseEventParsing() throws {
        let contractAddress = EthereumAddress("0x7ff546aaccd379d2d1f241e1d29cdd61d4d50778")
        let jsonString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_id\",\"type\":\"string\"}],\"name\":\"deposit\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_id\",\"type\":\"string\"},{\"indexed\":true,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"}]"
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Deposit", filter: nil) else {return XCTFail()}
        let pres = try eventParser.parseBlockByNumber(UInt64(2138657))
        XCTAssert(pres.count == 1)
    }
    
    
    func testSendTransactionWithEip1559() throws {
        do {
            guard let keystore = try? EthereumKeystoreV3(privateKey: Data(hex: "55d86c90105fb928ad61c817aa34902b7070868086ba48c30b7d56852fdd6346"), password: "qqqqqqqq", aesMode: "aes-128-ctr") else { return XCTFail() }
            let web3 = Web3.InfuraRinkebyWeb3()
            web3.addKeystoreManager(KeystoreManager([keystore]))
            let to = EthereumAddress("0xa3Fb93979c22766666F8105534295A1Feaee61a3")!
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: to, abiVersion: 2)!
            var options = TransactionOptions.defaultEIP1559Options
//            options.nonce = .pending
//            options.value = Web3.Utils.parseToBigUInt("0.001", units: .eth)
            options.from = keystore.addresses?.first
//            options.gasLimit = .manual(BigUInt(321000))
//            options.transactionType = .EIP1559
//            options.maxFeePerGas = .manual(.zero)
            options.maxFeePerGas = .manual(Web3.Utils.parseToBigUInt("5.000000131 ", units: .Gwei)!)
//            options.maxPriorityFeePerGas = .manual(.zero)
            options.maxPriorityFeePerGas = .manual(Web3.Utils.parseToBigUInt("1.0", units: .Gwei)!)
            let intermediate = try web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress("0xc7ad46e0b8a400bb3c915120d284aafba8fc4735")!, from: EthereumAddress("0x6d8e3Af13A7684973db63BA84dfFe42820774aa4")!, to: to, amount: "1", transactionOptions: options)
//            let intermediate = web3.eth.sendETH(to: to, amount: "0.0001")
//            let intermediate = contract.method("fallback", transactionOptions: options)
            guard let result = try intermediate?.send(password: "qqqqqqqq", transactionOptions: options) else { return XCTFail() }
            print("hash = \(result.hash)")
        } catch {
            print("error = \(error)")
        }
    }
    
    func testgetTransactionReceiptWithEip1559() throws {
        do {
            let web3 = Web3.InfuraRinkebyWeb3()
            let receipt = try web3.eth.getTransactionReceipt("0xdddca1e6beb45c91de95d2134dd74ab94594a5b2f241941a4ef2f07399f6bc81")
            print("hash = \(receipt)")
        } catch {
            XCTFail()
        }
    }
    
    func testgetTransactionDetailsWithEip1559() throws {
        do {
            let web3 = Web3.InfuraRinkebyWeb3()
            
            let number = try web3.eth.getBlockNumber()
            let block = try web3.eth.getBlockByNumber(number)
            print("block = \(block.baseFeePerGas.description)")
            
            let details = try web3.eth.getTransactionDetails("0xdddca1e6beb45c91de95d2134dd74ab94594a5b2f241941a4ef2f07399f6bc81")
            print("hash = \(details.transaction.sender?.address)")
        } catch {
            XCTFail()
        }
    }
    
}
