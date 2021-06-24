const Library = artifacts.require("Library");
const { assertAsyncThrows } = require("./utils/assertError");

contract("Library", (accounts) => {
  let LibraryContract;
  const admin = accounts[0];
  const issuer1 = accounts[1];
  const issuer2 = accounts[2];
  const issuer3 = accounts[3];
  const bookName = "Lorem Ipsum";
  const copies = 10;
  beforeEach(async () => {
    LibraryContract = await Library.new({ from: admin });
  });
  it("Add book", async () => {
    await LibraryContract.addBook(bookName, copies, { from: admin });
    await assertAsyncThrows(
      LibraryContract.addBook(bookName, copies, { from: admin })
    );
    await LibraryContract.addBook(bookName + "1", copies, { from: admin });
    await LibraryContract.addBook(bookName + "2", copies, { from: admin });
    const counter = await LibraryContract.counter();
    assert.equal(counter.toNumber(), 3);
  });

  it("Borrow book", async () => {
    await LibraryContract.addBook(bookName, 2, { from: admin });
    const availableBookBNArray = await LibraryContract.getAllAvailableBooks();
    const avlBook = availableBookBNArray.map((item) => item.toNumber());
    await LibraryContract.borrowBook(avlBook[0], { from: issuer1 });
    await assertAsyncThrows(
      LibraryContract.borrowBook(avlBook[0], { from: issuer1 })
    );
    await LibraryContract.borrowBook(avlBook[0], { from: issuer2 });
    const { 1: totalCount } = await LibraryContract.getBookDetail(avlBook[0]);
    assert.equal(totalCount.toNumber(), 0);
    await assertAsyncThrows(
      LibraryContract.borrowBook(avlBook[0], { from: issuer3 })
    );
  });

  it("Return book", async () => {
    await LibraryContract.addBook(bookName, 2, { from: admin });
    const availableBookBNArray = await LibraryContract.getAllAvailableBooks();
    const avlBook = availableBookBNArray.map((item) => item.toNumber());
    await LibraryContract.borrowBook(avlBook[0], { from: issuer1 });
    await assertAsyncThrows(
      LibraryContract.borrowBook(avlBook[0], { from: issuer1 })
    );
    await LibraryContract.borrowBook(avlBook[0], { from: issuer2 });
    const { 1: avlCopies } = await LibraryContract.getBookDetail(avlBook[0]);
    assert.equal(avlCopies.toNumber(), 0);
    await assertAsyncThrows(
      LibraryContract.borrowBook(avlBook[0], { from: issuer3 })
    );
    await LibraryContract.returnBook(avlBook[0], { from: issuer2 });
    await LibraryContract.borrowBook(avlBook[0], { from: issuer3 });
    await assertAsyncThrows(
      LibraryContract.borrowBook(avlBook[0], { from: accounts[4] })
    );
    await LibraryContract.returnBook(avlBook[0], { from: issuer1 });
    await LibraryContract.returnBook(avlBook[0], { from: issuer3 });
    const { 1: avlCopies1 } = await LibraryContract.getBookDetail(avlBook[0]);
    assert.equal(avlCopies1.toNumber(), 2);
    await assertAsyncThrows(
      LibraryContract.returnBook(avlBook[0], { from: accounts[5] })
    );
  });

  it("History of borrowers for a given book", async () => {
    await LibraryContract.addBook(bookName, 2, { from: admin });
    const availableBookBNArray = await LibraryContract.getAllAvailableBooks();
    const avlBook = availableBookBNArray.map((item) => item.toNumber());
    await LibraryContract.borrowBook(avlBook[0], { from: issuer1 });

    await LibraryContract.borrowBook(avlBook[0], { from: issuer2 });
    const { 1: avlCopies } = await LibraryContract.getBookDetail(avlBook[0]);
    assert.equal(avlCopies.toNumber(), 0);

    await LibraryContract.returnBook(avlBook[0], { from: issuer2 });
    await LibraryContract.borrowBook(avlBook[0], { from: issuer3 });

    await LibraryContract.returnBook(avlBook[0], { from: issuer1 });
    await LibraryContract.returnBook(avlBook[0], { from: issuer3 });
    const data = await LibraryContract.getBorrowHistoryOfBook(avlBook[0], {
      from: issuer1,
    });
    const result = [issuer1, issuer2, issuer3];
    assert.equal(data.length, result.length);
    assert.equal(data[0], result[0]);
    assert.equal(data[1], result[1]);
    assert.equal(data[2], result[2]);
  });

  it("get available books for a user", async () => {
    await LibraryContract.addBook(bookName, 2, { from: admin });
    await LibraryContract.addBook(bookName + "1", 3, { from: admin });
    await LibraryContract.addBook(bookName + "2", 2, { from: admin });
    let availableBookBNArray = await LibraryContract.getAllAvailableBooks({
      from: issuer1,
    });

    let avlBook = availableBookBNArray.map((item) => item.toNumber());
    let mainBookId = avlBook[0];
    assert.equal(avlBook.length, 3);
    await LibraryContract.borrowBook(mainBookId, { from: issuer1 });

    await LibraryContract.borrowBook(mainBookId, { from: issuer2 });
    availableBookBNArray = await LibraryContract.getAllAvailableBooks({
      from: issuer1,
    });

    avlBook = availableBookBNArray.map((item) => item.toNumber());
    assert.equal(avlBook.length, 2);
    assert.equal(avlBook.includes(mainBookId), false);
    const { 1: avlCopies } = await LibraryContract.getBookDetail(mainBookId);
    assert.equal(avlCopies.toNumber(), 0);

    await LibraryContract.returnBook(mainBookId, { from: issuer2 });
    await LibraryContract.borrowBook(mainBookId, { from: issuer3 });

    await LibraryContract.returnBook(mainBookId, { from: issuer1 });
    await LibraryContract.returnBook(mainBookId, { from: issuer3 });
    availableBookBNArray = await LibraryContract.getAllAvailableBooks({
      from: issuer1,
    });

    avlBook = availableBookBNArray.map((item) => item.toNumber());
    assert.equal(avlBook.length, 3);
    assert.equal(avlBook.includes(mainBookId), true);
  });
});
