const ZiptyCore = artifacts.require("Zipty");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const {
  expectRevert,
} = require('@openzeppelin/test-helpers');

const PROVINCES = [
  { code: 8, name: "Panama" },
  { code: 6, name: "Herrera" },
];

const DISTRICTS = [
  { provinceCode: 8, code: 1, name: "Balboa" },
  { provinceCode: 8, code: 2, name: "Chepo" },
  { provinceCode: 8, code: 3, name: "Chimán" },
  { provinceCode: 8, code: 4, name: "Panamá" },
  { provinceCode: 8, code: 5, name: "San Miguelito" },
  { provinceCode: 8, code: 6, name: "Taboga" },
  { provinceCode: 6, code: 1, name: "Chitré" },
  { provinceCode: 6, code: 2, name: "Las Minas" },
  { provinceCode: 6, code: 3, name: "Los Pozos" },
  { provinceCode: 6, code: 4, name: "Ocú" },
  { provinceCode: 6, code: 5, name: "Parita" },
  { provinceCode: 6, code: 6, name: "Pesé" },
  { provinceCode: 6, code: 7, name: "Santa María" },

];

const deployZiptyV1 = async (provinces = PROVINCES, districts = DISTRICTS) => 
  await deployProxy(ZiptyCore, [ provinces, districts ], { kind: "uups" });

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

  it("should be able to be initialized", async function () {
    const provinces = [
      { code: 6, name: "Herrera" },
      { code: 3, name: "Colon" },
    ];

    const districts = [
      { provinceCode: 6, code: 1, name: "Chitré" },
      { provinceCode: 6, code: 2, name: "Las Minas" },
      { provinceCode: 6, code: 3, name: "Los Pozos" },
    ];

    const ziptyContract = await deployZiptyV1(provinces, districts);
    
    await ziptyContract.getProvinces();
    
    assert(true);
  });

  it("getProvinces should return all provinces", async function () {
    const ziptyContract = await deployZiptyV1();
    
    const results = await ziptyContract.getProvinces();

    assert.equal(results.length, PROVINCES.length);

    results.forEach(result => {
      const province = PROVINCES.find((_province) => _province.code == result.code && _province.provinceCode == result.provinceCode);

      assert.equal(result.name, province.name);
    });
  });

  it("getProvince should return the correct province", async function () {
    const ziptyContract = await deployZiptyV1();

    const result = await ziptyContract.getProvince(PROVINCES[0].code);
   
    assert.equal(result.code, PROVINCES[0].code);
    assert.equal(result.name, PROVINCES[0].name);
  });

  it("setProvince should add a new province", async function () {
    const ziptyContract = await deployZiptyV1();
    const newProvince = {
      code: 7,
      name: "Los Santos",
    };

    await ziptyContract.setProvince(newProvince);
    const result =  await ziptyContract.getProvince(newProvince.code);
   
    assert.equal(result.code, newProvince.code);
    assert.equal(result.name, newProvince.name);
  });

  it("setProvince shouldn't set a province when the transaction is not sent from the owner", async function () {
    const ziptyContract = await deployZiptyV1();
    const newProvince = {
      code: 7,
      name: "Los Santos",
    };

    const txPromise = ziptyContract.setProvince(newProvince, { from: accounts[1] });


    await expectRevert(
      txPromise,
      "Ownable: caller is not the owner.",
    );
  });

  it("setDistrict shouldn't set a district when the transaction is not sent from the owner", async function () {
    const ziptyContract = await deployZiptyV1();
    const newDistrict =  { provinceCode: 6, code: 8, name: "Nueva Herrera" };

    const txPromise = ziptyContract.setDistrict(newDistrict, { from: accounts[1] });


    await expectRevert(
      txPromise,
      "Ownable: caller is not the owner.",
    );
  });

  it("setDistrict should set a district", async function () {
    const ziptyContract = await deployZiptyV1();
    const newDistrict =  { provinceCode: 6, code: 8, name: "Nueva Herrera" };

    await ziptyContract.setDistrict(newDistrict);
    const result =  await ziptyContract.getDistrict(newDistrict.provinceCode, newDistrict.code);
   
    assert.equal(result.code, newDistrict.code);
    assert.equal(result.provinceCode, newDistrict.provinceCode);
    assert.equal(result.name, newDistrict.name);
  });

  it("setDistrict shouldn't set a district when the provinceCode is invalid", async function () {
    const ziptyContract = await deployZiptyV1();
    const newDistrict =  { provinceCode: 0, code: 8, name: "Nueva Herrera" };

    const txPromise = ziptyContract.setDistrict(newDistrict);


    await expectRevert(
      txPromise,
      "PMZ: Minimum province code is 1.",
    );
  });

  it("setDistrict shouldn't set a district when the code is invalid", async function () {
    const ziptyContract = await deployZiptyV1();
    const newDistrict =  { provinceCode: 6, code: 0, name: "Nueva Herrera" };

    const txPromise = ziptyContract.setDistrict(newDistrict);


    await expectRevert(
      txPromise,
      "PMZ: Minimum district code is 1.",
    );
  });

  it("setDistrict shouldn't set a district when the code is invalid", async function () {
    const ziptyContract = await deployZiptyV1();
    const newDistrict =  { provinceCode: 2, code: 1, name: "Nuevo Colon" };

    const txPromise = ziptyContract.setDistrict(newDistrict);


    await expectRevert(
      txPromise,
      "PMZ: Paren't province doesn't exist",
    );
  });

  it("getDistricts should return all districts", async function () {
    const ziptyContract = await deployZiptyV1();
    
    const results = await ziptyContract.getDistricts();

    assert.equal(results.length, DISTRICTS.length);    
    results.forEach(result => {
      const district = DISTRICTS.find((_district) => _district.code == result.code && _district.provinceCode == result.provinceCode);

      assert.equal(result.name, district.name);
    });
  });
  

  it("getDistrictIdAsString should return the correct id", async function () {
    const ziptyContract = await deployZiptyV1();

    const id = await ziptyContract.getDistrictIdAsString(7, 1);


    assert.equal(id, '7-1');
  });

  it("getDistrict should return the correct province", async function () {
    const ziptyContract = await deployZiptyV1();

    const result = await ziptyContract.getDistrict(DISTRICTS[0].provinceCode, DISTRICTS[0].code);
   
    assert.equal(result.code, DISTRICTS[0].code);
    assert.equal(result.name, DISTRICTS[0].name);
    assert.equal(result.provinceCode, DISTRICTS[0].provinceCode);
  });
});
