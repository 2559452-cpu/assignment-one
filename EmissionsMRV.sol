// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EmissionsMRV {

    struct Facility {
        string name;
        address operator;
        bool isRegistered;
    }

    struct EmissionRecord {
        uint256 facilityId;
        string reportHash;
        uint256 timestamp;
        address submittedBy;
    }

    mapping(uint256 => Facility) public facilities;
    mapping(uint256 => EmissionRecord[]) public emissionsByFacility;
    uint256 public nextFacilityId;

    address public owner;

    event FacilityRegistered(uint256 indexed facilityId, string name, address operator);
    event EmissionSubmitted(uint256 indexed facilityId, string reportHash, uint256 timestamp, address submittedBy);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyFacilityOperator(uint256 _facilityId) {
        require(facilities[_facilityId].isRegistered, "Facility not registered");
        require(msg.sender == facilities[_facilityId].operator, "Not operator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerFacility(string memory _name, address _operator) external onlyOwner {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_operator != address(0), "Invalid operator");
        facilities[nextFacilityId] = Facility(_name, _operator, true);
        emit FacilityRegistered(nextFacilityId, _name, _operator);
        nextFacilityId++;
    }

    function submitEmission(uint256 _facilityId, string memory _reportHash) external onlyFacilityOperator(_facilityId) {
        require(bytes(_reportHash).length > 0, "Hash cannot be empty");
        EmissionRecord memory newRecord = EmissionRecord({
            facilityId: _facilityId,
            reportHash: _reportHash,
            timestamp: block.timestamp,
            submittedBy: msg.sender
        });
        emissionsByFacility[_facilityId].push(newRecord);
        emit EmissionSubmitted(_facilityId, _reportHash, block.timestamp, msg.sender);
    }

    function getEmissionCount(uint256 _facilityId) external view returns (uint256) {
        require(facilities[_facilityId].isRegistered, "Facility not registered");
        return emissionsByFacility[_facilityId].length;
    }

    function getEmissionRecord(uint256 _facilityId, uint256 _index) external view returns (EmissionRecord memory) {
        require(facilities[_facilityId].isRegistered, "Facility not registered");
        require(_index < emissionsByFacility[_facilityId].length, "Index out of bounds");
        return emissionsByFacility[_facilityId][_index];
    }
}