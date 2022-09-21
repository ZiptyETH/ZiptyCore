// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/// @custom:security-contact me@rolilink.com
abstract contract PanamaZonesManager  {
     using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;
     using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct Province {
        string name;
        uint256 code;
    }

    struct District {
        string name;
        uint8 provinceCode;
        uint8 code;
    }

    struct Corregimiento {
	    string name;
        uint8 districtCode;
        uint8 code;
    }

    struct Provinces {
        mapping(uint256 => Province) values;
        EnumerableSetUpgradeable.UintSet ids;
    }

    // saves the districts under their bytes32 string representation (2-1)
    struct Districts {
        mapping(bytes32 => District) values;
        EnumerableSetUpgradeable.Bytes32Set ids;
    }
/*
    // // saves the corregimientos under their bytes32 string representation (8-1-3)
    struct Corregimientos {
        mapping(bytes32 => Corregimiento) values;
        bytes32[] ids;
    }
*/

    // Variables declaration
    Provinces provinces;
    Districts districts;

    constructor() { }

    modifier isValidCode(uint256 code, string memory codeType) {
        require(code > 0, string(abi.encodePacked('PMZ: Minimum ', codeType, ' code is 1.')));
        _;
    }

    modifier withExistingProvince(uint256 code) {
        Province memory _province = provinces.values[code];
        require(_province.code != 0, "PMZ: Paren't province doesn't exist ");
        _;
    }

    function __PanamaZonesManager_init(Province[] memory _provinces, District[] memory _districts) internal {
        _authorizeZonesManager();
        initializeProvinces(_provinces);
        initializeDistricts(_districts);
    }

    function initializeProvinces(Province[] memory _provinces) private {
         if (_provinces.length == 0 ) {
            return;
        }

        for (uint256 index = 0; index < _provinces.length; index++) {
            setProvince(_provinces[index]);
        }
    }

    function initializeDistricts(District[] memory _districts) private {
         if (_districts.length == 0 ) {
            return;
        }

        for (uint256 index = 0; index < _districts.length; index++) {
            setDistrict(_districts[index]);
        }
    }

    function setProvince(Province memory _province) isValidCode(_province.code, "province") public {
        _authorizeZonesManager();
        
        provinces.values[_province.code] = _province;
        provinces.ids.add(_province.code);
    }

    function getDistrictIdAsBytes32(uint8 provinceCode, uint8 districtCode) private pure returns (bytes32) {
        return bytes32(abi.encodePacked(
                StringsUpgradeable.toString(provinceCode),
                '-',
                StringsUpgradeable.toString(districtCode)
            ));
    }

    function getDistrictIdAsString(uint8 provinceCode, uint8 districtCode) public pure returns (string memory) {
        return string(abi.encodePacked(
                StringsUpgradeable.toString(provinceCode),
                '-',
                StringsUpgradeable.toString(districtCode)
            ));
    }

    function setDistrict(District memory _district)
        isValidCode(_district.provinceCode, "province")
        isValidCode(_district.code, "district")
        withExistingProvince(_district.provinceCode)
        public {
        _authorizeZonesManager();
        
        bytes32 id = getDistrictIdAsBytes32(_district.provinceCode, _district.code);
        
        districts.values[id] = _district;
        districts.ids.add(id);
    }

    function getProvinces() public view returns(Province[] memory) {
        uint256 length = provinces.ids.length();
        Province[] memory rProvinces = new Province[](length);

        for (uint256 index = 0; index < length; index++) {
            rProvinces[index] = provinces.values[provinces.ids.at(index)];
        }

        return rProvinces;
    }

    function getDistricts() public view returns(District[] memory) {
        uint256 length = districts.ids.length();
        District[] memory rDistricts = new District[](length);

        for (uint256 index = 0; index < length; index++) {
            rDistricts[index] = districts.values[districts.ids.at(index)];
        }

        return rDistricts;
    }

    function getProvince(uint8 provinceCode) public view isValidCode(provinceCode, "province") returns(Province memory) {
        return provinces.values[provinceCode];
    }

    function getDistrict(uint8 provinceCode, uint8 districtCode)
        public
        view
        isValidCode(provinceCode, "province")
        isValidCode(districtCode, "district")
        withExistingProvince(provinceCode)
        returns(District memory) {
        return districts.values[getDistrictIdAsBytes32(provinceCode, districtCode)];
    }

    // Authorize setter functions since any contract inherting this will implement it's own access control logic
    function _authorizeZonesManager() internal virtual;
}