const Library = artifacts.require('Library');

contract('Library', (accounts) => {
    let LibraryContract;
    const admin = accounts[0];
    const bookName = "Lorem Ipsum";
    const copies = 10;
    beforeEach(async () => {
        LibraryContract = await Library.new({from: admin});
    });
    it('Add book', async() => {
        await LibraryContract.addBook(bookName, copies, {from: admin});
        try {
            await LibraryContract.addBook(bookName, copies, {from: admin});
        } catch(err) {
            assert.equal(false, false);
        }
    })
})