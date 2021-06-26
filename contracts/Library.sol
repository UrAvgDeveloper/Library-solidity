// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Library is Ownable {
    using SafeMath for uint256;

    struct Book {
        string name;
        uint256 availableCopies;
        uint256 ownerCount;
        mapping(uint256 => address) ownersHistory;
    }

    Book myBook;

    uint256 public bookCount;

    mapping(string => bool) private isPresent;
    mapping(address => mapping(uint256 => bool)) private isAlreadyIssued;
    mapping(uint256 => Book) public BookLedger;

    modifier bookNotPresent(string memory _name) {
        require(!isPresent[_name], "Book Already present");
        _;
    }

    function _getNextBookId() private view returns (uint256) {
        return bookCount.add(1);
    }

    function _increment() private {
        bookCount = bookCount.add(1);
    }

    function addBook(string memory _name, uint256 _copies)
        external
        onlyOwner
        bookNotPresent(_name)
    {
        require(bytes(_name).length != 0, "Name cannot be empty");
        isPresent[_name] = true;
        uint256 _bookId = _getNextBookId();
        Book storage book = BookLedger[_bookId];
        book.name = _name;
        book.availableCopies = _copies;
        _increment();
    }

    function addBookCopies(uint256 _bookId, uint256 _copies)
        external
        onlyOwner
    {
        require(_copies > 0, "!zero");
        Book storage book = BookLedger[_bookId];
        require(bytes(book.name).length != 0, "Book does not exist");
        book.availableCopies = book.availableCopies.add(_copies);
    }

    function borrowBook(uint256 _id) external {
        require(!isAlreadyIssued[msg.sender][_id], "Book is already issued");
        isAlreadyIssued[msg.sender][_id] = true;
        Book storage book = BookLedger[_id];
        require(book.availableCopies.sub(1) >= 0);
        book.availableCopies = book.availableCopies.sub(1);
        book.ownersHistory[book.ownerCount] = msg.sender;
        book.ownerCount = book.ownerCount.add(1);
    }

    function returnBook(uint256 _id) external {
        require(isAlreadyIssued[msg.sender][_id], "Book is not issued");
        Book storage book = BookLedger[_id];
        book.availableCopies = book.availableCopies.add(1);
        isAlreadyIssued[msg.sender][_id] = false;
    }

    function getAllAvailableBooks() external view returns (uint256[] memory) {
        uint256 currentIndex = 0;
        for (uint256 index = 1; index <= bookCount; index++) {
            if (!isAlreadyIssued[msg.sender][index] && BookLedger[index].availableCopies > 0) {
                currentIndex++;
            }
        }
        uint256[] memory result = new uint256[](currentIndex);
        currentIndex = 0;
        for (uint256 index = 1; index <= bookCount; index++) {
            if (!isAlreadyIssued[msg.sender][index] && BookLedger[index].availableCopies > 0) {
                result[currentIndex] = index;
                currentIndex++;
            }
        }
        return result;
    }

    function getOwnerHistoryOfBook(uint256 _id)
        public
        view
        returns (address[] memory)
    {
        address[] memory result = new address[](BookLedger[_id].ownerCount);
        for (uint256 index = 0; index < result.length; index++) {
            result[index] = BookLedger[_id].ownersHistory[index];
        }
        return result;
    }

    function getBookDetail(uint256 _id)
        public
        view
        returns (string memory, uint256)
    {
        return (BookLedger[_id].name, BookLedger[_id].availableCopies);
    }
}
