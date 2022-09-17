// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @custom:security-contact me@rolilink.com
contract PanamaZonesManager  {
    struct Province {
        string name;
        uint8 code; // we have 9 provinces and 3 indigenous zones
    }

    struct District {
        string name;
        uint8 code; // we have 75 districts, and I don't see feasible that there will be more than 255
        uint8 provinceCode;
    }

    struct Corregimiento {
	    string name;
        uint16 code; // we have around 620 so we need uint16 in here
        uint8 districtCode;
    }

    struct Provinces {
        mapping(uint256 => Province) values;
        uint256[] ids;
    }


    // Variables declaration
    Provinces provinces;

    constructor() { }

    function __PanamaZonesManager_init(Province[] memory _provinces) internal {
        initializeProvinces(_provinces);
    }

    function initializeProvinces(Province[] memory _provinces) private {
         if (_provinces.length == 0 ) {
            return;
        }

        for (uint256 index = 0; index < _provinces.length; index++) {
            __addProvince(_provinces[index]);
        }
    }

    function __addProvince(Province memory _province) private {
        provinces.values[_province.code] = _province;
        provinces.ids.push(_province.code);
    }

    function getProvinces() public view returns(Province[] memory) {
        Province[] memory rProvinces = new Province[](provinces.ids.length);

        for (uint256 index = 0; index < provinces.ids.length; index++) {
            rProvinces[index] = provinces.values[provinces.ids[index]];
        }

        return rProvinces;
    }

    function getProvince(uint8 provinceCode) public view returns(Province memory) {
        require(provinceCode > 0, "Minimum province code is 1");

        return provinces.values[provinceCode];
    }
}