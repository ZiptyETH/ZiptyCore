const ZiptyCore = artifacts.require("Zipty");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const deployZiptyV1 = async () => await deployProxy(ZiptyCore, { kind: "uups" });

contract("Zipty V1", function () {
  it("Should contain the correct name", async function () {
    const ziptyContract = await deployZiptyV1();
    
    assert( await ziptyContract.name() === 'Zipty');
  });

  it("Should contain the correct symbol", async function () {
    const ziptyContract = await deployZiptyV1();
    
    assert( await ziptyContract.symbol() === 'ZPTY');
  });
});
