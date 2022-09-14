const ZiptyCore = artifacts.require("Zipty");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

contract("Zipty V1", function () {
  it("Should contain the correct name", async function () {
    const ziptyContract = await deployProxy(ZiptyCore, { kind: "uups" });
    
    assert( await ziptyContract.name() === 'Zipty');
  });

  it("Should contain the correct symbol", async function () {
    const ziptyContract = await deployProxy(ZiptyCore, { kind: "uups" });
    
    assert( await ziptyContract.symbol() === 'ZPTY');
  });
});
