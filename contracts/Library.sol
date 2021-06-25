pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Library is Ownable {
    using SafeMath for uint256;

    struct Book {
        string name;
        uint256 availableCopies;
        uint256 counter;
        mapping(uint256 => address) history;
    }

    Book myBook;

    uint256 public counter;

    mapping(string => bool) private isPresent;
    mapping(address => mapping(uint256 => bool)) private isAlreadyIssued;
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

    function addBook(string memory _name, uint256 _copies)
        external
        onlyOwner
        isBookPresent(_name)
    {
        isPresent[_name] = true;
        uint256 _bookId = _getNextBookId();
        Book storage book = BookLedger[_bookId];
        book.name = _name;
        book.availableCopies = _copies;
        _increment();
    }

    function borrowBook(uint256 _id) external {
        require(!isAlreadyIssued[msg.sender][_id], "Book is already issued");
        isAlreadyIssued[msg.sender][_id] = true;
        Book storage book = BookLedger[_id];
        require(book.availableCopies.sub(1) >= 0);
        book.availableCopies -= 1;
        book.history[book.counter] = msg.sender;
        book.counter += 1;
    }

    function returnBook(uint256 _id) external {
        require(isAlreadyIssued[msg.sender][_id], "Book is not issued");
        Book storage book = BookLedger[_id];
        book.availableCopies += 1;
        isAlreadyIssued[msg.sender][_id] = false;
    }

    function getAllAvailableBooks() external view returns (uint256[] memory) {
        uint256 currentIndex = 0;
        for (uint256 index = 1; index <= counter; index++) {
            if (!isAlreadyIssued[msg.sender][index] && BookLedger[index].availableCopies > 0) {
                currentIndex++;
            }
        }
        uint256[] memory result = new uint256[](currentIndex);
        currentIndex = 0;
        for (uint256 index = 1; index <= counter; index++) {
            if (!isAlreadyIssued[msg.sender][index] && BookLedger[index].availableCopies > 0) {
                result[currentIndex] = index;
                currentIndex++;
            }
        }
        return result;
    }

    function getBorrowHistoryOfBook(uint256 _id)
        public
        view
        returns (address[] memory)
    {
        address[] memory result = new address[](BookLedger[_id].counter);
        for (uint256 index = 0; index < result.length; index++) {
            result[index] = BookLedger[_id].history[index];
        }
        return result;
    }

    function getBookDetail(uint256 _id)
        public
        view
        returns (string memory, uint256)
    {
        require(isPresent[BookLedger[_id].name]);
        return (BookLedger[_id].name, BookLedger[_id].availableCopies);

    }
}
