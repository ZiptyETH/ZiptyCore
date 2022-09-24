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
        uint256 provinceCode;
        uint256 code;
    }

    struct Corregimiento {
	    string name;
        uint256 provinceCode;
        uint256 districtCode;
        uint256 code;
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

    // // saves the corregimientos under their bytes32 string representation (8-1-3)
    struct Corregimientos {
        mapping(bytes32 => Corregimiento) values;
        EnumerableSetUpgradeable.Bytes32Set ids;
    }

    // Variables declaration
    Provinces provinces;
    Districts districts;
    Corregimientos corregimientos;

    constructor() { }

    modifier isValidCode(uint256 code, string memory codeType) {
        require(code > 0, string(abi.encodePacked('PMZ: Minimum ', codeType, ' code is 1.')));
        _;
    }

    modifier isValidDistrict(uint256 provinceCode, uint256 code) {
        {
            require(code > 0, "PMZ: Minimum District code is 1.");
            require(provinceCode > 0, "PMZ: Minimum Province code is 1.");
        }

        Province memory _province = provinces.values[provinceCode];
        require(_province.code != 0, "PMZ: Paren't province doesn't exist ");
        _;
    }

    modifier isValidCorregimiento(uint256 provinceCode, uint256 districtCode, uint256 code) {
        {
            require(code > 0, "PMZ: Minimum Corregimiento code is 1.");
            require(provinceCode > 0, "PMZ: Minimum Province code is 1.");
            require(districtCode > 0, "PMZ: Minimum District code is 1.");
        }

        bytes32 id = getDistrictIdAsBytes32(provinceCode, districtCode);
        District memory _district = districts.values[id];
        require(_district.code != 0, "PMZ: Paren't District doesn't exist ");
        _;
    }

    function __PanamaZonesManager_init(Province[] memory _provinces, District[] memory _districts, Corregimiento[] memory _corregimientos) internal {
        _authorizeZonesManager();
        initializeProvinces(_provinces);
        initializeDistricts(_districts);
        initializeCorregimientos(_corregimientos);
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

     function initializeCorregimientos(Corregimiento[] memory _corregimientos) private {
         if (_corregimientos.length == 0 ) {
            return;
        }

        for (uint256 index = 0; index < _corregimientos.length; index++) {
            setCorregimiento(_corregimientos[index]);
        }
    }

    function setProvince(Province memory _province) isValidCode(_province.code, "province") public {
        _authorizeZonesManager();
        
        provinces.values[_province.code] = _province;
        provinces.ids.add(_province.code);
    }

    function getDistrictIdAsBytes32(uint256 provinceCode, uint256 districtCode) private pure returns (bytes32) {
        return bytes32(abi.encodePacked(
                StringsUpgradeable.toString(provinceCode),
                '-',
                StringsUpgradeable.toString(districtCode)
            ));
    }

    function getCorregimientoIddAsBytes32(uint256 provinceCode, uint256 districtCode, uint256 corregimientoCode) private pure returns (bytes32) {
        return bytes32(abi.encodePacked(
                StringsUpgradeable.toString(provinceCode),
                '-',
                StringsUpgradeable.toString(districtCode)
                ,
                '-',
                StringsUpgradeable.toString(corregimientoCode)
            ));
    }

    function getCorregimientoIddAsString(uint256 provinceCode, uint256 districtCode, uint256 corregimientoCode) private pure returns (string memory) {
        return string(abi.encodePacked(
                StringsUpgradeable.toString(provinceCode),
                '-',
                StringsUpgradeable.toString(districtCode)
                ,
                '-',
                StringsUpgradeable.toString(corregimientoCode)
            ));
    }

    function getDistrictIdAsString(uint256 provinceCode, uint256 districtCode) public pure returns (string memory) {
        return string(abi.encodePacked(
                StringsUpgradeable.toString(provinceCode),
                '-',
                StringsUpgradeable.toString(districtCode)
            ));
    }

    function setDistrict(District memory _district)
        isValidDistrict(_district.provinceCode, _district.code)
        public {
        _authorizeZonesManager();
        
        bytes32 id = getDistrictIdAsBytes32(_district.provinceCode, _district.code);
        
        districts.values[id] = _district;
        districts.ids.add(id);
    }

     function setCorregimiento(Corregimiento memory _corregimiento)
        isValidCorregimiento(_corregimiento.provinceCode, _corregimiento.districtCode, _corregimiento.code)
        public {
        _authorizeZonesManager();
        
        bytes32 id = getCorregimientoIddAsBytes32(_corregimiento.provinceCode, _corregimiento.districtCode, _corregimiento.code);
        
        corregimientos.values[id] = _corregimiento;
        corregimientos.ids.add(id);
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

    function getCorregimientos() public view returns(Corregimiento[] memory) {
        uint256 length = corregimientos.ids.length();
        Corregimiento[] memory rCorregimientos = new Corregimiento[](length);

        for (uint256 index = 0; index < length; index++) {
            rCorregimientos[index] = corregimientos.values[corregimientos.ids.at(index)];
        }

        return rCorregimientos;
    }

    function getProvince(uint256 provinceCode) public view isValidCode(provinceCode, "province") returns(Province memory) {
        return provinces.values[provinceCode];
    }

    function getDistrict(uint256 provinceCode, uint256 districtCode)
        public
        view
        isValidDistrict(provinceCode, districtCode)
        returns(District memory) {
        return districts.values[getDistrictIdAsBytes32(provinceCode, districtCode)];
    }

    function getCorregimiento(uint256 provinceCode, uint256 districtCode, uint256 code)
        public
        view
        isValidCorregimiento(provinceCode, districtCode, code)
        returns(Corregimiento memory) {
        bytes32 id = getCorregimientoIddAsBytes32(provinceCode, districtCode, code);
        {
            return corregimientos.values[id];   
        }
    }

    // Authorize setter functions since any contract inherting this will implement it's own access control logic
    function _authorizeZonesManager() internal virtual;
}