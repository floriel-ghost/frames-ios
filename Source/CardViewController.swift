import Foundation

public class CardViewController: UIViewController, AddressViewControllerDelegate {

    let cardUtils = CardUtils()

    let stackView = UIStackView()
    let schemeIconsView = UIStackView()
    let acceptedCardLabel = UILabel()
    let cardNumberInputView = CardNumberInputView()
    let cardHolderNameInputView = StandardInputView()
    let expirationDateInputView = ExpirationDateInputView()
    let cvvInputView = StandardInputView()
    let billingDetailsInputView = DetailsInputView()

    let addressViewController = AddressViewController()
    let addressTapGesture = UITapGestureRecognizer()

    let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                                     target: self, action: nil)

    var availableSchemes: [CardScheme] = [.visa, .mastercard, .americanExpress, .dinersClub]

    /// Delegate
    public weak var delegate: CardViewControllerDelegate?

    /// Called after the controller's view is loaded into memory.
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUIViews()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(onTapDoneCardButton))
        // add gesture recognizer
        addressTapGesture.addTarget(self, action: #selector(onTapAddressView))
        billingDetailsInputView.addGestureRecognizer(addressTapGesture)

        addressViewController.delegate = self

        // add views
        stackView.addArrangedSubview(cardNumberInputView)
        stackView.addArrangedSubview(cardHolderNameInputView)
        stackView.addArrangedSubview(expirationDateInputView)
        stackView.addArrangedSubview(cvvInputView)
        stackView.addArrangedSubview(billingDetailsInputView)
        self.view.addSubview(acceptedCardLabel)
        self.view.addSubview(schemeIconsView)
        self.view.addSubview(stackView)

        // add constraints
        setupConstraints()

        // add schemes icons
        availableSchemes.forEach { scheme in
            self.addSchemeIcon(scheme: scheme)
        }
        self.addFillerView()

        addKeyboardToolbarNavigation(textFields: [
            cardNumberInputView.textField!,
            cardHolderNameInputView.textField!,
            expirationDateInputView.textField!,
            cvvInputView.textField!
            ])
    }

    @objc func onTapAddressView() {
        navigationController?.pushViewController(addressViewController, animated: true)
    }

    @objc func onTapDoneCardButton() {
        // Get the values
        guard
            let cardNumber = cardNumberInputView.textField!.text,
            let expirationDate = expirationDateInputView.textField!.text,
            let cvv = cvvInputView.textField!.text
            else { return }
        let cardNumberStandardized = cardUtils.standardize(cardNumber: cardNumber)
        // Validate the values
        guard
            let cardType = cardUtils.getTypeOf(cardNumber: cardNumberStandardized)
            else { return }
        let (expiryMonth, expiryYear) = cardUtils.standardize(expirationDate: expirationDate)
        guard
            cardUtils.isValid(cardNumber: cardNumberStandardized, cardType: cardType),
            cardUtils.isValid(expirationMonth: expiryMonth, expirationYear: expiryYear),
            cardUtils.isValid(cvv: cvv, cardType: cardType)
            else { return }

        let card = CardRequest(number: cardNumberStandardized, expiryMonth: expiryMonth, expiryYear: expiryYear,
                               cvv: cvv, name: cardHolderNameInputView.textField!.text)
        self.delegate?.onTapDone(card: card)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - AddressViewControllerDelegate

    /// Executed when an user tap on the done button.
    public func onTapDoneButton(address: Address) {
        let value = "\(address.addressLine1 ?? ""), \(address.addressLine2 ?? ""), \(address.city ?? "")"
        billingDetailsInputView.value?.text = value
    }

    private func setupUIViews() {
        acceptedCardLabel.text = "Accepted Cards"
        cardNumberInputView.set(label: "cardNumber", backgroundColor: .white)
        cardHolderNameInputView.set(label: "cardholderName", backgroundColor: .white)
        expirationDateInputView.set(label: "expirationDate", backgroundColor: .white)
        cvvInputView.set(label: "cvv", backgroundColor: .white)
        billingDetailsInputView.set(label: "billingDetails", backgroundColor: .white)
        cardNumberInputView.textField?.placeholder = "4242"
        expirationDateInputView.textField?.placeholder = "06/2020"
        cvvInputView.textField?.placeholder = "100"

        self.view.backgroundColor = UIColor.groupTableViewBackground
        schemeIconsView.spacing = 8
        stackView.axis = .vertical
        stackView.spacing = 16
    }

    private func setupConstraints() {
        acceptedCardLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptedCardLabel.trailingAnchor
            .constraint(equalTo: self.view.safeTrailingAnchor, constant: -16)
            .isActive = true
        acceptedCardLabel.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: 16).isActive = true
        acceptedCardLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true

        schemeIconsView.translatesAutoresizingMaskIntoConstraints = false
        schemeIconsView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -16).isActive = true
        schemeIconsView.topAnchor.constraint(equalTo: acceptedCardLabel.bottomAnchor, constant: 16).isActive = true
        schemeIconsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: self.schemeIconsView.bottomAnchor, constant: 16).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 16).isActive = true
    }

    private func addSchemeIcon(scheme: CardScheme) {
        let imageView = UIImageView()
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let image = UIImage(named: "schemes/icon-\(scheme.rawValue)", in: Bundle(for: CardViewController.self),
                compatibleWith: nil)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false

        schemeIconsView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }

    private func addFillerView() {
        let fillerView = UIView()
        fillerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        fillerView.backgroundColor = .clear
        fillerView.translatesAutoresizingMaskIntoConstraints = false
        schemeIconsView.addArrangedSubview(fillerView)
    }

}