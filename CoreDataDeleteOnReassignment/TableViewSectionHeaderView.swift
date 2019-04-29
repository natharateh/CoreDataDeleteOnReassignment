import UIKit

class TableViewSectionHeaderView: UIView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var replaceButton: UIButton!

    class func instanceFromNib() -> TableViewSectionHeaderView {
        return UINib(nibName: "TableViewSectionHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TableViewSectionHeaderView
    }

    private var deleteAction: (() -> Void)? = nil
    private var replaceAction: (() -> Void)? = nil

    func configure(with sectionName: String, deleteAction: @escaping () -> Void, replaceAction: @escaping () -> Void) {
        label.text = sectionName.uppercased()
        self.deleteAction = deleteAction
        self.replaceAction = replaceAction
    }

    @IBAction private func performDeleteAction(_ sender: UIButton) {
        deleteAction?()
    }

    @IBAction private func performReplaceAction(_ sender: UIButton) {
        replaceAction?()
    }
}
