// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

/// @custom:security-contact me@rolilink.com
abstract contract PanamaZonesManager  {
     //using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;
     using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct Province {
        string name;
        uint256 code;
    }

    struct District {
        string name;
        uint8 provinceCode;
        uint16 code;
    }

    struct Corregimiento {
	    string name;
        uint8 districtCode;
        uint16 code;
    }

    struct Provinces {
        mapping(uint256 => Province) values;
        EnumerableSetUpgradeable.UintSet ids;
    }
/*
    // saves the districts under their bytes32 string representation (2-1)
    struct Districts {
        mapping(bytes32 => District) values;
        bytes32[] ids;
    }

    // // saves the corregimientos under their bytes32 string representation (8-1-3)
    struct Corregimientos {
        mapping(bytes32 => Corregimiento) values;
        bytes32[] ids;
    }
*/

    // Variables declaration
    Provinces provinces;

    constructor() { }

    function __PanamaZonesManager_init(Province[] memory _provinces) internal {
        initializeProvinces(_provinces);
    }

    function initializeProvinces(Province[] memory _provinces) private {
        _authorizeZonesManager();

         if (_provinces.length == 0 ) {
            return;
        }

        for (uint256 index = 0; index < _provinces.length; index++) {
            setProvince(_provinces[index]);
        }
    }

    function setProvince(Province memory _province) public {
        _authorizeZonesManager();
        provinces.values[_province.code] = _province;
        provinces.ids.add( _province.code);
    }

    function getProvinces() public view returns(Province[] memory) {
        uint256 length = provinces.ids.length();
        Province[] memory rProvinces = new Province[](length);

        for (uint256 index = 0; index < length; index++) {
            rProvinces[index] = provinces.values[provinces.ids.at(index)];
        }

        return rProvinces;
    }

    function getProvince(uint8 provinceCode) public view returns(Province memory) {
        require(provinceCode > 0, "Minimum province code is 1");

        return provinces.values[provinceCode];
    }

    // Authorize setter functions since any contract inherting this will implement it's own access control logic
    function _authorizeZonesManager() internal virtual;
}