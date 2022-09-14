const ZiptyCore = artifacts.require("Zipty");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const deployZiptyV1 = async () => await deployProxy(ZiptyCore, { kind: "uups" });

contract("Zipty V1", function (accounts) {
  const ownerAccount = accounts[0];

  it("Should contain the correct name", async function () {
    const ziptyContract = await deployZiptyV1();
    
    assert( await ziptyContract.name() === 'Zipty');
  });

  it("Should contain the correct symbol", async function () {
    const ziptyContract = await deployZiptyV1();
    
    assert( await ziptyContract.symbol() === 'ZPTY');
  });

  it("Should have the correct owner", async function () {
    const ziptyContract = await deployZiptyV1();

    const owner = await ziptyContract.owner();
    
    assert.equal(
      owner,
      ownerAccount,
    );
  });

  it("Should mint to the correct owner", async function () {
    const ziptyContract = await deployZiptyV1();
    const user = accounts[1];

    await ziptyContract.mint({
      from: user,
    });

    const newlyMintedUser = await ziptyContract.ownerOf(0)
    
    
    assert.equal(
      user,
      newlyMintedUser,
    );
  });
});
