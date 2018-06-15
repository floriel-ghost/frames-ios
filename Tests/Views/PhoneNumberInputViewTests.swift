import XCTest
@testable import CheckoutSdkIos

class PhoneNumberInputViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCoderInitialization() {
        let coder = NSKeyedUnarchiver(forReadingWith: Data())
        let phoneNumberInputView = PhoneNumberInputView(coder: coder)
        XCTAssertNotNil(phoneNumberInputView)
        XCTAssertEqual(phoneNumberInputView?.textField.allTargets.count, 1)
    }

    func testFrameInitialization() {
        let phoneNumberInputView = PhoneNumberInputView(frame: CGRect(x: 0, y: 0, width: 400, height: 48))
        XCTAssertEqual(phoneNumberInputView.textField.allTargets.count, 1)
    }

    func testInvalidPhoneNumber() {
        let phoneNumberInputView = PhoneNumberInputView()
        phoneNumberInputView.textField.text = "hello world"
        XCTAssertFalse(phoneNumberInputView.isValidNumber)
    }

    func testTexFieldDidChange() {
        let phoneNumberInputView = PhoneNumberInputView()
        phoneNumberInputView.textField.text = "+33622545688"
        phoneNumberInputView.textFieldDidChange(textField: phoneNumberInputView.textField)
        XCTAssertEqual(phoneNumberInputView.textField.text, "+33 6 22 54 56 88")
    }

    func testTextFieldDidChangeWithInvalidNumber() {
        let phoneNumberInputView = PhoneNumberInputView()
        phoneNumberInputView.textField.text = "hello world"
        phoneNumberInputView.textFieldDidChange(textField: phoneNumberInputView.textField)
        XCTAssertEqual(phoneNumberInputView.textField.text, "hello world")
    }
}