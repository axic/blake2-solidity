const Blake2bTest = artifacts.require('Blake2bTest.sol');

contract('Blake2bTest', function (accounts) {
    let contract;

    beforeEach(async () => {
        contract = await Blake2bTest.new();
    });

    it('smoke', async () => {
        let ret = await contract.testOneBlock.call(Buffer.alloc(0), 0);
        assert.equal(ret, '0x48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b', 'hash mismatch');
    });

    it('eip-152 test vector 5', async () => {
        let input = Buffer.from('6162630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', 'hex');
        let ret = await contract.testOneBlock.call(input, 3);
        assert.equal(ret, '0xba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923', 'hash mismatch');
    });
});
