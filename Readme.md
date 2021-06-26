# Library
## Requirements
* Rust (nightly)
* Docker
* docker-compose

## Setup and test
```
# Install Dependencies
npm install

# Compile contracts
./node_modules/.bin/truffle compile

# Run local development RPC instance
./node_modules/.bin/ganache-cli

# Run tests
./node_modules/.bin/truffle test
```

## Key terms
### `Administrator`
Administrator is the person which can add new books in library
### `Book`
Book consist of name, id and copies which is available in library of a given book.
### `Borrower`
Borrower is a user which can take a book from library. He can only take a 1 copy of book per book.
### `BookLedger`
BookLedger contain one - one mapping of ids with books.

## Functions description
### `addBook(string memory _name, uint256 _copies)`
- Only Adminstrator can call this function.
- It is used to add books in library.
- It also autogenerate an id and assign it to book.

#### Parameter description
* _name: name of book. Name of book is also unique. So there will be no 2 books having same name
* _copies: total number of copies of a book included in library

### `addBookCopies(uint256 _bookId, uint256 _copies)`
- Only Adminstrator can call this function.
- It is used to add more copies of an existing book.

#### Parameter description
* _bookId: Id of book
* _copies: total number of copies of the book to add.

### `borrowBook(uint256 _id)`
- It is a public function.
- It can only borrow a book which is available in the library
- User can only borrow 1 copy of book with given Id.
- Borrowing of book reduce the available copies of book by 1
- User cannot borrow books more than available copies of book with given id.

#### Parameter description
* id: id of a book present in library

### `returnBook(uint256 _id)`
- It is a public function.
- User can only return a book if it is borrowed by given user.
- Returning of book will increase available copies by 1.

#### Parameter description
* id: id of a book present in library

### `getAllAvailableBooks()`
- It is a public function.
- Return an array of bookIds which given user can borrow ie.. only books which are not borrowed by user and books whose copies are available in the library

### `getOwnerHistoryOfBook(uint256 _id)`
- It is a public function.
- Return an array of addresses of user who borrowed the book untill present

#### Parameter description
* id: id of a book present in library

### `getBookDetail(uint256 _id)`
- It is a public function.
- returns an name of book and available copies of given book

#### Parameter description
* id: id of a book present in library