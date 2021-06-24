pragma solidity >=0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Library is Ownable {
    using SafeMath for uint256;
    
    struct Book {
        string name;
        uint256 totalCopies;
        uint256 counter;
        mapping(uint256 => address) history;
    }

    struct BookNameAndId {
        string name;
        uint256 id;
    }

    uint256 public counter;

    mapping(string => bool) private isPresent;
    mapping(address => mapping (uint256=>bool)) private isAlreadyIssued;
    mapping(uint256 => Book) public BookLedger;
    
    modifier isBookPresent(string memory _name) {
        require(!isPresent[_name], "Book Already present");
        _;
    }

    

    function _getNextBookId() private view returns (uint256) {
        return counter.add(1);
    }
    
    function _increment() private {
        counter++;
    }

    function addBook(string memory _name, uint256 _copies) external onlyOwner isBookPresent(_name) {
        isPresent[_name] = true;
        uint256 _bookId = _getNextBookId();
        Book storage book = BookLedger[_bookId];
        book.name = _name;
        book.totalCopies = _copies;
        _increment();
    }

    function issueBooks(uint256 _id) external {
        require(!isAlreadyIssued[msg.sender][_id], "Book is already issued");
        Book storage book = BookLedger[_id];
        book.totalCopies -= 1;
        book.history[counter] = msg.sender;
        book.counter += 1;
    }

    function returnBook(uint256 _id) external {
        require(isAlreadyIssued[msg.sender][_id], "Book is not issued");
        Book storage book = BookLedger[_id];
        book.totalCopies += 1;
    }

    // function getAllAvailableBooks() external returns(BookNameAndId[]) {
    // }
}
