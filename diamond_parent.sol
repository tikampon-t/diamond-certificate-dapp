// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract DiamondStorage {
    address public owner;

    // ประกาศโครงสร้างข้อมูล
    struct Certificate {
        uint256 serialNumber;
        address diamondOwner;
        string carat;
        string clarity;
        string cut;
        string color;
        uint256 issueDate;
    }

    struct CertificateDetails {
        string diamondShape;
        string measurement;
        string fluorescence;
        string girdleAndCulet;
        string laserInscription;
        string plottingDiagram;
    }

    // Mapping เก็บข้อมูล
    mapping(uint256 => Certificate) public certificates;
    mapping(uint256 => CertificateDetails) public certificateDetails;
    mapping(uint256 => bool) public validCertificates;

    // Mapping เก็บ Serial Number ของแต่ละ Owner
    mapping(address => uint256[]) public ownerCertificates;

    // Events บันทึก log แสดงการทำงานของแต่ละ function
    event CertificateCreated(uint256 serialNumber, address indexed issuer);
    event OwnershipTransferred(uint256 serialNumber, address indexed newOwner);
    event CertificateRevoked(uint256 serialNumber);
    event CertificateDetailsAdded(uint256 serialNumber);
    // กำหนดให้ contract นี้มีเฉพาะเจ้าของเท่านั้นที่เข้าถึง functiont ได้
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // สร้างข้อมูลพื้นฐานของ Certificate  
    function createCertificateBasic(
        uint256 _serialNumber,
        string memory _carat,
        string memory _clarity,
        string memory _cut,
        string memory _color
    ) public onlyOwner {
        require(!validCertificates[_serialNumber], "Certificate already exists.");

        certificates[_serialNumber] = Certificate({
            serialNumber: _serialNumber,
            diamondOwner: msg.sender,
            carat: _carat,
            clarity: _clarity,
            cut: _cut,
            color: _color,
            issueDate: block.timestamp
        });

        validCertificates[_serialNumber] = true;

        // เพิ่ม Serial Number เข้าใน Array ของ Owner
        ownerCertificates[msg.sender].push(_serialNumber);

        emit CertificateCreated(_serialNumber, msg.sender);
    }

    // เพิ่มข้อมูลเชิงลึกของ Certificate
    function addCertificateDetails(
        uint256 _serialNumber,
        string memory _diamondShape,
        string memory _measurement,
        string memory _fluorescence,
        string memory _girdleAndCulet,
        string memory _laserInscription,
        string memory _plottingDiagram
    ) public onlyOwner {
        require(validCertificates[_serialNumber], "Certificate not found.");

        certificateDetails[_serialNumber] = CertificateDetails({
            diamondShape: _diamondShape,
            measurement: _measurement,
            fluorescence: _fluorescence,
            girdleAndCulet: _girdleAndCulet,
            laserInscription: _laserInscription,
            plottingDiagram: _plottingDiagram
        });
        emit CertificateDetailsAdded(_serialNumber);
    }



    // โอนกรรมสิทธิ์
    function transferOwnership(uint256 _serialNumber, address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address.");
        require(certificates[_serialNumber].diamondOwner == msg.sender, "Only the owner can transfer ownership.");
        

        // ลบ Serial Number ออกจากเจ้าของเดิม
        uint256[] storage userCertificates = ownerCertificates[msg.sender];
        for (uint256 i = 0; i < userCertificates.length; i++) {
            if (userCertificates[i] == _serialNumber) {
                userCertificates[i] = userCertificates[userCertificates.length - 1];
                userCertificates.pop();
                break;
            }
        }

        // เพิ่ม Serial Number เข้าไปในเจ้าของใหม่
        ownerCertificates[_newOwner].push(_serialNumber);
        certificates[_serialNumber].diamondOwner = _newOwner;

        emit OwnershipTransferred(_serialNumber, _newOwner);
    }

    // เพิกถอนใบ Certificate
    function revokeCertificate(uint256 _serialNumber) public onlyOwner {
        require(validCertificates[_serialNumber], "Certificate not found.");

        // ลบ Serial Number ออกจากเจ้าของ
        uint256[] storage userCertificates = ownerCertificates[certificates[_serialNumber].diamondOwner];
        for (uint256 i = 0; i < userCertificates.length; i++) {
            if (userCertificates[i] == _serialNumber) {
                userCertificates[i] = userCertificates[userCertificates.length - 1];
                userCertificates.pop();
                break;
            }
        }

        delete certificates[_serialNumber];
        delete certificateDetails[_serialNumber];
        validCertificates[_serialNumber] = false;

        emit CertificateRevoked(_serialNumber);
    }

    // ดูใบ Certificate ทั้งหมดที่ Address หนึ่งถืออยู่
    function getOwnerCertificates(address _owner) public view returns (uint256[] memory) {
        require(_owner != address(0), "Invalid address.");
        return ownerCertificates[_owner];
    }

    // ดึงข้อมูลเจ้าของปัจจุบันของ Certificate
    function getCurrentOwner(uint256 _serialNumber) public view returns (address) {
        require(validCertificates[_serialNumber], "Certificate not found.");
        return certificates[_serialNumber].diamondOwner;
    }
}
