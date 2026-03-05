// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "./diamond_parent.sol";

// Interface ของ DiamondStorage ที่เชื่อมต่อเพื่อดึงข้อมูล
interface IDiamondStorage {
    function certificates(uint256 _serialNumber) external view returns (
        uint256, address, string memory, string memory, string memory, string memory, uint256
    );

    function certificateDetails(uint256 _serialNumber) external view returns (
        string memory, string memory, string memory, string memory, string memory, string memory
    );

    function validCertificates(uint256 _serialNumber) external view returns (bool);

    // ดึงใบ Certificate ทั้งหมดที่ Owner ถือครอง
    function getOwnerCertificates(address _owner) external view returns (uint256[] memory);

    // ดึงข้อมูลเจ้าของปัจจุบัน
    function getCurrentOwner(uint256 _serialNumber) external view returns (address);
}

contract DiamondView {
    address public storageContract;

    constructor(address _storageContract) {
        storageContract = _storageContract;
    }

    // ดึงข้อมูลพื้นฐานจาก Parent
    function getBasicDetails(uint256 _serialNumber) public view returns (
        uint256, address, string memory, string memory, string memory, string memory, uint256
    ) {
        return IDiamondStorage(storageContract).certificates(_serialNumber);
    }

    // ดึงข้อมูลเชิงลึกจาก Parent
    function getExtendedDetails(uint256 _serialNumber) public view returns (
        string memory, string memory, string memory, string memory, string memory, string memory
    ) {
        return IDiamondStorage(storageContract).certificateDetails(_serialNumber);
    }

    // ตรวจสอบความถูกต้องของใบ Certificate
    function verifyCertificate(uint256 _serialNumber) public view returns (bool) {
        return IDiamondStorage(storageContract).validCertificates(_serialNumber);
    }

    // ดึงจำนวนใบ Certificate ทั้งหมดที่ Address นั้นถืออยู่
    function getCertificatesOfOwner(address _owner) public view returns (uint256[] memory) {
        return IDiamondStorage(storageContract).getOwnerCertificates(_owner);
    }

    // ดึงเจ้าของปัจจุบันของ Certificate
    function getCurrentOwner(uint256 _serialNumber) public view returns (address) {
        return IDiamondStorage(storageContract).getCurrentOwner(_serialNumber);
    }
}
