pragma solidity >=0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BookLibrary is Ownable {
    using SafeMath for uint256;
    struct Book {
        string name;
        uint256 totalCopies;
    }

    struct BookIssued {
        address issuer;
        uint256 bookId;
        uint256 entryKeyIndex;
        uint256 entryInAddressList;
        uint256 entryInBookList;
    }

    uint256 private _counter;

    mapping(string => uint256) private isPresent;

    mapping(uint256 => Book) public BookLedger;
    mapping(bytes32 => BookIssued) public entryMap;
    mapping(address => mapping(uint256 => bytes32)) public issuerToBookMap;

    bytes32[] public entryKeyList; // key list of entryMap
    mapping(address => bytes32[]) public issuerToBooks; // issuer => key list of entryMap
    mapping(uint256 => bytes32[]) public booksToIssuer; // bookId => key list of entryMap


    constructor() {}

    function _getNextBookId() internal view returns (uint256) {
        return _counter.add(1);
    }

    function addBook(string memory _name, uint256 _copies) external onlyOwner {
        require(isPresent[_name] == 0, "Book Already present");
        uint256 _bookId = _getNextBookId();
        isPresent[_name] = _bookId;
        BookLedger[_bookId] = Book(_name, _copies);
    }

    function issueBooks(uint256 _bookId) external {
        require(!_isBookAlreadyIssued(msg.sender, _bookId));
        require(bookAvailable(_bookId) > 0);
        bytes32 key = getHash(msg.sender, _bookId);
        BookIssued storage entry = entryMap[key];
        entry.issuer = msg.sender;
        entry.bookId = _bookId;
        entryKeyList.push(key);
        entry.entryKeyIndex = entryKeyList.length - 1;
        issuerToBooks[msg.sender].push(key);
        entry.entryInAddressList = issuerToBooks[msg.sender].length - 1;
        booksToIssuer[_bookId].push(key);
        entry.entryInBookList = booksToIssuer[_bookId].length - 1;
    }

    function returnBook(uint256 _bookId) external {
        require(_isBookAlreadyIssued(msg.sender, _bookId));
        bytes32 key = getHash(msg.sender, _bookId);
        BookIssued storage entry = entryMap[key];

        bytes32 lastKeyOfList = entryKeyList[entryKeyList.length - 1];
        entryMap[lastKeyOfList].entryKeyIndex = entry.entryKeyIndex;
        entryKeyList[entry.entryKeyIndex] = lastKeyOfList;
        delete entryKeyList[entryKeyList.length - 1];

        lastKeyOfList = issuerToBooks[msg.sender][
            issuerToBooks[msg.sender].length - 1
        ];
        entryMap[lastKeyOfList].entryInAddressList = entry.entryInAddressList;
        issuerToBooks[msg.sender][entry.entryInAddressList] = lastKeyOfList;
        delete issuerToBooks[msg.sender][issuerToBooks[msg.sender].length - 1];

        lastKeyOfList = booksToIssuer[_bookId][
            booksToIssuer[_bookId].length - 1
        ];
        entryMap[lastKeyOfList].entryInBookList = entry.entryInBookList;
        booksToIssuer[_bookId][entry.entryInBookList] = lastKeyOfList;
        delete booksToIssuer[_bookId][booksToIssuer[_bookId].length - 1];

        delete issuerToBookMap[msg.sender][_bookId];

        delete entryMap[key];
    }

    function _isBookAlreadyIssued(address _issuer, uint256 _bookId)
        internal
        view
        returns (bool)
    {
        return issuerToBookMap[_issuer][_bookId] != 0;
    }

    function getHash(address _issuer, uint256 _bookId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_issuer, _bookId));
    }

    function bookAvailable(uint256 _bookId) public view returns (uint256) {
        return
            BookLedger[_bookId].totalCopies.sub(booksToIssuer[_bookId].length);
    }
}
