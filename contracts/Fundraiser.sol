pragma solidity >0.4.23 <0.7.0;

import "../client/node_modules/@openzeppelin/contracts/ownership/Ownable.sol";
import "../client/node_modules/@openzeppelin/contracts/math/SafeMath.sol";
//import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Fundraiser is Ownable {

    using SafeMath for uint256;

    string public name;
    string public url;
    string public imageURL;
    string public description;

    address payable public beneficiary;

    struct Donation {
        uint256 value;
        uint256 date;
    }

    mapping(address => Donation[]) private _donations;

    event DonationReceived(address indexed donor, uint256 value);
    event Withdraw(uint256 amount);

    uint256 public totalDonations;
    uint256 public donationsCount;

    constructor(
        string memory _name,
        string memory _url,
        string memory _imageURL,
        string memory _description,
        address payable _beneficiary,
        address _custodian
    ) 
        public 
    {
        name = _name;
        url = _url;
        imageURL = _imageURL;
        description = _description;
        beneficiary = _beneficiary;
        _transferOwnership(_custodian);
    }

    function setBeneficiary(address payable _newBeneficiary) public onlyOwner {
        beneficiary = _newBeneficiary;
    }

    function myDonationsCount() public view returns(uint256) {
        return _donations[msg.sender].length;
    } 

    function donate() public payable {
        Donation memory donation = Donation({
            value: msg.value,
            date: block.timestamp
        });
        _donations[msg.sender].push(donation);
        totalDonations = totalDonations.add(msg.value);
        donationsCount++;

        emit DonationReceived(msg.sender, msg.value);
    }

    function myDonations() public view returns(
        uint256[] memory values,
        uint256[] memory dates
    )
    {
        uint256 count = myDonationsCount();
        values = new uint256[](count);
        dates = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            Donation storage donation = _donations[msg.sender][i];
            values[i] = donation.value;
            dates[i] = donation.date;
        }

        return (values, dates);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = beneficiary.call.value(balance)(""); 
        require(success, "Error: Transfer failed.");
        
        emit Withdraw(balance);
    }

    function () external payable {
        totalDonations = totalDonations.add(msg.value);
        donationsCount++;
    }
}
