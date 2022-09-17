const ZiptyCore = artifacts.require("Zipty");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const PROVINCES = [
  { code: 8, name: "Panama" },
];

const transformResultInStruct = ( result ) => {
  console.log(result.code);

  const jsonString = result.reduce((jsonString, resultMember, index, array) => {
    if (!resultMember.includes(':')) return jsonString;

    return jsonString + resultMember + ( index < array.length - 1 ? ',' : '');
  }, '{ ') + ' }';

  console.log(jsonString);
}

const deployZiptyV1 = async ({ provinces } = { provinces: PROVINCES }) => await deployProxy(ZiptyCore, [ provinces ], { kind: "uups" });

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

contract("PanamaZonesManager", function (accounts) {
  const ownerAccount = accounts[0];

  it("should be able to be initialized with provinces", async function () {
    const provinces = [
      { code: 6, name: "Herrera" },
      { code: 3, name: "Colon" },
    ];

    const ziptyContract = await deployZiptyV1({ provinces });
    
    const results = await debug(ziptyContract.getProvinces());
    const herreraProvince = results.find((result) => result.code == provinces[0].code);
    const colonProvince = results.find((result) => result.code == provinces[1].code);

    assert.equal(herreraProvince.code, provinces[0].code);
    assert.equal(colonProvince.code, provinces[1].code);
  });

  it("getProvince should return the correct province", async function () {
    const ziptyContract = await deployZiptyV1();

    const result = await ziptyContract.getProvince(PROVINCES[0].code);
   
    assert.equal(result.code, PROVINCES[0].code);
    assert.equal(result.name, PROVINCES[0].name);
  });
});
